import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../shared/theme/app_colors.dart';

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
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.forest,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isReady
          ? SfPdfViewer.network(
              widget.fileUrl,
              canShowScrollHead: false,
              canShowScrollStatus: false,
            )
          : const Center(
              child: CircularProgressIndicator(
                color: AppColors.forest,
              ),
            ),
    );
  }
}
