// import 'dart:typed_data';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:lucide_flutter/lucide_flutter.dart';
// import 'package:pdfx/pdfx.dart';

// import '../../../../shared/theme/app_colors.dart';
// import '../../../../shared/theme/app_text_styles.dart';
// import '../../domain/models/analysis_result.dart';
// import '../../domain/models/file_info.dart';
// import '../../services/image_analyzer_service.dart';
// import '../widgets/analysis_loading_widget.dart';
// import '../widgets/analysis_results_widget.dart';
// import '../widgets/empty_state_widget.dart';
// import '../widgets/file_info_widget.dart';
// import '../widgets/image_preview_widget.dart';
// import '../widgets/pdf_preview_widget.dart';
// import '../widgets/pdf_pages_results_widget.dart';
// import '../widgets/score_widget.dart';
// import '../widgets/upload_widget.dart';
// import '../widgets/verdict_widget.dart';

// /// Main page for Document Quality Checker feature.
// ///
// /// Purely client-side — no backend, no API, no file storage.
// class DocumentQualityCheckerPage extends StatefulWidget {
//   const DocumentQualityCheckerPage({super.key});

//   @override
//   State<DocumentQualityCheckerPage> createState() =>
//       _DocumentQualityCheckerPageState();
// }

// class _DocumentQualityCheckerPageState
//     extends State<DocumentQualityCheckerPage> {
//   // ─── State ──────────────────────────────────────────────────
//   UploadedFileInfo? _fileInfo;
//   bool _isAnalyzing = false;
//   String? _analysisError;

//   // Single image analysis
//   AnalysisResult? _imageResult;

//   // PDF analysis
//   PdfAnalysisResult? _pdfResult;
//   int _pdfTotalPages = 0;
//   int _pdfAnalyzedPages = 0;

//   final _analyzerService = const ImageAnalyzerService();

//   static const int _maxPdfPages = 5;

//   // ─── Actions ────────────────────────────────────────────────

//   void _onFileSelected(UploadedFileInfo fileInfo) {
//     setState(() {
//       _fileInfo = fileInfo;
//       _imageResult = null;
//       _pdfResult = null;
//       _pdfTotalPages = 0;
//       _pdfAnalyzedPages = 0;
//     });

//     _startAnalysis();
//   }

//   Future<void> _startAnalysis() async {
//     if (_fileInfo == null) return;

//     setState(() {
//       _isAnalyzing = true;
//       _imageResult = null;
//       _pdfResult = null;
//       _analysisError = null;
//     });

//     try {
//       if (_fileInfo!.isImage) {
//         await _analyzeImage();
//       } else if (_fileInfo!.isPdf) {
//         await _analyzePdf();
//       }
//     } catch (e) {
//       // Fallback on error
//       if (mounted) {
//         setState(() {
//           _isAnalyzing = false;
//         });
//       }
//     }
//   }

//   Future<void> _analyzeImage() async {
//     final result = await _analyzerService.analyzeImage(_fileInfo!.bytes);
//     if (mounted) {
//       setState(() {
//         _imageResult = result;
//         _isAnalyzing = false;
//       });
//     }
//   }

//   Future<void> _analyzePdf() async {
//     try {
//       final document = await PdfDocument.openData(_fileInfo!.bytes);
//       final totalPages = document.pagesCount;
//       final pagesToAnalyze =
//           totalPages > _maxPdfPages ? _maxPdfPages : totalPages;

//       setState(() {
//         _pdfTotalPages = totalPages;
//         _pdfAnalyzedPages = pagesToAnalyze;
//       });

//       final List<AnalysisResult> pageResults = [];

//       for (int i = 1; i <= pagesToAnalyze; i++) {
//         final page = await document.getPage(i);
//         // Render at a reasonable resolution for analysis
//         final pageImage = await page.render(
//           width: page.width,
//           height: page.height,
//           format: PdfPageImageFormat.png,
//         );

//         if (pageImage != null) {
//           final pngBytes = pageImage.bytes;
//           final result = await _analyzerService.analyzeImage(pngBytes);
//           pageResults.add(result);
//         }
//         await page.close();
//       }

//       await document.close();

//       if (mounted) {
//         setState(() {
//           _pdfResult = PdfAnalysisResult(
//             pageResults: pageResults,
//             totalPages: totalPages,
//             analyzedPages: pagesToAnalyze,
//           );
//           _isAnalyzing = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error analyzing PDF: $e');
//       if (mounted) {
//         setState(() {
//           _isAnalyzing = false;
//           _analysisError =
//               'حدث خطأ أثناء معالجة ملف الـ PDF. يرجى التأكد من إعادة بناء التطبيق بالكامل (Restart) لتحميل مكتبات معالجة الـ PDF الأصلية (Native Libraries).';
//         });
//       }
//     }
//   }

//   void _onNewFile() {
//     setState(() {
//       _fileInfo = null;
//       _imageResult = null;
//       _pdfResult = null;
//       _analysisError = null;
//       _isAnalyzing = false;
//       _pdfTotalPages = 0;
//       _pdfAnalyzedPages = 0;
//     });
//   }

//   void _onReanalyze() {
//     _startAnalysis();
//   }

//   void _onDelete() {
//     _onNewFile();
//   }

//   void _onVerdictAction() {
//     _onNewFile();
//   }

//   // ─── Build ──────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isSmall = constraints.maxWidth < 900;

//         return SingleChildScrollView(
//           padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
//           child: Directionality(
//             textDirection: TextDirection.rtl,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // ── Header ──
//                 FadeInDown(
//                   duration: const Duration(milliseconds: 400),
//                   child: _buildHeader(),
//                 ),
//                 const SizedBox(height: 28),

//                 // ── Main Content ──
//                 if (isSmall) _buildSmallLayout() else _buildWideLayout(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           textDirection: TextDirection.rtl,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: AppColors.forest.withOpacity(0.08),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 LucideIcons.shieldCheck,
//                 size: 24,
//                 color: AppColors.forest,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'فحص جودة الوثائق',
//                     style: AppTextStyles.displayMedium,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'قم برفع صورة أو ملف PDF لاختبار جودة الوثيقة قبل إرسالها.',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: AppColors.goldDark,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // Prototype badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//           decoration: BoxDecoration(
//             color: AppColors.forestLight.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(LucideIcons.testTube2,
//                   size: 13, color: AppColors.forestLight),
//               const SizedBox(width: 6),
//               Text(
//                 'Prototype / Proof of Concept',
//                 style: AppTextStyles.labelSmall.copyWith(
//                   color: AppColors.forestLight,
//                   fontWeight: AppTextStyles.semiBold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Wide (desktop) layout: left = upload, right = results ──

//   Widget _buildWideLayout() {
//     return Row(
//       textDirection: TextDirection.rtl,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left — Upload Area
//         SizedBox(
//           width: 420,
//           child: _buildUploadColumn(),
//         ),
//         const SizedBox(width: 24),
//         // Right — Results
//         Expanded(
//           child: _buildResultsColumn(),
//         ),
//       ],
//     );
//   }

//   // ── Small (mobile) layout: stacked ──

//   Widget _buildSmallLayout() {
//     return Column(
//       children: [
//         _buildUploadColumn(),
//         const SizedBox(height: 24),
//         _buildResultsColumn(),
//       ],
//     );
//   }

//   // ── Upload Column ──

//   Widget _buildUploadColumn() {
//     return Column(
//       children: [
//         if (_fileInfo == null)
//           UploadWidget(onFileSelected: _onFileSelected)
//         else ...[
//           FileInfoWidget(
//             fileInfo: _fileInfo!,
//             onNewFile: _onNewFile,
//             onReanalyze: _onReanalyze,
//             onDelete: _onDelete,
//           ),
//           const SizedBox(height: 16),
//           if (_fileInfo!.isImage)
//             ImagePreviewWidget(imageBytes: _fileInfo!.bytes),
//           if (_fileInfo!.isPdf)
//             PdfPreviewWidget(
//               pdfBytes: _fileInfo!.bytes,
//               totalPages: _pdfTotalPages > 0 ? _pdfTotalPages : 1,
//               analyzedPages: _pdfAnalyzedPages > 0 ? _pdfAnalyzedPages : 1,
//             ),
//         ],
//       ],
//     );
//   }

//   // ── Results Column ──

//   Widget _buildResultsColumn() {
//     // Loading state
//     if (_isAnalyzing) {
//       return const AnalysisLoadingWidget();
//     }

//     // Error state
//     if (_analysisError != null) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: AppColors.umber.withOpacity(0.05),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.umber.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             const Icon(LucideIcons.alertTriangle,
//                 size: 48, color: AppColors.umber),
//             const SizedBox(height: 16),
//             Text(
//               'خطأ في التحليل',
//               style: AppTextStyles.titleMedium.copyWith(color: AppColors.umber),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               _analysisError!,
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodySmall
//                   .copyWith(color: AppColors.charcoalDark),
//             ),
//           ],
//         ),
//       );
//     }

//     // Image results
//     if (_imageResult != null) {
//       return Column(
//         children: [
//           ScoreWidget(
//             score: _imageResult!.finalScore,
//             verdict: _imageResult!.verdict,
//           ),
//           const SizedBox(height: 16),
//           AnalysisResultsWidget(result: _imageResult!),
//           const SizedBox(height: 16),
//           VerdictWidget(
//             verdict: _imageResult!.verdict,
//             reasons: _imageResult!.reasons,
//             onAction: _onVerdictAction,
//           ),
//         ],
//       );
//     }

//     // PDF results
//     if (_pdfResult != null) {
//       // Use the first page result for the detailed analysis view
//       final firstPageResult = _pdfResult!.pageResults.isNotEmpty
//           ? _pdfResult!.pageResults.first
//           : null;

//       return Column(
//         children: [
//           ScoreWidget(
//             score: _pdfResult!.overallScore,
//             verdict: _pdfResult!.verdict,
//           ),
//           const SizedBox(height: 16),
//           PdfPagesResultsWidget(pdfResult: _pdfResult!),
//           if (firstPageResult != null) ...[
//             const SizedBox(height: 16),
//             AnalysisResultsWidget(result: firstPageResult),
//           ],
//           const SizedBox(height: 16),
//           VerdictWidget(
//             verdict: _pdfResult!.verdict,
//             reasons: _pdfResult!.reasons,
//             onAction: _onVerdictAction,
//           ),
//         ],
//       );
//     }

//     // Empty state
//     return const EmptyStateWidget();
//   }
// }
