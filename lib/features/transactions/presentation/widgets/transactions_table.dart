import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionsTable extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const TransactionsTable({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useHorizontalScroll = constraints.maxWidth < 1050;
        final tableWidth = useHorizontalScroll ? 1050.0 : constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: tableWidth,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const _TableHeader(),
                  ...transactions.map(
                    (transaction) => _TransactionRow(transaction: transaction),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: AppColors.goldLight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderCell('رقم المعاملة', flex: 14),
          _HeaderCell('النوع', flex: 13),
          _HeaderCell('مقدم الطلب', flex: 14),
          _HeaderCell('الدائرة', flex: 14),
          _HeaderCell('التاريخ', flex: 11),
          _HeaderCell('الأولوية', flex: 10),
          _HeaderCell('الحالة', flex: 12),
          _HeaderCell('إجراء', flex: 12),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionRow({
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.charcoal.withOpacity(0.08)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            flex: 14,
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (transaction.isUrgent) ...[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.umber,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                ],
                Flexible(
                  child: Text(
                    transaction.id,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
                  ),
                ),
              ],
            ),
          ),
          _BodyCell(transaction.type, flex: 13),
          _BodyCell(
            transaction.applicant,
            flex: 14,
            color: AppColors.charcoalDark,
            fontWeight: FontWeight.w600,
          ),
          _BodyCell(transaction.department,
              flex: 14, color: AppColors.goldDark),
          _BodyCell(transaction.date, flex: 11, color: AppColors.goldDark),
          Expanded(
            flex: 10,
            child: Center(
              child: _Badge(
                text: transaction.priority,
                background: _priorityBackground(transaction.priority),
                color: _priorityColor(transaction.priority),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Center(
              child: _Badge(
                text: transaction.status,
                background: _statusBackground(transaction.status),
                color: _statusColor(transaction.status),
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (transaction.needsSignature) ...[
                      _SignButton(onTap: () {}),
                      const SizedBox(width: 6),
                    ],
                    _SmallIconButton(
                      icon: Icons.visibility_outlined,
                      onTap: () {},
                    ),
                    if (transaction.needsSignature) ...[
                      const SizedBox(width: 6),
                      _SmallIconButton(
                        icon: Icons.close,
                        color: AppColors.umber,
                        background: AppColors.umber.withOpacity(0.08),
                        onTap: () {},
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityBackground(String value) {
    switch (value) {
      case 'عالية':
        return AppColors.umber.withOpacity(0.08);
      case 'منخفضة':
        return AppColors.forestLight.withOpacity(0.10);
      default:
        return AppColors.gold.withOpacity(0.12);
    }
  }

  Color _priorityColor(String value) {
    switch (value) {
      case 'عالية':
        return AppColors.umber;
      case 'منخفضة':
        return AppColors.forest;
      default:
        return AppColors.goldDark;
    }
  }

  Color _statusBackground(String value) {
    switch (value) {
      case 'بانتظار توقيعي':
        return AppColors.forestLight.withOpacity(0.10);
      case 'منجزة':
        return AppColors.forestLight.withOpacity(0.14);
      case 'تم الرفض':
        return AppColors.umber.withOpacity(0.08);
      default:
        return AppColors.gold.withOpacity(0.12);
    }
  }

  Color _statusColor(String value) {
    switch (value) {
      case 'تم الرفض':
        return AppColors.umber;
      default:
        return AppColors.forest;
    }
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderCell(
    this.text, {
    required this.flex,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.bold),
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final FontWeight fontWeight;

  const _BodyCell(
    this.text, {
    required this.flex,
    this.color,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodySmall.copyWith(fontWeight: fontWeight, color: color ?? AppColors.charcoal),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color background;
  final Color color;

  const _Badge({
    required this.text,
    required this.background,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      constraints: const BoxConstraints(
        minWidth: 58,
        maxWidth: 120,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: color),
      ),
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  const _SmallIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.forest,
    this.background = const Color(0xFFEDEBE0),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 16,
        ),
      ),
    );
  }
}

class _SignButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.edit_square,
              size: 14,
              color: AppColors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'توقيع',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.white, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}
