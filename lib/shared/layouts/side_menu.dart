import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _MenuItem(Icons.home_outlined, 'الرئيسية', true),
      _MenuItem(Icons.description_outlined, 'المعاملات', false),
      _MenuItem(Icons.people_outline, 'الموظفين', false),
      _MenuItem(Icons.chat_bubble_outline, 'الشكاوى', false),
      _MenuItem(Icons.account_tree_outlined, 'إعداد سير العمل', false),
    ];

    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          const SizedBox(height: 27),
          const Text(
            'مديرية التربية',
            style: TextStyle(
              fontSize: 20,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: AppColors.forest,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'ريف دمشق',
            style: TextStyle(
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w400,
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.forestLight.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'رئيس الدائرة',
              style: TextStyle(
                fontSize: 10,
                height: 1,
                color: AppColors.forest,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 39),
          ...items.map((item) => _SideMenuTile(item: item)),
          const Spacer(),
          Container(height: 1, color: AppColors.charcoal.withOpacity(0.18)),
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(Icons.logout, color: AppColors.umber, size: 22),
                SizedBox(width: 12),
                Text(
                  'تغيير الدور',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1,
                    color: AppColors.umber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  final _MenuItem item;

  const _SideMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 49,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: item.isSelected ? AppColors.goldLight : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            item.icon,
            size: 22,
            color: item.isSelected ? AppColors.forest : AppColors.charcoal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: 15,
                height: 1,
                fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: item.isSelected ? AppColors.forest : AppColors.charcoalDark,
              ),
            ),
          ),
          if (item.isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.forest,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final bool isSelected;

  const _MenuItem(this.icon, this.title, this.isSelected);
}