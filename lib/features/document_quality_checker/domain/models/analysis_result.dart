/// Quality analysis result for a single image/page.
class AnalysisResult {
  final double blurScore;        // 0–100
  final int resolutionWidth;
  final int resolutionHeight;
  final double brightnessScore;  // 0–100
  final double finalScore;       // 0–100

  const AnalysisResult({
    required this.blurScore,
    required this.resolutionWidth,
    required this.resolutionHeight,
    required this.brightnessScore,
    required this.finalScore,
  });

  // --- Blur ---
  BlurLevel get blurLevel {
    if (blurScore >= 70) return BlurLevel.clear;
    if (blurScore >= 40) return BlurLevel.acceptable;
    return BlurLevel.blurry;
  }

  // --- Resolution ---
  static const int minWidth = 1000;
  static const int minHeight = 720;

  ResolutionStatus get resolutionStatus {
    if (resolutionWidth >= minWidth && resolutionHeight >= minHeight) {
      return ResolutionStatus.suitable;
    }
    return ResolutionStatus.lowResolution;
  }

  String get resolutionText => '$resolutionWidth × $resolutionHeight';

  // --- Brightness ---
  BrightnessLevel get brightnessLevel {
    if (brightnessScore < 35) return BrightnessLevel.tooDark;
    if (brightnessScore > 80) return BrightnessLevel.tooBright;
    return BrightnessLevel.balanced;
  }

  // --- Verdict ---
  QualityVerdict get verdict {
    if (finalScore >= 80) return QualityVerdict.accepted;
    if (finalScore >= 60) return QualityVerdict.warning;
    return QualityVerdict.rejected;
  }

  /// Human-readable rejection / warning reasons (Arabic).
  List<String> get reasons {
    final list = <String>[];
    if (blurLevel == BlurLevel.blurry) list.add('الصورة مغبشة');
    if (blurLevel == BlurLevel.acceptable) list.add('الصورة وضوحها مقبول لكن يفضل إعادة التصوير');
    if (brightnessLevel == BrightnessLevel.tooDark) list.add('الإضاءة ضعيفة');
    if (brightnessLevel == BrightnessLevel.tooBright) list.add('الإضاءة عالية جدًا');
    if (resolutionStatus == ResolutionStatus.lowResolution) list.add('الدقة منخفضة');
    return list;
  }
}

/// Overall analysis for a PDF document (multiple pages).
class PdfAnalysisResult {
  final List<AnalysisResult> pageResults;
  final int totalPages;
  final int analyzedPages;

  const PdfAnalysisResult({
    required this.pageResults,
    required this.totalPages,
    required this.analyzedPages,
  });

  double get overallScore {
    if (pageResults.isEmpty) return 0;
    return pageResults.map((r) => r.finalScore).reduce((a, b) => a + b) /
        pageResults.length;
  }

  QualityVerdict get verdict {
    final score = overallScore;
    if (score >= 80) return QualityVerdict.accepted;
    if (score >= 60) return QualityVerdict.warning;
    return QualityVerdict.rejected;
  }

  int get badPageCount => pageResults.where((r) => r.finalScore < 60).length;

  /// PDF-specific reasons.
  List<String> get reasons {
    final list = <String>[];
    if (badPageCount > 0 && badPageCount <= pageResults.length / 2) {
      list.add('بعض صفحات الوثيقة غير واضحة');
    }
    if (badPageCount > pageResults.length / 2) {
      list.add('الوثيقة غير قابلة للقراءة');
    }
    return list;
  }
}

// ─── Enums ───────────────────────────────────────────────

enum BlurLevel { clear, acceptable, blurry }

enum BrightnessLevel { tooDark, balanced, tooBright }

enum ResolutionStatus { suitable, lowResolution }

enum QualityVerdict { accepted, warning, rejected }
