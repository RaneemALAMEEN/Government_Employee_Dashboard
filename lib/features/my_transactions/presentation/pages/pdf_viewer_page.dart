import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../shared/theme/app_colors.dart';

class PdfViewerPage extends StatelessWidget {
  final String fileUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.forest,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SfPdfViewer.network(
        fileUrl,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
