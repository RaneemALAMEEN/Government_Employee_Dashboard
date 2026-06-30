import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

class TransactionsFilters extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const TransactionsFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const filters = [
    'الكل',
    'بانتظار توقيعي',
    'منجزة',
    'تم الرفض',
  ];

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 1000;

    final searchField = const _SearchField();
    final filtersBar = _FiltersBar(
      selectedFilter: selectedFilter,
      onFilterChanged: onFilterChanged,
    );

    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          const SizedBox(height: 14),
          filtersBar,
        ],
      );
    }

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(child: searchField),
        const SizedBox(width: 24),
        filtersBar,
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        textAlign: TextAlign.right,
        style: AppTextStyles.titleMedium,
        decoration: InputDecoration(
          hintText: 'بحث برقم المعاملة أو الاسم أو النوع...',
          hintStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.goldDark),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.goldDark,
            size: 25,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
          ),
        ),
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FiltersBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 700;

    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Row(
          textDirection: TextDirection.rtl,
          children: TransactionsFilters.filters.map((filter) {
            final isSelected = selectedFilter == filter;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => onFilterChanged(filter),
                child: Container(
                  height: 42,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 14 : 20,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.forest : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    filter,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? AppTextStyles.bold : AppTextStyles.medium,
                      color: isSelected ? Colors.white : AppColors.charcoalDark,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}