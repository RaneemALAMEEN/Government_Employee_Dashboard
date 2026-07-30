import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class RejectTransactionDialog extends StatefulWidget {
  const RejectTransactionDialog({super.key});

  @override
  State<RejectTransactionDialog> createState() =>
      _RejectTransactionDialogState();
}

class _RejectTransactionDialogState extends State<RejectTransactionDialog> {
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_noteController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header icon & title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.umber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.xCircle,
                        color: AppColors.umber,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'رفض المعاملة',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.charcoal,
                              fontWeight: AppTextStyles.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'يرجى كتابة سبب رفض المعاملة لإعلام صاحب الطلب',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.charcoal.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Reason input field
                Text(
                  'سبب الرفض (إجباري)',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: AppTextStyles.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  minLines: 3,
                  autofocus: true,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب سبب رفض هذه المعاملة بالتفصيل هنا...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.charcoal.withOpacity(0.35),
                    ),
                    filled: true,
                    fillColor: AppColors.goldLight.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.charcoal.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.charcoal.withOpacity(0.15),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.umber,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.red,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'سبب الرفض مطلوب ولا يمكن إكمال عملية الرفض بدون كتابته';
                    }
                    if (value.trim().length < 3) {
                      return 'يرجى كتابة سبب رفض أكثر توضيحاً (3 أحرف على الأقل)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.charcoal.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(LucideIcons.xCircle, size: 18),
                        label: const Text('تأكيد الرفض'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.umber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
