import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';

class AppointmentImagePreview extends StatefulWidget {
  final ImageProvider imageProvider;
  final double height;
  final BorderRadius borderRadius;

  const AppointmentImagePreview({
    super.key,
    required this.imageProvider,
    this.height = 155,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  State<AppointmentImagePreview> createState() =>
      _AppointmentImagePreviewState();
}

class _AppointmentImagePreviewState extends State<AppointmentImagePreview> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Tooltip(
          message: 'عرض الصورة',
          child: Semantics(
            button: true,
            label: 'عرض صورة الهوية بالحجم الكامل',
            child: GestureDetector(
              onTap: () => showFullscreenImageViewer(
                context,
                imageProvider: widget.imageProvider,
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius,
                child: SizedBox(
                  width: double.infinity,
                  height: widget.height,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetworkAwareImage(
                        imageProvider: widget.imageProvider,
                        fit: BoxFit.cover,
                        borderRadius: widget.borderRadius,
                      ),
                      AnimatedOpacity(
                        opacity: _hovered ? 1 : 0,
                        duration: const Duration(milliseconds: 190),
                        child: ColoredBox(
                          color: Colors.black.withValues(alpha: .28),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: .5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.maximize2,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'عرض بالحجم الكامل',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

Future<void> showFullscreenImageViewer(
  BuildContext context, {
  required ImageProvider imageProvider,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق معاينة الصورة',
    barrierColor: Colors.black.withValues(alpha: .88),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, _, __) => _FullscreenImageViewer(
      imageProvider: imageProvider,
    ),
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .97, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _FullscreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;
  const _FullscreenImageViewer({required this.imageProvider});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(context).pop(),
          },
          child: Focus(
            autofocus: true,
            child: Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: FractionallySizedBox(
                        widthFactor: .88,
                        heightFactor: .88,
                        child: _NetworkAwareImage(
                          imageProvider: imageProvider,
                          fit: BoxFit.contain,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 22,
                    end: 24,
                    child: Tooltip(
                      message: 'إغلاق',
                      child: IconButton.filled(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: .55),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(46, 46),
                        ),
                        icon: const Icon(LucideIcons.x, size: 23),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _NetworkAwareImage extends StatelessWidget {
  final ImageProvider imageProvider;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const _NetworkAwareImage({
    required this.imageProvider,
    required this.fit,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => Image(
        image: imageProvider,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return CustomSkeletonLoader(
            width: double.infinity,
            height: double.infinity,
            borderRadius: borderRadius.topLeft.x,
          );
        },
        errorBuilder: (_, __, ___) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F3),
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.imageOff,
                size: 34,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 10),
              Text(
                'تعذر تحميل صورة الهوية',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
}
