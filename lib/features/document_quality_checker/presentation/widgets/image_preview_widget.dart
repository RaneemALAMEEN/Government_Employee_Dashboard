import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

/// Large image preview widget with zoom and fullscreen support.
class ImagePreviewWidget extends StatelessWidget {
  final Uint8List imageBytes;

  const ImagePreviewWidget({super.key, required this.imageBytes});

  void _openFullscreen(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _FullscreenImageViewer(imageBytes: imageBytes),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(LucideIcons.image, size: 16, color: AppColors.forestLight),
                  const SizedBox(width: 6),
                  Text(
                    'معاينة الصورة',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: AppColors.forest.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _openFullscreen(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.maximize, size: 13, color: AppColors.forest),
                            const SizedBox(width: 5),
                            Text(
                              'تكبير',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: AppTextStyles.semiBold,
                                color: AppColors.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image container — clickable for fullscreen
          GestureDetector(
            onTap: () => _openFullscreen(context),
            child: MouseRegion(
              cursor: SystemMouseCursors.zoomIn,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 380),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.20)),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fullscreen Image Viewer ──────────────────────────────────────

class _FullscreenImageViewer extends StatelessWidget {
  final Uint8List imageBytes;

  const _FullscreenImageViewer({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image with zoom
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 16,
          left: 16,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(LucideIcons.x, size: 22, color: Colors.white),
              ),
            ),
          ),
        ),

        // Hint text
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'استخدم العجلة أو اسحب للتكبير والتصغير — اضغط × للإغلاق',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
