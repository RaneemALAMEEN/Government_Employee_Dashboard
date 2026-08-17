import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../../../shared/widgets/app_snack_bar.dart';


class ImageViewerPage extends StatefulWidget {
  final String fileUrl;
  final String title;

  const ImageViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  final TransformationController _transformationController =
      TransformationController();

  bool _isLoading = true;
  Uint8List? _imageBytes;
  String? _contentType;
  String? _errorMessage;
  double _downloadProgress = 0.0;
  double _scale = 1.0;
  int _quarterTurns = 0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _loadImage();
  }

  void _onTransformationChanged() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if ((currentScale - _scale).abs() > 0.01) {
      setState(() => _scale = currentScale);
    }
  }

  String get _displayTitle {
    var title = widget.title.trim();
    final realExt = AppFileDownloader.extractExtension(
      widget.fileUrl,
      contentType: _contentType,
      bytes: _imageBytes,
      fallbackExtension: 'jpg',
    );

    if (title.isEmpty || title == 'ملف_مرفق.pdf' || title == 'ملف_مرفق') {
      return 'صورة_مرفقة.$realExt';
    }

    if (title.toLowerCase().endsWith('.pdf')) {
      title = '${title.substring(0, title.length - 4)}.$realExt';
    } else if (!title.toLowerCase().endsWith('.$realExt') &&
        !title.substring(title.lastIndexOf('/') + 1).contains('.')) {
      title = '$title.$realExt';
    }
    return title;
  }

  Future<void> _loadImage() async {
    try {
      // 1. Check local disk cache for instant opening
      final tempDir = await getTemporaryDirectory();
      final cacheKey = widget.fileUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final cacheFile = File('${tempDir.path}/img_cache_$cacheKey');

      if (await cacheFile.exists()) {
        final cachedBytes = await cacheFile.readAsBytes();
        final ext = AppFileDownloader.detectExtensionFromBytes(cachedBytes);
        if (ext != null && ext != 'pdf') {
          if (!mounted) return;
          setState(() {
            _imageBytes = cachedBytes;
            _isLoading = false;
            _errorMessage = null;
          });
          return;
        }
      }

      // 2. Download from network with progress tracking
      final response = await getIt<Dio>().get<List<int>>(
        widget.fileUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = (received / total).clamp(0.0, 1.0);
            });
          }
        },
      );

      final bytes = response.data;
      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
        _showLoadError(
          response.statusCode == 404
              ? 'الصورة غير متاحة حالياً، يرجى التواصل مع الشخص الذي أرفقها.'
              : 'تعذر تحميل الصورة. حاول مرة أخرى.',
        );
        return;
      }

      final uint8Bytes = Uint8List.fromList(bytes);
      final contentType = response.headers.value('content-type');

      // Save to local cache
      try {
        await cacheFile.writeAsBytes(uint8Bytes);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _imageBytes = uint8Bytes;
        _contentType = contentType;
        _isLoading = false;
        _errorMessage = null;
      });
    } on DioException catch (error) {
      _showLoadError(
        error.response?.statusCode == 404
            ? 'الصورة غير متاحة حالياً، يرجى التواصل مع الشخص الذي أرفقها.'
            : 'تعذر الاتصال بالخادم لتحميل الصورة.',
      );
    } catch (_) {
      _showLoadError('حدث خطأ غير متوقع أثناء تحميل الصورة.');
    }
  }

  void _showLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _imageBytes = null;
      _errorMessage = message;
    });
  }

  void _changeZoom(double value) {
    final next = value.clamp(0.5, 5.0);
    _transformationController.value = Matrix4.identity()..scale(next);
    setState(() => _scale = next);
  }

  void _zoomOut() => _changeZoom(_scale - 0.25);
  void _zoomIn() => _changeZoom(_scale + 0.25);

  void _resetZoomAndRotation() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _scale = 1.0;
      _quarterTurns = 0;
    });
  }

  void _rotateLeft() {
    setState(() {
      _quarterTurns = (_quarterTurns + 3) % 4;
    });
  }

  void _rotateRight() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
    });
  }

  Future<void> _downloadImage() async {
    if (_imageBytes == null) return;
    try {
      final savePath = await AppFileDownloader.getSavePath(
        originalFilename: _displayTitle,
        contentType: _contentType,
        bytes: _imageBytes,
      );

      final file = File(savePath);
      await file.writeAsBytes(_imageBytes!);

      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'تم التحميل بنجاح',
        message: 'تم حفظ الصورة بنجاح في:\n$savePath',
        isError: false,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'فشل التحميل',
        message: 'تعذر تحميل الصورة وحفظها على الجهاز',
        isError: true,
      );
    }
  }


  void _retry() {
    setState(() {
      _isLoading = true;
      _imageBytes = null;
      _errorMessage = null;
      _downloadProgress = 0.0;
      _scale = 1.0;
      _quarterTurns = 0;
    });
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF18181B),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 68,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          titleSpacing: 18,
          leadingWidth: 64,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'إغلاق',
            color: AppColors.surface,
            icon: const Icon(LucideIcons.x, size: 24),
          ),
          title: Row(
            children: [
              const Icon(LucideIcons.image, size: 21, color: AppColors.gold),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            _ToolbarButton(
              tooltip: 'تحميل الصورة',
              icon: LucideIcons.download,
              onPressed: _imageBytes != null ? _downloadImage : null,
            ),
            const SizedBox(width: 4),
            Container(
              height: 24,
              width: 1,
              color: AppColors.surface.withValues(alpha: 0.25),
            ),
            const SizedBox(width: 4),
            _ToolbarButton(
              tooltip: 'تدوير لليسار (90°)',
              icon: LucideIcons.rotateCcw,
              onPressed: _imageBytes != null ? _rotateLeft : null,
            ),
            _ToolbarButton(
              tooltip: 'تدوير لليمين (90°)',
              icon: LucideIcons.rotateCw,
              onPressed: _imageBytes != null ? _rotateRight : null,
            ),
            const SizedBox(width: 4),
            Container(
              height: 24,
              width: 1,
              color: AppColors.surface.withValues(alpha: 0.25),
            ),
            const SizedBox(width: 4),
            _ToolbarButton(
              tooltip: 'إعادة التعيين (100%)',
              icon: LucideIcons.refreshCw,
              onPressed: (_scale != 1.0 || _quarterTurns != 0)
                  ? _resetZoomAndRotation
                  : null,
            ),
            _ToolbarButton(
              tooltip: 'تصغير',
              icon: LucideIcons.zoomOut,
              onPressed: _scale > 0.5 ? _zoomOut : null,
            ),
            SizedBox(
              width: 52,
              child: Center(
                child: Text(
                  '${(_scale * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            _ToolbarButton(
              tooltip: 'تكبير',
              icon: LucideIcons.zoomIn,
              onPressed: _scale < 5.0 ? _zoomIn : null,
            ),
            const SizedBox(width: 14),
          ],
        ),
        body: ColoredBox(
          color: const Color(0xFF18181B),
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress > 0 ? _downloadProgress : null,
                        color: AppColors.gold,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _downloadProgress > 0
                            ? 'جاري التحميل... ${(_downloadProgress * 100).toInt()}%'
                            : 'جاري جلب الصورة...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null || _imageBytes == null
                  ? _ImageErrorState(
                      message: _errorMessage ?? 'تعذر عرض الصورة',
                      onRetry: _retry,
                    )
                  : InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 5.0,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      clipBehavior: Clip.none,
                      child: SizedBox.expand(
                        child: Center(
                          child: RotatedBox(
                            quarterTurns: _quarterTurns,
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        color: AppColors.surface,
        disabledColor: AppColors.surface.withValues(alpha: .38),
        icon: Icon(icon, size: 20),
      );
}

class _ImageErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ImageErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.umber.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.imageOff,
                    size: 34,
                    color: AppColors.umber,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تعذر عرض الصورة',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  textStyle: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
