import '../../../../shared/theme/app_text_styles.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/internal_transaction_entity.dart';
import '../bloc/internal_transactions_bloc.dart';
import '../bloc/internal_transactions_event.dart';
import '../bloc/internal_transactions_state.dart';

class InternalProcessesTable extends StatelessWidget {
  const InternalProcessesTable({super.key});

  static const double _minTableWidth = 1100;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternalTransactionsBloc, InternalTransactionsState>(
      builder: (context, state) {
        if (state.loadingTransactions) {
          return const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            ),
          );
        }

        if (state.errorMessage != null && state.transactionsPageData == null) {
          return _ErrorBox(message: state.errorMessage!);
        }

        final data = state.transactionsPageData;

        if (data == null) {
          return const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
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
                        onPageChanged: (page) {
                          context.read<InternalTransactionsBloc>().add(
                                LoadInternalTransactionsPage(page: page),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
          SizedBox(
            height: 72,
            child: Center(
              child: Text(
                'لا توجد معاملات حالياً',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.goldDark,
                ),
              ),
            ),
          )
        else
          ...items.asMap().entries.map(
                (entry) => FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  delay: Duration(milliseconds: (entry.key % 10) * 50),
                  child: _TransactionRow(item: entry.value),
                ),
              ),
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
      color: AppColors.goldLight.withValues(alpha: 0.4),
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
          bottom: BorderSide(
            color: AppColors.charcoal.withValues(alpha: 0.08),
          ),
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
                child: _DetailsButton(
                  onTap: () {
                    context.go(
                      '/internal-transactions/${item.transactionId}/first-stage',
                    );
                  },
                ),
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
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: AppTextStyles.bold,
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
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: fontWeight,
            color: color ?? AppColors.charcoal,
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
          color: AppColors.forestLight.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$safePercent%',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: AppTextStyles.bold,
            color: AppColors.forest,
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
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: AppTextStyles.semiBold,
          color: data.textColor,
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
          background: AppColors.goldLight.withValues(alpha: 0.45),
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
          color: AppColors.goldLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 15,
              color: AppColors.charcoal,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'عرض التفاصيل',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.charcoalDark,
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
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal.withValues(alpha: 0.6),
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.6),
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
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
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
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: AppTextStyles.bold,
            color: selected ? AppColors.white : AppColors.charcoal,
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
        color: AppColors.umber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.umber.withValues(alpha: 0.18)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.right,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: AppTextStyles.semiBold,
          color: AppColors.umber,
        ),
      ),
    );
  }
}
