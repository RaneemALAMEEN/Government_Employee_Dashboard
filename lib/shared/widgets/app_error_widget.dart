import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_text_styles.dart';

/// ويدجت موحّد لعرض حالة الخطأ (انقطاع الاتصال / فشل التحميل)
/// يُستخدم في جميع صفحات النظام لتوحيد تجربة المستخدم.
class AppErrorWidget extends StatelessWidget {
  /// رسالة الخطأ الرئيسية
  final String message;

  /// دالة إعادة المحاولة
  final VoidCallback onRetry;

  /// عنوان اختياري (يظهر فوق الرسالة)
  final String title;

  /// أيقونة اختيارية (الافتراضي: wifi-off)
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.message = 'لا يتوفّر اتصال بالإنترنت. يُرجى التحقّق من الاتصال.',
    required this.onRetry,
    this.title = 'الاتصال بالإنترنت',
    this.icon = LucideIcons.wifiOff,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeIn(
        duration: const Duration(milliseconds: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.umber.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: AppColors.umber.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.charcoalDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              SizedBox(
                width: 360,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.charcoal.withOpacity(0.65),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Retry button
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
