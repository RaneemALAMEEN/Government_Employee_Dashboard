import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// زر رجوع موحد لكامل صفحات النظام بتصميم نظيف، أنيق وتفاعلي
class AppBackButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.label = 'العودة',
    this.icon = LucideIcons.arrowRight,
  });

  @override
  State<AppBackButton> createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  bool _isHovered = false;

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.goldLight.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                widget.icon,
                color: _isHovered ? AppColors.forest : AppColors.charcoal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: _isHovered
                      ? AppColors.forest
                      : AppColors.charcoal.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
