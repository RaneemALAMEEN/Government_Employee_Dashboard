import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/usecases/change_pin_usecase.dart';


class ChangePinDialog extends StatefulWidget {
  const ChangePinDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ChangePinDialog(),
    );
  }

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final _oldPinFocus = FocusNode();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _oldPinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _oldPinFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  Future<void> _submitChangePin() async {
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (oldPin.length != 6) {
      setState(() => _errorMessage = 'يرجى إدخال رمز PIN القديم (6 أرقام)');
      return;
    }
    if (newPin.length != 6) {
      setState(() => _errorMessage = 'رمز PIN الجديد يجب أن يتكون من 6 أرقام');
      return;
    }
    if (confirmPin != 6 && confirmPin.length != 6) {
      setState(() => _errorMessage = 'تأكيد رمز PIN الجديد يجب أن يتكون من 6 أرقام');
      return;
    }
    if (newPin != confirmPin) {
      setState(() => _errorMessage = 'رمز PIN الجديد وتأكيده غير متطابقين');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = getIt<ChangePinUseCase>();
    final result = await useCase(
      oldPin: oldPin,
      newPin: newPin,
      confirmNewPin: confirmPin,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (changePinResult) {
        Navigator.of(context).pop();
        final bool usbSuccess = changePinResult.usbUpdated;
        final String message = usbSuccess
            ? 'تم تغيير رمز PIN وتحديث مفتاح التوقيع على فلاشة USB بنجاح'
            : 'تم تغيير رمز PIN بنجاح.\nتنبيه: لم يتم العثور على فلاشة USB لتحديث مفتاح التوقيع عليها';

        AppSnackBar.show(
          context,
          title: usbSuccess ? 'تم التحديث بنجاح' : 'تنبيه',
          message: message,
          isError: !usbSuccess,
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 44,
      height: 48,
      textStyle: const TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 18,
        color: AppColors.charcoal,
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.white,
        border: Border.all(
          color: AppColors.forest,
          width: 1.8,
        ),
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 12,
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.forestLight.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.keyRound,
                      color: AppColors.forest,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تغيير رمز PIN',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'أدخل رمز PIN الحالي والجديد (مع إبقاء فلاشة التوقيع متصلة)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),

                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // Old PIN field
              Text(
                'رمز PIN الحالي',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    controller: _oldPinController,
                    focusNode: _oldPinFocus,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '●',
                    enabled: !_isLoading,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (_) => _newPinFocus.requestFocus(),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // New PIN field
              Text(
                'رمز PIN الجديد',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    controller: _newPinController,
                    focusNode: _newPinFocus,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '●',
                    enabled: !_isLoading,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (_) => _confirmPinFocus.requestFocus(),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Confirm New PIN field
              Text(
                'تأكيد رمز PIN الجديد',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    controller: _confirmPinController,
                    focusNode: _confirmPinFocus,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '●',
                    enabled: !_isLoading,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    onCompleted: (_) => _submitChangePin(),
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitChangePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'حفظ التغييرات',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
    );
  }
}
