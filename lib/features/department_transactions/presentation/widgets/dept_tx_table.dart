import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/department_transaction_entity.dart';

class DeptTxTable extends StatefulWidget {
  final List<DepartmentTransactionEntity> transactions;

  const DeptTxTable({
    super.key,
    required this.transactions,
  });

  @override
  State<DeptTxTable> createState() => _DeptTxTableState();
}

class _DeptTxTableState extends State<DeptTxTable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Table header info section
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.white,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  '${widget.transactions.length} معاملة',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.info,
                      size: 16,
                      color: AppColors.charcoal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'للعرض والمتابعة فقط',
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.gold.withOpacity(0.25)),

          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 900;
              final double availableWidth = constraints.maxWidth;

              final Widget tableContent = Column(
                children: [
                  const _TableHeader(),
                  if (widget.transactions.isEmpty)
                    FadeIn(
                      duration: const Duration(milliseconds: 350),
                      child: Container(
                        height: 180,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ZoomIn(
                              duration: const Duration(milliseconds: 400),
                              child: const Icon(
                                LucideIcons.search,
                                size: 56,
                                color: AppColors.goldDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد معاملات تطابق الفلترة',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.medium),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.transactions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: AppColors.gold.withOpacity(0.18),
                      ),
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: index * 45),
                          child: _TransactionRow(tx: widget.transactions[index]),
                        );
                      },
                    ),
                ],
              );

              if (availableWidth < minTableWidth) {
                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: tableContent,
                    ),
                  ),
                );
              } else {
                return tableContent;
              }
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
      height: 46,
      color: AppColors.goldLight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderText('رقم المعاملة', flex: 12),
          _HeaderText('النوع', flex: 16),
          _HeaderText('التصنيف', flex: 14),
          _HeaderText('التاريخ', flex: 12),
          _HeaderText('بين يدي', flex: 18),
          _HeaderText('الحالة', flex: 14),
          _HeaderText('عرض التفاصيل', flex: 20),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final DepartmentTransactionEntity tx;

  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    // Generate avatar background color based on name letter
    final String firstLetter = tx.assignedTo.isNotEmpty ? tx.assignedTo[0] : '';
    final Color avatarBgColor = _getAvatarColor(firstLetter);

    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Transaction Number
            Expanded(
              flex: 12,
              child: Center(
                child: Text(
                  tx.number,
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                ),
              ),
            ),
            // Type
            Expanded(
              flex: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.user,
                    size: 15,
                    color: AppColors.charcoal,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      tx.type,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoalDark),
                    ),
                  ),
                ],
              ),
            ),
            // Classification Badge
            Expanded(
              flex: 14,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forestLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.forest.withOpacity(0.12)),
                  ),
                  child: Text(
                    tx.classification,
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.forest, height: 1),
                  ),
                ),
              ),
            ),
            // Date
            _CellText(tx.date, flex: 12, color: AppColors.charcoal.withOpacity(0.70)),
            // Assigned To ("بين يدي")
            Expanded(
              flex: 18,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: avatarBgColor,
                    child: Text(
                      firstLetter,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      tx.assignedTo,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoalDark),
                    ),
                  ),
                  if (tx.isAssignedToMe) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'أنت',
                        style: AppTextStyles.labelSmall.copyWith(fontSize: 9, fontWeight: AppTextStyles.semiBold, color: AppColors.goldDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Status Badge
            Expanded(
              flex: 14,
              child: Center(child: _StatusBadge(status: tx.status)),
            ),
            // Details Action Button
            Expanded(
              flex: 20,
              child: Center(
                child: Material(
                  color: AppColors.forestLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      // Action details placeholder
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.eye,
                            color: AppColors.forest,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'عرض التفاصيل',
                            style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest, height: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String letter) {
    switch (letter) {
      case 'م':
        return Colors.teal.shade400;
      case 'ح':
        return Colors.orange.shade400;
      case 'ل':
        return Colors.purple.shade400;
      case 'س':
        return Colors.blue.shade400;
      case 'ن':
        return Colors.red.shade400;
      default:
        return AppColors.forest;
    }
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
        style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, height: 1),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;

  const _CellText(
    this.text, {
    required this.flex,
    this.color,
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
        style: AppTextStyles.labelLarge.copyWith(color: color ?? AppColors.charcoalDark, height: 1.25),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'قيد الانتظار':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'قيد المعالجة':
        bg = AppColors.gold.withOpacity(0.14);
        fg = AppColors.goldDark;
        break;
      case 'منجزة':
        bg = AppColors.forestLight.withOpacity(0.12);
        fg = AppColors.forest;
        break;
      default: // مرفوضة
        bg = AppColors.umber.withOpacity(0.08);
        fg = AppColors.umber;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: fg, height: 1),
      ),
    );
  }
}
