import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class PdfViewerPage extends StatefulWidget {
  final String fileUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _controller = PdfViewerController();
  int _pageNumber = 1;
  int _pageCount = 0;
  double _zoom = 1;
  double _viewScale = .75;
  bool _isLoading = true;
  Uint8List? _pdfBytes;
  String? _errorMessage;
  int _reloadKey = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await getIt<Dio>().get<List<int>>(
        widget.fileUrl,
        options: Options(responseType: ResponseType.bytes),
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
    final next = value.clamp(1.0, 3.0);
    _controller.zoomLevel = next;
    setState(() => _zoom = next);
  }

  void _zoomOut() {
    if (_zoom > 1) {
      _changeZoom(_zoom - .25);
      return;
    }
    setState(() => _viewScale = (_viewScale - .1).clamp(.5, 1));
  }

  void _zoomIn() {
    if (_viewScale < 1) {
      setState(() => _viewScale = (_viewScale + .1).clamp(.5, 1));
      return;
    }
    _changeZoom(_zoom + .25);
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
                const Icon(LucideIcons.fileText, size: 21),
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
                tooltip: 'الصفحة السابقة',
                icon: LucideIcons.chevronRight,
                onPressed: _pageNumber > 1 ? _previousPage : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 76),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _pageCount == 0 ? '-- / --' : '$_pageNumber / $_pageCount',
                  style: AppTextStyles.bodySmall.copyWith(
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
              const SizedBox(width: 10),
              _ToolbarButton(
                tooltip: 'تصغير',
                icon: LucideIcons.zoomOut,
                onPressed: _viewScale > .5 || _zoom > 1 ? _zoomOut : null,
              ),
              SizedBox(
                width: 48,
                child: Center(
                  child: Text(
                    '${(_zoom * _viewScale * 100).round()}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ),
              _ToolbarButton(
                tooltip: 'تكبير',
                icon: LucideIcons.zoomIn,
                onPressed: _viewScale < 1 || _zoom < 3 ? _zoomIn : null,
              ),
              const SizedBox(width: 18),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: AppColors.surface,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _errorMessage != null || _pdfBytes == null
                        ? _PdfErrorState(
                            message: _errorMessage ?? 'تعذر عرض ملف PDF',
                            onRetry: _retry,
                          )
                        : LayoutBuilder(
                            builder: (_, constraints) => OverflowBox(
                              maxWidth: constraints.maxWidth / _viewScale,
                              maxHeight: constraints.maxHeight / _viewScale,
                              child: Transform.scale(
                                scale: _viewScale,
                                child: SizedBox(
                                  width: constraints.maxWidth / _viewScale,
                                  height: constraints.maxHeight / _viewScale,
                                  child: SfPdfViewerTheme(
                                    data: const SfPdfViewerThemeData(
                                      backgroundColor: AppColors.background,
                                      progressBarColor: AppColors.primary,
                                    ),
                                    child: SfPdfViewer.memory(
                                      _pdfBytes!,
                                      key: ValueKey(_reloadKey),
                                      controller: _controller,
                                      pageLayoutMode: PdfPageLayoutMode.single,
                                      canShowScrollHead: false,
                                      canShowScrollStatus: false,
                                      enableDoubleTapZooming: true,
                                      onDocumentLoaded: (details) {
                                        if (!mounted) return;
                                        setState(() {
                                          _pageCount =
                                              details.document.pages.count;
                                          _pageNumber = 1;
                                        });
                                      },
                                      onPageChanged: (details) {
                                        if (mounted) {
                                          setState(
                                            () => _pageNumber =
                                                details.newPageNumber,
                                          );
                                        }
                                      },
                                      onDocumentLoadFailed: (details) {
                                        if (mounted) {
                                          setState(
                                            () => _errorMessage =
                                                details.description,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.fileWarning,
              size: 46,
              color: AppColors.error,
            ),
            const SizedBox(height: 13),
            const Text(
              'تعذر عرض ملف PDF',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 17),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
}
