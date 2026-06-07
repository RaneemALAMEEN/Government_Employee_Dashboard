import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';

class LatestTransactionsTable extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const LatestTransactionsTable({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          SizedBox(
            height: 62,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                textDirection: TextDirection.rtl,
                children: const [
                  Text(
                    'آخر المعاملات',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forest,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'عرض الكل ‹',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1,
                      fontWeight: FontWeight.w500,
                      color: AppColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 1, color: AppColors.gold.withOpacity(0.25)),
          const _TableHeader(),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => Container(
              height: 1,
              color: AppColors.gold.withOpacity(0.18),
            ),
            itemBuilder: (context, index) {
              return _TransactionRow(tx: transactions[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      color: AppColors.goldLight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderText('رقم المعاملة', flex: 16),
          _HeaderText('النوع', flex: 16),
          _HeaderText('مقدم الطلب', flex: 18),
          _HeaderText('التاريخ', flex: 14),
          _HeaderText('الحالة', flex: 14),
          _HeaderText('إجراء', flex: 12),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionEntity tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            _CellText(
              tx.number,
              flex: 16,
              color: AppColors.forest,
              fontWeight: FontWeight.w600,
            ),
            _CellText(tx.type, flex: 16),
            _CellText(tx.applicant, flex: 18),
            _CellText(tx.date, flex: 14, color: AppColors.charcoal.withOpacity(0.70)),
            Expanded(
              flex: 14,
              child: Center(child: _StatusBadge(status: tx.status)),
            ),
            Expanded(
              flex: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIcon(
                    icon: Icons.visibility_outlined,
                    tooltip: 'عرض التفاصيل',
                    onTap: () {},
                  ),
                  if (tx.canSign) ...[
                    const SizedBox(width: 6),
                    _ActionIcon(
                      icon: Icons.edit_square,
                      tooltip: 'توقيع المعاملة',
                      onTap: () {},
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderText(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final FontWeight fontWeight;

  const _CellText(
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          height: 1.25,
          fontWeight: fontWeight,
          color: color ?? AppColors.charcoalDark,
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
    final bg = _backgroundColor(status);
    final fg = _textColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }

  Color _backgroundColor(String status) {
    switch (status) {
      case 'مستعجل':
      case 'مرفوض':
        return AppColors.umber.withOpacity(0.08);
      case 'منجز':
        return AppColors.forestLight.withOpacity(0.12);
      default:
        return AppColors.gold.withOpacity(0.14);
    }
  }

  Color _textColor(String status) {
    switch (status) {
      case 'مستعجل':
      case 'مرفوض':
        return AppColors.umber;
      case 'منجز':
        return AppColors.forest;
      default:
        return AppColors.goldDark;
    }
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: AppColors.forestLight.withOpacity(0.10),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.forest,
          ),
        ),
      ),
    );
  }
}