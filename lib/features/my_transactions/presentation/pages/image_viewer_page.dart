import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class ImageViewerPage extends StatelessWidget {
  final String fileUrl;
  final String title;

  const ImageViewerPage({
    super.key,
    required this.fileUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTextStyles.titleMedium
              .copyWith(fontWeight: AppTextStyles.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              fileUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    color: AppColors.forest,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image,
                          color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'عذراً، فشل تحميل الصورة',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الصورة غير موجودة أو تالفة.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
