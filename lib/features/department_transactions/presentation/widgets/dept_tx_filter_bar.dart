import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../domain/entities/accessible_department_entity.dart';

import 'dept_tx_date_range_picker_dialog.dart';

class DeptTxFilterBar extends StatefulWidget {
  final String activeStatusFilter;
  final String searchQuery;
  final String? fromDate;
  final String? toDate;
  final ValueChanged<String> onStatusFilterChanged;
  final Function(String?, String?) onDateRangeChanged;
  final ValueChanged<String> onSearchChanged;
  final List<AccessibleDepartmentEntity> accessibleDepartments;
  final int? selectedDepartmentId;
  final Function(int departmentId, String departmentName)? onDepartmentChanged;

  const DeptTxFilterBar({
    super.key,
    required this.activeStatusFilter,
    required this.searchQuery,
    this.fromDate,
    this.toDate,
    required this.onStatusFilterChanged,
    required this.onDateRangeChanged,
    required this.onSearchChanged,
    this.accessibleDepartments = const [],
    this.selectedDepartmentId,
    this.onDepartmentChanged,
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
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    await DeptTxDateRangePickerDialog.show(
      context: context,
      initialFromDate: widget.fromDate,
      initialToDate: widget.toDate,
      onApply: (fromStr, toStr) {
        widget.onDateRangeChanged(fromStr, toStr);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ['منجزة', 'مرفوضة'];
    final hasDateFilter = widget.fromDate != null || widget.toDate != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 950;

        final searchBox = AppSearchField(
          controller: _searchController,
          width: isNarrow ? double.infinity : 320,
          hintText: 'بحث برقم المعاملة، النوع، أو اسم المسؤول...',
          onChanged: widget.onSearchChanged,
        );

        final datePickerButton = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectDateRange(context),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: hasDateFilter ? AppColors.forest : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasDateFilter
                      ? AppColors.forestDark
                      : AppColors.gold.withOpacity(0.25),
                  width: hasDateFilter ? 1.2 : 1.0,
                ),
                boxShadow: hasDateFilter
                    ? [
                        BoxShadow(
                          color: AppColors.forest.withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasDateFilter
                        ? LucideIcons.calendarCheck
                        : LucideIcons.calendar,
                    color: hasDateFilter ? Colors.white : AppColors.forest,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasDateFilter
                        ? '${widget.fromDate} إلى ${widget.toDate}'
                        : 'تحديد الفترة الزمنية',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: hasDateFilter
                          ? FontWeight.w600
                          : AppTextStyles.medium,
                      color:
                          hasDateFilter ? Colors.white : AppColors.charcoalDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final clearDateFilterButton = hasDateFilter
            ? Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'إلغاء فلترة التاريخ والعودة للكل',
                  child: InkWell(
                    onTap: () => widget.onDateRangeChanged(null, null),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.umber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.umber.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.rotateCcw,
                            size: 14,
                            color: AppColors.umber,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'إلغاء الفلترة',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.umber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : null;

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

        // Department dropdown — يظهر فقط إذا كان هناك أكثر من دائرة
        Widget? departmentDropdown;
        if (widget.accessibleDepartments.length > 1) {
          departmentDropdown = Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: widget.selectedDepartmentId,
                isDense: true,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.forest),
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.charcoalDark,
                ),
                hint: Text(
                  'اختر الدائرة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.charcoal.withOpacity(0.6),
                  ),
                ),
                items: widget.accessibleDepartments.map((dept) {
                  return DropdownMenuItem<int>(
                    value: dept.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.building2, size: 14, color: AppColors.forest),
                        const SizedBox(width: 8),
                        Text(
                          dept.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: dept.id == widget.selectedDepartmentId
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppColors.charcoalDark,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && widget.onDepartmentChanged != null) {
                    final dept = widget.accessibleDepartments.firstWhere((d) => d.id == value);
                    widget.onDepartmentChanged!(dept.id, dept.name);
                  }
                },
              ),
            ),
          );
        }

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (departmentDropdown != null) ...[
                departmentDropdown,
                const SizedBox(height: 12),
              ],
              searchBox,
              const SizedBox(height: 12),
              Row(
                children: [
                  datePickerButton,
                  if (clearDateFilterButton != null) ...[
                    const SizedBox(width: 8),
                    clearDateFilterButton,
                  ],
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (departmentDropdown != null) ...[
              Row(
                children: [
                  departmentDropdown,
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                searchBox,
                const SizedBox(width: 12),
                datePickerButton,
                if (clearDateFilterButton != null) ...[
                  const SizedBox(width: 8),
                  clearDateFilterButton,
                ],
                const Spacer(),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: statusChips,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
