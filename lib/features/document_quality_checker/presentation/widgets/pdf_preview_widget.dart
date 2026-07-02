// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:animate_do/animate_do.dart';
// import 'package:lucide_flutter/lucide_flutter.dart';
// import 'package:pdfx/pdfx.dart';

// import '../../../../shared/theme/app_colors.dart';
// import '../../../../shared/theme/app_text_styles.dart';

// /// PDF preview with page navigation and thumbnail-style display.
// class PdfPreviewWidget extends StatefulWidget {
//   final Uint8List pdfBytes;
//   final int totalPages;
//   final int analyzedPages;

//   const PdfPreviewWidget({
//     super.key,
//     required this.pdfBytes,
//     required this.totalPages,
//     required this.analyzedPages,
//   });
// // 
//   @override
//   State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
// }

// class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
//   late PdfController _controller;
//   int _currentPage = 1;

//   @override
//   void initState() {
//     super.initState();
//     _controller = PdfController(
//       document: PdfDocument.openData(widget.pdfBytes),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeIn(
//       duration: const Duration(milliseconds: 400),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: AppColors.gold.withOpacity(0.20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // PDF Viewer
//             SizedBox(
//               height: 340,
//               child: ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(top: Radius.circular(11)),
//                 child: PdfView(
//                   controller: _controller,
//                   onPageChanged: (page) {
//                     setState(() => _currentPage = page);
//                   },
//                 ),
//               ),
//             ),

//             // Navigation bar
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: AppColors.goldLight.withOpacity(0.5),
//                 borderRadius:
//                     const BorderRadius.vertical(bottom: Radius.circular(11)),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _NavButton(
//                         icon: LucideIcons.chevronRight,
//                         onTap: _currentPage > 1
//                             ? () {
//                                 _controller.previousPage(
//                                   duration: const Duration(milliseconds: 250),
//                                   curve: Curves.easeOut,
//                                 );
//                               }
//                             : null,
//                       ),
//                       const SizedBox(width: 12),
//                       Text(
//                         'صفحة $_currentPage / ${widget.totalPages}',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           fontWeight: AppTextStyles.semiBold,
//                           color: AppColors.charcoalDark,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       _NavButton(
//                         icon: LucideIcons.chevronLeft,
//                         onTap: _currentPage < widget.totalPages
//                             ? () {
//                                 _controller.nextPage(
//                                   duration: const Duration(milliseconds: 250),
//                                   curve: Curves.easeOut,
//                                 );
//                               }
//                             : null,
//                       ),
//                     ],
//                   ),
//                   if (widget.totalPages > widget.analyzedPages) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: AppColors.goldDark.withOpacity(0.10),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         'يتم تحليل أول ${widget.analyzedPages} صفحات فقط',
//                         style: AppTextStyles.labelSmall.copyWith(
//                           color: AppColors.goldDark,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NavButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;

//   const _NavButton({required this.icon, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final enabled = onTap != null;
//     return Material(
//       color: enabled ? AppColors.forest.withOpacity(0.10) : Colors.transparent,
//       borderRadius: BorderRadius.circular(6),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(6),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(6),
//           child: Icon(
//             icon,
//             size: 18,
//             color: enabled
//                 ? AppColors.forest
//                 : AppColors.charcoal.withOpacity(0.3),
//           ),
//         ),
//       ),
//     );
//   }
// }
