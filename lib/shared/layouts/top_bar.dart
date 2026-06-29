import '../theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/di/injection.dart';
import '../../core/services/session_service.dart';
import '../theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showSearch = constraints.maxWidth > 500;
          return Row(
            children: [
              if (showSearch) ...[
                const _SearchBox(),
                const SizedBox(width: 14),
              ],
              const _NotificationButton(),
              const Spacer(),
              const _UserInfo(),
            ],
          );
        },
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.forest,
          child: Icon(LucideIcons.user, color: AppColors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'محمد العمر',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark, height: 1.1),
            ),
            SizedBox(height: 4),
            ValueListenableBuilder<String>(
              valueListenable: getIt<SessionService>().activeRoleNotifier,
              builder: (context, activeRole, _) {
                return Text(
                  activeRole,
                  style: AppTextStyles.labelMedium.copyWith(height: 1),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 14),
        const Icon(LucideIcons.chevronDown, size: 20),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 42,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'بحث في المعاملات...',
            prefixIcon: const Icon(LucideIcons.search, size: 18),
            filled: true,
            fillColor: AppColors.goldLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.45)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.45)),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.forestLight.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(LucideIcons.bell, color: AppColors.forest, size: 20),
    );
  }
}