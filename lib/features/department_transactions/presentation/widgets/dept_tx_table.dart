import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/department_transaction_entity.dart';

class DeptTxTable extends StatefulWidget {
  final List<DepartmentTransactionEntity> transactions;
  final bool isSearching;
  final String searchQuery;
  final String activeFilter;

  const DeptTxTable({
    super.key,
    required this.transactions,
    this.isSearching = false,
    this.searchQuery = '',
    this.activeFilter = 'الكل',
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
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.06),
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
                if (widget.isSearching) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.forest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'جاري البحث...',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.forest,
                      fontWeight: AppTextStyles.medium,
                    ),
                  ),
                ],
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
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: AppTextStyles.medium,
                        color: AppColors.charcoal.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.isSearching)
            const SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                color: AppColors.forest,
                backgroundColor: AppColors.goldLight,
              ),
            )
          else
            Container(height: 1, color: AppColors.gold.withValues(alpha: 0.25)),

          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 650;
              final double availableWidth = constraints.maxWidth;

              final Widget tableContent = Column(
                children: [
                  const _TableHeader(),
                  if (widget.transactions.isEmpty)
                    _buildEmptyState(widget.activeFilter)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.transactions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: (index % 10) * 45),
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

  Widget _buildEmptyState(String filter) {
    String svgPath;
    String title;
    String description;

    if (widget.searchQuery.isNotEmpty) {
      svgPath = 'assets/vectors/empty search.svg';
      title = 'لا توجد نتائج تطابق بحثك';
      description = 'تأكد من كتابة الاسم أو رقم المعاملة بشكل صحيح وحاول مرة أخرى.';
    } else {
      switch (filter) {
        case 'بانتظار الاستلام':
        case 'pending_pickup':
        case 'pending':
          svgPath = 'assets/vectors/waiting.svg';
          title = 'لا توجد معاملات بانتظار الاستلام';
          description = 'جميع المعاملات الواردة تم استلامها للبدء بالعمل عليها.';
          break;
        case 'قيد التنفيذ':
        case 'قيد المعالجة':
        case 'in_progress':
          svgPath = 'assets/vectors/in progress.svg';
          title = 'لا توجد معاملات قيد التنفيذ';
          description = 'لا توجد معاملات قيد الإجراء حالياً ضمن هذه الدائرة.';
          break;
        case 'منجزة':
        case 'منجز':
        case 'completed':
          svgPath = 'assets/vectors/approved.svg';
          title = 'لا توجد معاملات منجزة';
          description = 'لم تقم بإنجاز أي معاملات خلال الفترة الحالية.';
          break;
        case 'مرفوضة':
        case 'تم الرفض':
        case 'مرفوض':
        case 'rejected':
          svgPath = 'assets/vectors/rejected.svg';
          title = 'لا توجد معاملات مرفوضة';
          description = 'سجلك خالي من أي معاملات مرفوضة.';
          break;
        default:
          svgPath = 'assets/vectors/waiting.svg';
          title = 'لا توجد معاملات متوفرة';
          description = 'قائمتك فارغة تماماً ولا تحتوي على أي معاملات.';
      }
    }

    return FadeIn(
      duration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        alignment: Alignment.center,
        child: ZoomIn(
          duration: const Duration(milliseconds: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 380,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal.withValues(alpha: 0.65),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          _HeaderText('رقم المعاملة', flex: 13),
          _HeaderText('النوع', flex: 15),
          _HeaderText('الدائرة', flex: 14),
          _HeaderText('التاريخ', flex: 12),
          _HeaderText('مقدم الطلب', flex: 18),
          _HeaderText('الحالة', flex: 13),
          _HeaderText('إجراء', flex: 15),
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
    final firstLetter =
        tx.applicantName.isNotEmpty ? tx.applicantName.characters.first : 'م';
    final avatarBgColor = _getAvatarColor(firstLetter);

    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Transaction Number
            Expanded(
              flex: 13,
              child: Center(
                child: Tooltip(
                  message: tx.transactionNumber,
                  waitDuration: const Duration(milliseconds: 250),
                  child: Text(
                    tx.transactionNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ),
            ),
            // Type
            Expanded(
              flex: 15,
              child: Tooltip(
                message: tx.type,
                waitDuration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.fileText,
                      size: 15,
                      color: AppColors.charcoal,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tx.type,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoalDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Department Badge
            Expanded(
              flex: 14,
              child: Center(
                child: Tooltip(
                  message: tx.department,
                  waitDuration: const Duration(milliseconds: 250),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forestLight.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.forest.withValues(alpha: 0.12)),
                    ),
                    child: Text(
                      tx.department,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: AppTextStyles.medium,
                        color: AppColors.forest,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Date
            _CellText(
              tx.date,
              flex: 12,
              color: AppColors.charcoal.withValues(alpha: 0.70),
            ),
            // Applicant Name
            Expanded(
              flex: 18,
              child: Tooltip(
                message: tx.applicantName,
                waitDuration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: avatarBgColor,
                      child: Text(
                        firstLetter,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: AppTextStyles.semiBold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tx.applicantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoalDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Status Badge
            Expanded(
              flex: 13,
              child: Center(
                child: _StatusBadge(status: tx.status, statusLabel: tx.statusLabel),
              ),
            ),
            // Details Action Button
            Expanded(
              flex: 15,
              child: Center(
                child: Material(
                  color: AppColors.forestLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      context.push('/department-transaction-details/${tx.transactionId}');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.eye,
                            color: AppColors.forest,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'عرض التفاصيل',
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: AppTextStyles.semiBold,
                              color: AppColors.forest,
                              height: 1,
                            ),
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
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: AppTextStyles.semiBold,
            height: 1,
          ),
        ),
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
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            color: color ?? AppColors.charcoalDark,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String statusLabel;

  const _StatusBadge({required this.status, required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'pending_pickup':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'in_progress':
        bg = AppColors.gold.withValues(alpha: 0.14);
        fg = AppColors.goldDark;
        break;
      case 'completed':
        bg = AppColors.forestLight.withValues(alpha: 0.12);
        fg = AppColors.forest;
        break;
      case 'rejected':
      default:
        bg = AppColors.umber.withValues(alpha: 0.08);
        fg = AppColors.umber;
    }

    return Tooltip(
      message: 'الحالة: $statusLabel',
      waitDuration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          statusLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: AppTextStyles.semiBold,
            color: fg,
            height: 1,
          ),
        ),
      ),
    );
  }
}
