import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class PdfViewerPage extends StatefulWidget {
  final String fileUrl;
  final String title;
  final bool readOnly;

  const PdfViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
    this.readOnly = false,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _controller = PdfViewerController();
  int _pageNumber = 1;
  int _pageCount = 0;
  double _zoom = 1;
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  String? _errorMessage;
  int _reloadKey = 0;
  PdfPageLayoutMode _layoutMode = PdfPageLayoutMode.continuous;

  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // 1. Check local disk cache first for instant opening (0ms network delay)
      final tempDir = await getTemporaryDirectory();
      final cacheKey = widget.fileUrl.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final cacheFile = File('${tempDir.path}/pdf_cache_$cacheKey.pdf');

      if (await cacheFile.exists()) {
        final cachedBytes = await cacheFile.readAsBytes();
        if (_hasPdfSignature(cachedBytes)) {
          if (!mounted) return;
          setState(() {
            _pdfBytes = cachedBytes;
            _isLoading = false;
            _errorMessage = null;
          });
          return;
        }
      }

      // 2. Download from network with progress tracking if not cached
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
              ? 'الملف غير متاح حالياً، يرجى التواصل مع الشخص الذي أرفقه.'
              : 'تعذر تحميل ملف PDF. حاول مرة أخرى.',
        );
        return;
      }

      final pdfBytes = Uint8List.fromList(bytes);
      if (!_hasPdfSignature(pdfBytes)) {
        _showLoadError('الملف المستلم ليس ملف PDF صالحاً أو أنه تالف.');
        return;
      }

      // Cache locally for fast subsequent loads
      try {
        await cacheFile.writeAsBytes(pdfBytes);
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _pdfBytes = pdfBytes;
        _isLoading = false;
        _errorMessage = null;
      });
    } on DioException catch (error) {
      _showLoadError(
        error.response?.statusCode == 404
            ? 'الملف غير متاح حالياً، يرجى التواصل مع الشخص الذي أرفقه.'
            : 'تعذر الاتصال بالخادم لتحميل الملف.',
      );
    } catch (_) {
      _showLoadError('حدث خطأ غير متوقع أثناء تحميل الملف.');
    }
  }

  bool _hasPdfSignature(Uint8List bytes) {
    final checkLength = bytes.length > 1024 ? 1024 : bytes.length;
    for (var index = 0; index <= checkLength - 5; index++) {
      if (bytes[index] == 37 &&
          bytes[index + 1] == 80 &&
          bytes[index + 2] == 68 &&
          bytes[index + 3] == 70 &&
          bytes[index + 4] == 45) {
        return true;
      }
    }
    return false;
  }

  void _showLoadError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _pdfBytes = null;
      _errorMessage = message;
    });
  }

  void _changeZoom(double value) {
    final next = value.clamp(0.5, 3.0);
    try {
      _controller.zoomLevel = next;
    } catch (_) {}
    setState(() => _zoom = next);
  }

  void _zoomOut() {
    _changeZoom(_zoom - .25);
  }

  void _zoomIn() {
    _changeZoom(_zoom + .25);
  }

  void _resetZoom() {
    _changeZoom(1.0);
    try {
      _controller.zoomLevel = 1.0;
    } catch (_) {}
  }

  void _toggleLayoutMode() {
    setState(() {
      _layoutMode = _layoutMode == PdfPageLayoutMode.continuous
          ? PdfPageLayoutMode.single
          : PdfPageLayoutMode.continuous;
      _zoom = 1.0;
    });
    try {
      _controller.zoomLevel = 1.0;
    } catch (_) {}
  }

  String _displayPercentage() {
    if (_layoutMode == PdfPageLayoutMode.single) {
      final pct = (_zoom * 49).round();
      return '$pct%';
    }
    final pct = (_zoom * 100).round();
    return '$pct%';
  }

  Future<void> _downloadPdf() async {
    if (_pdfBytes == null) return;
    try {
      final rawTitle = widget.title.trim();
      final originalFilename =
          rawTitle.endsWith('.pdf') ? rawTitle : '$rawTitle.pdf';
      final savePath = await AppFileDownloader.getSavePath(
        originalFilename: originalFilename,
      );
      final file = File(savePath);
      await file.writeAsBytes(_pdfBytes!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحميل الوثيقة بنجاح\n$savePath'),
          backgroundColor: AppColors.forest,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحميل الوثيقة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previousPage() {
    if (_pageNumber > 1) _controller.jumpToPage(_pageNumber - 1);
  }

  void _nextPage() {
    if (_pageNumber < _pageCount) _controller.jumpToPage(_pageNumber + 1);
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _pdfBytes = null;
      _errorMessage = null;
      _pageNumber = 1;
      _pageCount = 0;
      _zoom = 1.0;
      _reloadKey++;
    });
    _loadPdf();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
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
                const Icon(LucideIcons.fileText,
                    size: 21, color: AppColors.gold),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.title,
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
                tooltip: 'تحميل الوثيقة',
                icon: LucideIcons.download,
                onPressed: _pdfBytes != null ? _downloadPdf : null,
              ),
              const SizedBox(width: 4),
              Container(
                height: 24,
                width: 1,
                color: AppColors.surface.withOpacity(0.25),
              ),
              const SizedBox(width: 4),
              _ToolbarButton(
                tooltip: 'الصفحة السابقة',
                icon: LucideIcons.chevronRight,
                onPressed: _pageNumber > 1 ? _previousPage : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 72),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _pageCount == 0 ? '-- / --' : '$_pageNumber / $_pageCount',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _ToolbarButton(
                tooltip: 'الصفحة التالية',
                icon: LucideIcons.chevronLeft,
                onPressed: _pageNumber < _pageCount ? _nextPage : null,
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 1,
                color: AppColors.surface.withOpacity(0.25),
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                tooltip: _layoutMode == PdfPageLayoutMode.continuous
                    ? 'عرض صفحة واحدة كاملة'
                    : 'تصفح مستمر (عمودي)',
                icon: _layoutMode == PdfPageLayoutMode.continuous
                    ? LucideIcons.fileText
                    : LucideIcons.rows,
                onPressed: _toggleLayoutMode,
              ),
              _ToolbarButton(
                tooltip: 'إعادة التعيين (100%)',
                icon: LucideIcons.rotateCcw,
                onPressed: _zoom != 1.0 ? _resetZoom : null,
              ),
              _ToolbarButton(
                tooltip: 'تصغير',
                icon: LucideIcons.zoomOut,
                onPressed: _zoom > 0.5 ? _zoomOut : null,
              ),
              SizedBox(
                width: 52,
                child: Center(
                  child: Text(
                    _displayPercentage(),
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
                onPressed: _zoom < 3.0 ? _zoomIn : null,
              ),
              const SizedBox(width: 14),
            ],
          ),
          body: ColoredBox(
            color: const Color(0xFFE8ECEB),
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          value:
                              _downloadProgress > 0 ? _downloadProgress : null,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _downloadProgress > 0
                              ? 'جاري التحميل... ${(_downloadProgress * 100).toInt()}%'
                              : 'جاري جلب الملف...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.charcoal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null || _pdfBytes == null
                    ? _PdfErrorState(
                        message: _errorMessage ?? 'تعذر عرض ملف PDF',
                        onRetry: _retry,
                      )
                    : ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: SfPdfViewerTheme(
                          data: const SfPdfViewerThemeData(
                            backgroundColor: Color(0xFFE8ECEB),
                            progressBarColor: AppColors.primary,
                          ),
                          child: SfPdfViewer.memory(
                            _pdfBytes!,
                            key: ValueKey(
                                'pdf_${_reloadKey}_${_layoutMode.name}'),
                            controller: _controller,
                            pageLayoutMode: _layoutMode,
                            scrollDirection: PdfScrollDirection.vertical,
                            initialZoomLevel: 1.0,
                            canShowScrollHead: true,
                            canShowScrollStatus: false,
                            enableDoubleTapZooming: true,
                            enableTextSelection: !widget.readOnly,
                            canShowTextSelectionMenu: !widget.readOnly,
                            interactionMode: widget.readOnly
                                ? PdfInteractionMode.pan
                                : PdfInteractionMode.selection,
                            pageSpacing: 10,
                            onDocumentLoaded: (details) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                if (widget.readOnly) {
                                  for (final field
                                      in _controller.getFormFields()) {
                                    field.readOnly = true;
                                  }
                                  FocusManager.instance.primaryFocus?.unfocus();
                                }
                                setState(() {
                                  _pageCount = details.document.pages.count;
                                  _pageNumber = 1;
                                });
                              });
                            },
                            onPageChanged: (details) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _pageNumber = details.newPageNumber;
                                });
                              });
                            },
                            onDocumentLoadFailed: (details) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _errorMessage =
                                      'الملف غير متاح حالياً، يرجى التواصل مع الشخص الذي أرفقه.';
                                  _isLoading = false;
                                  _pdfBytes = null;
                                });
                              });
                            },
                          ),
                        ),
                      ),
          ),
        ),
      );
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

class _PdfErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PdfErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // File Icon with Exclamation mark matching the user's design image
              Container(
                width: 60,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF4A1017), width: 2.5),
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4A1017),
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تعذر عرض ملف PDF',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal.withOpacity(0.65),
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
