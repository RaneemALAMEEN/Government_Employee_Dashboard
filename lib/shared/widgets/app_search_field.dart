import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// حقل بحث موحد لكامل صفحات النظام يطابق حقل البحث في صفحة معاملات الدائرة:
/// - ارتفاع 42 بكسل وحواف دائرية 8 بكسل
/// - حدود ذهبية ناعمة وحد تركيز بلون الغابة
/// - أيقونة بحث واضحة وأيقونة مسح تفاعلية
class AppSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool isLoading;
  final double? width;
  final double height;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? suffixIcon;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'بحث...',
    this.isLoading = false,
    this.width,
    this.height = 42,
    this.autofocus = false,
    this.focusNode,
    this.suffixIcon,
  });

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _internalController;
  bool _isInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
      _isInternal = true;
    } else {
      _internalController = widget.controller!;
    }
  }

  @override
  void didUpdateWidget(covariant AppSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _internalController) {
      if (_isInternal) {
        _internalController.dispose();
        _isInternal = false;
      }
      _internalController = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_isInternal) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _internalController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final searchInput = SizedBox(
      width: widget.width,
      height: widget.height,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _internalController,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          onChanged: (val) {
            setState(() {});
            widget.onChanged?.call(val);
          },
          onSubmitted: widget.onSubmitted,
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.charcoalDark,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.6),
            ),
            prefixIcon: widget.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.forest,
                      ),
                    ),
                  )
                : const Icon(
                    LucideIcons.search,
                    size: 18,
                    color: AppColors.charcoal,
                  ),
            suffixIcon: widget.suffixIcon ??
                (_internalController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          size: 16,
                          color: AppColors.charcoal,
                        ),
                        onPressed: _handleClear,
                        tooltip: 'مسح البحث',
                      )
                    : null),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.forest,
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );

    return searchInput;
  }
}
