import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';

class MyTxFilterBar extends StatefulWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final String searchQuery;

  const MyTxFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.searchQuery,
  });

  @override
  State<MyTxFilterBar> createState() => _MyTxFilterBarState();
}

class _MyTxFilterBarState extends State<MyTxFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant MyTxFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['الكل', 'بانتظار الاستلام', 'قيد التنفيذ', 'منجزة', 'تم الرفض'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 750;

        final filterChips = Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: filters.map((filter) {
            final isSelected = filter == widget.activeFilter;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  filter,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : AppColors.charcoalDark),
                ),
                selected: isSelected,
                selectedColor: AppColors.forest,
                backgroundColor: AppColors.goldLight.withOpacity(0.4),
                checkmarkColor: Colors.white,
                showCheckmark: false,
                onSelected: (selected) {
                  if (selected) {
                    widget.onFilterChanged(filter);
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? AppColors.forest : AppColors.gold.withOpacity(0.2),
                  ),
                ),
              ),
            );
          }).toList(),
        );

        final searchBox = SizedBox(
          width: isNarrow ? double.infinity : 320,
          height: 42,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'بحث برقم المعاملة أو الاسم أو النوع...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal.withOpacity(0.6)),
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.charcoal),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.forest),
                ),
              ),
            ),
          ),
        );

        return isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  searchBox,
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: filterChips,
                  ),
                ],
              )
            : Row(
                textDirection: TextDirection.rtl,
                children: [
                  searchBox,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: filterChips,
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
