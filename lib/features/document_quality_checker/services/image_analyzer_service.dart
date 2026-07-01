import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../domain/models/analysis_result.dart';

/// Purely client-side image quality analyser.
///
/// All analysis is approximate (no ML/AI).
class ImageAnalyzerService {
  const ImageAnalyzerService();

  /// Analyse a single image from its raw bytes.
  Future<AnalysisResult> analyzeImage(Uint8List bytes) async {
    // Offload heavy image decoding and processing to a background Isolate
    // to prevent the UI from freezing and the app from crashing.
    return await Isolate.run(() {
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        // Fallback — return worst-case result
        return const AnalysisResult(
          blurScore: 20,
          resolutionWidth: 0,
          resolutionHeight: 0,
          brightnessScore: 50,
          finalScore: 20,
        );
      }

      final width = decoded.width;
      final height = decoded.height;

      final blurScore = _computeBlurScore(decoded);
      final brightnessScore = _computeBrightnessScore(decoded);
      final resolutionScore = _computeResolutionScore(width, height);

      final finalScore =
          blurScore * 0.40 + brightnessScore * 0.30 + resolutionScore * 0.30;

      return AnalysisResult(
        blurScore: blurScore,
        resolutionWidth: width,
        resolutionHeight: height,
        brightnessScore: brightnessScore,
        finalScore: finalScore.clamp(0, 100),
      );
    });
  }

  // ─── Blur Detection (Laplacian variance approximation) ──────────

  static double _computeBlurScore(img.Image image) {
    // Down-sample for speed, but keep enough resolution (400px)
    // to detect high-frequency text edges accurately.
    final small = img.copyResize(image, width: 400);
    final grey = img.grayscale(small);

    double sum = 0;
    double sumSq = 0;
    int count = 0;

    for (int y = 1; y < grey.height - 1; y++) {
      for (int x = 1; x < grey.width - 1; x++) {
        // Laplacian kernel: [0  1  0]
        //                    [1 -4  1]
        //                    [0  1  0]
        final c = _luminance(grey.getPixel(x, y));
        final t = _luminance(grey.getPixel(x, y - 1));
        final b = _luminance(grey.getPixel(x, y + 1));
        final l = _luminance(grey.getPixel(x - 1, y));
        final r = _luminance(grey.getPixel(x + 1, y));

        final lap = (t + b + l + r - 4 * c).abs();
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }

    if (count == 0) return 50;

    final mean = sum / count;
    final variance = (sumSq / count) - (mean * mean);

    // Text documents have very high variance when sharp.
    // We map the variance -> 0..100 score using a stricter scale:
    // variance < 150 : Very blurry (score 0-39)
    // variance 150-600: Acceptable to good (score 40-79)
    // variance > 600 : Very sharp (score 80-100)

    double score = 0;
    if (variance < 150) {
      score = (variance / 150) * 39;
    } else if (variance < 600) {
      score = 40 + ((variance - 150) / 450) * 39;
    } else {
      score = 80 + ((variance - 600) / 1000) * 20;
    }

    return score.clamp(0.0, 100.0).roundToDouble();
  }

  // ─── Brightness ─────────────────────────────────────────────────

  static double _computeBrightnessScore(img.Image image) {
    final small = img.copyResize(image, width: 100);

    double totalLum = 0;
    int count = 0;

    for (int y = 0; y < small.height; y++) {
      for (int x = 0; x < small.width; x++) {
        totalLum += _luminance(small.getPixel(x, y));
        count++;
      }
    }

    if (count == 0) return 50;

    final avgLum = totalLum / count; // 0..255
    // Map to 0..100 where 50 is ideal (≈128 luminance)
    return (avgLum / 255.0 * 100).clamp(0.0, 100.0).roundToDouble();
  }

  // ─── Resolution ─────────────────────────────────────────────────

  static double _computeResolutionScore(int width, int height) {
    const minW = AnalysisResult.minWidth; // 1200
    const minH = AnalysisResult.minHeight; // 800

    final wRatio = (width / minW).clamp(0.0, 1.0);
    final hRatio = (height / minH).clamp(0.0, 1.0);
    return ((wRatio + hRatio) / 2 * 100).roundToDouble();
  }

  // ─── Helpers ────────────────────────────────────────────────────

  static double _luminance(img.Pixel pixel) {
    final r = pixel.r.toDouble();
    final g = pixel.g.toDouble();
    final b = pixel.b.toDouble();
    return 0.299 * r + 0.587 * g + 0.114 * b;
  }
}
