import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        textDirection: TextDirection.ltr,
        children: const [
          _UserInfo(),
          Spacer(),
          _NotificationButton(),
          SizedBox(width: 14),
          _SearchBox(),
        ],
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
        const Icon(Icons.keyboard_arrow_down, size: 22),
        const SizedBox(width: 14),
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.forest,
          child: Icon(Icons.person_outline, color: AppColors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'محمد العمر',
              style: TextStyle(
                fontSize: 14,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoalDark,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'رئيس الدائرة',
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w400,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
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
            prefixIcon: const Icon(Icons.search, size: 20),
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
      child: const Icon(Icons.notifications_none, color: AppColors.forest),
    );
  }
}