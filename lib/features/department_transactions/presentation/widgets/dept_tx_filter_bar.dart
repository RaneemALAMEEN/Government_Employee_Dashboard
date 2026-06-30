import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';

class DeptTxFilterBar extends StatefulWidget {
  final String activeStatusFilter;
  final String activeClassificationFilter;
  final String searchQuery;
  final ValueChanged<String> onStatusFilterChanged;
  final ValueChanged<String> onClassificationFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const DeptTxFilterBar({
    super.key,
    required this.activeStatusFilter,
    required this.activeClassificationFilter,
    required this.searchQuery,
    required this.onStatusFilterChanged,
    required this.onClassificationFilterChanged,
    required this.onSearchChanged,
  });

  @override
  State<DeptTxFilterBar> createState() => _DeptTxFilterBarState();
}

class _DeptTxFilterBarState extends State<DeptTxFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant DeptTxFilterBar oldWidget) {
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
    final statuses = ['الكل', 'قيد الانتظار', 'قيد المعالجة', 'منجزة', 'مرفوضة'];
    final classifications = [
      'الكل',
      'الموارد البشرية',
      'التعليم الأساسي',
      'الأبنية والصيانة',
      'الشؤون الإدارية',
      'التعليم الثانوي',
      'التخطيط'
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 950;

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
                hintText: 'بحث برقم المعاملة، النوع، أو اسم المسؤول...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.charcoal.withOpacity(0.6)),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.charcoal),
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

        final classificationDropdown = Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold.withOpacity(0.25)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.activeClassificationFilter,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.forest, size: 20),
              style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoalDark),
              onChanged: (val) {
                if (val != null) {
                  widget.onClassificationFilterChanged(val);
                }
              },
              items: classifications.map((cls) {
                return DropdownMenuItem<String>(
                  value: cls,
                  child: Text(cls),
                );
              }).toList(),
            ),
          ),
        );

        final statusChips = Row(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            final isSelected = status == widget.activeStatusFilter;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(
                  status,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : AppColors.charcoalDark),
                ),
                selected: isSelected,
                selectedColor: AppColors.forest,
                backgroundColor: AppColors.goldLight.withOpacity(0.4),
                checkmarkColor: Colors.white,
                showCheckmark: false,
                onSelected: (selected) {
                  if (selected) {
                    widget.onStatusFilterChanged(status);
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

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              searchBox,
              const SizedBox(height: 12),
              Row(
                children: [
                  classificationDropdown,
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: statusChips,
              ),
            ],
          );
        }

        return Row(
          children: [
            searchBox,
            const SizedBox(width: 12),
            classificationDropdown,
            const Spacer(),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: statusChips,
            ),
          ],
        );
      },
    );
  }
}
