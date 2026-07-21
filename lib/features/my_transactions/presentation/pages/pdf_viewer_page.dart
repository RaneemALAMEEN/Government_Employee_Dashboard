import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../shared/theme/app_colors.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../shared/widgets/app_error_widget.dart';

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
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _pdfBytes;
  String _errorMessage = 'تعذر تحميل ملف الـ PDF';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        widget.fileUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final bytes = response.data as Uint8List;
        
        // Verify PDF signature to prevent SfPdfViewer from crashing
        // PDF files start with %PDF- (or within the first 1024 bytes)
        bool isValidPdf = false;
        final checkLength = bytes.length > 1024 ? 1024 : bytes.length;
        for (int i = 0; i < checkLength - 4; i++) {
          if (bytes[i] == 37 && // %
              bytes[i + 1] == 80 && // P
              bytes[i + 2] == 68 && // D
              bytes[i + 3] == 70 && // F
              bytes[i + 4] == 45) { // -
            isValidPdf = true;
            break;
          }
        }

        if (isValidPdf) {
          setState(() {
            _pdfBytes = bytes;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'الملف المستلم ليس بتنسيق PDF صالح أو أنه تالف.';
            _hasError = true;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.statusCode == 404 
              ? 'هناك مشكلة في هذا الملف ولا يمكن عرضه أو تنزيله ، يرجى التواصل مع من أرفقه لإعادة إرفاقه مرة أخرى' 
              : 'تعذر تحميل ملف الـ PDF. الملف تالف أو الخادم لا يستجيب.';
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e is DioException && e.response?.statusCode == 404) {
          _errorMessage = 'هناك مشكلة في هذا الملف ولا يمكن عرضه أو تنزيله ، يرجى التواصل مع من أرفقه لإعادة إرفاقه مرة أخرى';
        } else {
          _errorMessage = 'حدث خطأ أثناء الاتصال بالخادم لتحميل الملف.';
        }
        _hasError = true;
        _isLoading = false;
      });
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.forest),
            const SizedBox(height: 16),
            Text('جاري تحميل الملف...', style: AppTextStyles.titleSmall),
          ],
        ),
      );
    }

    if (_hasError || _pdfBytes == null) {
      return AppErrorWidget(
        title: 'عذراً، فشل تحميل الملف',
        message: _errorMessage,
        icon: LucideIcons.fileWarning,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _hasError = false;
          });
          _loadPdf();
        },
      );
    }

    return SfPdfViewer.memory(
      _pdfBytes!,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = 'محتوى الملف تالف أو غير صالح للقراءة كملف PDF.';
            });
          }
        });
      },
    );
  }
}
