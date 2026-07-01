import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';

class DeptTxFilterBar extends StatefulWidget {
  final String activeStatusFilter;
  final String searchQuery;
  final String? fromDate;
  final String? toDate;
  final ValueChanged<String> onStatusFilterChanged;
  final Function(String?, String?) onDateRangeChanged;
  final ValueChanged<String> onSearchChanged;

  const DeptTxFilterBar({
    super.key,
    required this.activeStatusFilter,
    required this.searchQuery,
    this.fromDate,
    this.toDate,
    required this.onStatusFilterChanged,
    required this.onDateRangeChanged,
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

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = DateTimeRange(
      start: widget.fromDate != null ? DateTime.tryParse(widget.fromDate!) ?? DateTime.now().subtract(const Duration(days: 30)) : DateTime.now().subtract(const Duration(days: 30)),
      end: widget.toDate != null ? DateTime.tryParse(widget.toDate!) ?? DateTime.now() : DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forest,
              onPrimary: Colors.white,
              onSurface: AppColors.charcoalDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final fromStr = "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}";
      final toStr = "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}";
      widget.onDateRangeChanged(fromStr, toStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statuses = ['منجزة', 'مرفوضة'];

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

        final datePickerButton = InkWell(
          onTap: () => _selectDateRange(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.calendar, color: AppColors.forest, size: 18),
                const SizedBox(width: 8),
                Text(
                  (widget.fromDate != null && widget.toDate != null) 
                    ? '${widget.fromDate} إلى ${widget.toDate}'
                    : 'تحديد الفترة الزمنية',
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoalDark),
                ),
                if (widget.fromDate != null || widget.toDate != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => widget.onDateRangeChanged(null, null),
                    child: const Icon(LucideIcons.x, size: 16, color: Colors.grey),
                  ),
                ],
              ],
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
                  datePickerButton,
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
            datePickerButton,
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
