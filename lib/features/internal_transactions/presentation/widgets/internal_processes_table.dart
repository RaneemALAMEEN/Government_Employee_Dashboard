import 'package:flutter/material.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/services/api_service.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_remote_data_source.dart';
import '../../domain/entities/internal_transaction_entity.dart';

class InternalProcessesTable extends StatefulWidget {
  const InternalProcessesTable({super.key});

  @override
  State<InternalProcessesTable> createState() => _InternalProcessesTableState();
}

class _InternalProcessesTableState extends State<InternalProcessesTable> {
  final _dataSource = InternalTransactionsRemoteDataSource(
    getIt<ApiService>(),
  );

  InternalTransactionsPageData? _pageData;

  bool _loading = true;
  String? _errorMessage;

  int _page = 1;
  static const int _limit = 10;
  static const double _minTableWidth = 1100;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _dataSource.getMyTransactions(
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        _pageData = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.forest),
        ),
      );
    }

    if (_errorMessage != null) {
      return _ErrorBox(message: _errorMessage!);
    }

    final data = _pageData!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tableWidth = constraints.maxWidth < _minTableWidth
              ? _minTableWidth
              : constraints.maxWidth;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _Table(items: data.items),
                  _Pagination(
                    page: data.page,
                    totalPages: data.totalPages,
                    total: data.total,
                    limit: data.limit,
                    hasNext: data.hasNext,
                    hasPrev: data.hasPrev,
                    onPageChanged: _goToPage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final List<InternalTransactionEntity> items;

  const _Table({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TableHeader(),
        if (items.isEmpty)
          const SizedBox(
            height: 72,
            child: Center(
              child: Text(
                'لا توجد معاملات حالياً',
                style: TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        else
          ...items.map((item) => _TransactionRow(item: item)),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: AppColors.goldLight.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderCell('رقم المعاملة', flex: 18, shiftRight: 10),
          _HeaderCell('نوع المعاملة', flex: 25, shiftRight: 10),
          _HeaderCell('المرحلة الحالية', flex: 20, shiftRight: 10),
          _HeaderCell('نسبة الإنجاز', flex: 15, shiftRight: 10),
          _HeaderCell('الحالة', flex: 12, shiftRight: 10),
          _HeaderCell('إجراء', flex: 10, shiftRight: 10),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final InternalTransactionEntity item;

  const _TransactionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.charcoal.withOpacity(0.08)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _BodyCell(
            item.idProcess,
            flex: 18,
            color: AppColors.forest,
            fontWeight: FontWeight.w700,
            shiftRight: 10,
          ),
          _BodyCell(
            item.processDefinitionName,
            flex: 25,
            color: AppColors.charcoalDark,
            fontWeight: FontWeight.w600,
            shiftRight: 10,
          ),
          _BodyCell(
            item.stageName,
            flex: 20,
            color: AppColors.charcoal,
            shiftRight: 10,
          ),
          Expanded(
            flex: 15,
            child: Transform.translate(
              offset: const Offset(10, 0),
              child: _ProgressBadge(percent: item.progressPercent),
            ),
          ),
          Expanded(
            flex: 12,
            child: Transform.translate(
              offset: const Offset(10, 0),
              child: Center(
                child: _StatusBadge(status: item.status),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Transform.translate(
              offset: const Offset(10, 0),
              child: Center(
                child: _DetailsButton(onTap: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final double shiftRight;

  const _HeaderCell(
    this.text, {
    required this.flex,
    this.shiftRight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Transform.translate(
        offset: Offset(shiftRight, 0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.charcoal,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final FontWeight fontWeight;
  final double shiftRight;

  const _BodyCell(
    this.text, {
    required this.flex,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.shiftRight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Transform.translate(
        offset: Offset(shiftRight, 0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color ?? AppColors.charcoal,
            fontSize: 14,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int percent;

  const _ProgressBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 92, maxWidth: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.forestLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$safePercent%',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.forest,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final data = _statusData(status);

    return Container(
      constraints: const BoxConstraints(minWidth: 82, maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: data.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        data.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: data.textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _StatusViewData _statusData(String status) {
    switch (status) {
      case 'draft':
        return const _StatusViewData(
          text: 'مسودة',
          textColor: Color(0xFF5A738E),
          background: Color(0xFFEDF2F7),
        );
      case 'submitted':
        return const _StatusViewData(
          text: 'مقدمة',
          textColor: AppColors.forest,
          background: Color(0xFFEAF3F0),
        );
      case 'in_progress':
        return _StatusViewData(
          text: 'قيد المعالجة',
          textColor: AppColors.goldDark,
          background: AppColors.goldLight.withOpacity(0.45),
        );
      case 'completed':
        return const _StatusViewData(
          text: 'منجزة',
          textColor: Color(0xFF2E7D32),
          background: Color(0xFFE8F5E9),
        );
      case 'rejected':
        return const _StatusViewData(
          text: 'مرفوضة',
          textColor: Color(0xFFC62828),
          background: Color(0xFFFFEBEE),
        );
      case 'cancelled':
        return const _StatusViewData(
          text: 'ملغاة',
          textColor: AppColors.umber,
          background: Color(0xFFF8EDEF),
        );
      default:
        return const _StatusViewData(
          text: 'غير معروف',
          textColor: Color(0xFF5A738E),
          background: Color(0xFFEDF2F7),
        );
    }
  }
}

class _StatusViewData {
  final String text;
  final Color textColor;
  final Color background;

  const _StatusViewData({
    required this.text,
    required this.textColor,
    required this.background,
  });
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minWidth: 104, maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.goldLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 15,
              color: AppColors.charcoal,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'عرض التفاصيل',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.charcoalDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int limit;
  final bool hasNext;
  final bool hasPrev;
  final ValueChanged<int> onPageChanged;

  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
    required this.onPageChanged,
  });
  @override
  Widget build(BuildContext context) {
    if (total == 0) {
      return Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: AppColors.white,
        alignment: Alignment.centerRight,
        child: Text(
          'عرض 0–0 من 0 معاملة',
          style: TextStyle(
            color: AppColors.charcoal.withOpacity(0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final start = ((page - 1) * limit) + 1;
    final end = (page * limit).clamp(0, total);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.white,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(
            'عرض $start–$end من $total معاملة',
            style: TextStyle(
              color: AppColors.charcoal.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          _PageButton(
            icon: Icons.chevron_right,
            enabled: hasPrev,
            onTap: () => onPageChanged(page - 1),
          ),
          const SizedBox(width: 8),
          ...List.generate(
            totalPages,
            (index) {
              final pageNumber = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _NumberButton(
                  number: pageNumber,
                  selected: pageNumber == page,
                  onTap: () => onPageChanged(pageNumber),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _PageButton(
            icon: Icons.chevron_left,
            enabled: hasNext,
            onTap: () => onPageChanged(page + 1),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.gold.withOpacity(0.15)),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.charcoal : AppColors.gold,
          size: 18,
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final int number;
  final bool selected;
  final VoidCallback onTap;

  const _NumberButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: selected ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : AppColors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.charcoal,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.umber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.umber.withOpacity(0.18)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.umber,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
