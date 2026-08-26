import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../domain/entities/my_transaction_entity.dart';

class MyTxTable extends StatefulWidget {
  final List<MyTransactionEntity> transactions;
  final ValueChanged<String> onSign;
  final ValueChanged<String> onReject;
  final String activeFilter;
  final String searchQuery;
  final bool isLoadingMore;
  final bool isSearching;
  final bool hasMore;

  const MyTxTable({
    super.key,
    required this.transactions,
    required this.onSign,
    required this.onReject,
    required this.activeFilter,
    required this.searchQuery,
    this.isLoadingMore = false,
    this.isSearching = false,
    this.hasMore = false,
  });

  @override
  State<MyTxTable> createState() => _MyTxTableState();
}

class _MyTxTableState extends State<MyTxTable> {
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
    final filteredTransactions = widget.transactions;

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
          if (widget.isSearching) ...[
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.white,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
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
              ),
            ),
            const SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                color: AppColors.forest,
                backgroundColor: AppColors.goldLight,
              ),
            ),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 650;
              final double availableWidth = constraints.maxWidth;

              final Widget tableContent = Column(
                children: [
                  const _TableHeader(),
                  if (filteredTransactions.isEmpty)
                    _buildEmptyState(widget.activeFilter)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: index * 50),
                          child: _TransactionRow(
                            tx: filteredTransactions[index],
                            onSign: widget.onSign,
                            onReject: widget.onReject,
                          ),
                        );
                      },
                    ),
                  // Loading more indicator
                  if (widget.isLoadingMore)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    ),
                  // "No more data" indicator
                  if (!widget.hasMore &&
                      filteredTransactions.isNotEmpty &&
                      !widget.isLoadingMore)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'تم عرض جميع المعاملات',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
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
      description =
          'تأكد من كتابة الاسم أو رقم المعاملة بشكل صحيح وحاول مرة أخرى.';
    } else {
      switch (filter) {
        case 'قيد التنفيذ':
          svgPath = 'assets/vectors/in progress.svg';
          title = 'لا توجد معاملات قيد التنفيذ';
          description =
              'لقد أنجزت جميع مهامك أو لم تقم باستلام معاملات جديدة للبدء بتنفيذها.';
          break;
        case 'بانتظار الاستلام':
          svgPath = 'assets/vectors/waiting.svg';
          title = 'لا توجد معاملات بانتظار الاستلام';
          description =
              'جميع المعاملات الواردة تم استلامها للبدء بالعمل عليها.';
          break;
        case 'منجزة':
          svgPath = 'assets/vectors/approved.svg';
          title = 'لا توجد معاملات منجزة';
          description = 'لم تقم بإنجاز أي معاملات خلال الفترة الحالية.';
          break;
        case 'تم الرفض':
          svgPath = 'assets/vectors/rejected.svg';
          title = 'لا توجد معاملات مرفوضة';
          description = 'سجلك خالي من أي معاملات مرفوضة.';
          break;
        default: // الكل
          svgPath = 'assets/vectors/waiting.svg';
          title = 'لا توجد معاملات متوفرة';
          description = 'قائمتك فارغة تماماً ولا تحتوي على أي معاملات.';
      }
    }

    return AppEmptySearchState(
      title: title,
      description: description,
      svgPath: svgPath,
      isCard: false,
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
          _HeaderText('رقم المعاملة', flex: 15),
          _HeaderText('اسم المعاملة', flex: 14),
          _HeaderText('النوع', flex: 12),
          _HeaderText('مقدم الطلب', flex: 14),
          _HeaderText('الدائرة', flex: 13),
          _HeaderText('التاريخ', flex: 10),
          _HeaderText('الأولوية', flex: 9),
          _HeaderText('الحالة', flex: 14),
          _HeaderText('إجراء', flex: 8),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final MyTransactionEntity tx;
  final ValueChanged<String> onSign;
  final ValueChanged<String> onReject;

  const _TransactionRow({
    required this.tx,
    required this.onSign,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgentPending = tx.priority == 'عالية' &&
        (tx.status == 'بانتظار الاستلام' || tx.status == 'قيد التنفيذ');

    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Transaction Number
            Expanded(
              flex: 15,
              child: Tooltip(
                message: tx.number,
                waitDuration: const Duration(milliseconds: 250),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUrgentPending) ...[
                      const Icon(
                        LucideIcons.alertTriangle,
                        color: AppColors.umber,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                    ],
                    Flexible(
                      child: Text(
                        tx.number,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.semiBold,
                            color: isUrgentPending
                                ? AppColors.umber
                                : AppColors.charcoalDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Process Name (اسم المعاملة)
            _CellText(tx.processName, flex: 14),
            // Type
            _CellText(tx.type, flex: 12),
            // Applicant
            _CellText(tx.applicant, flex: 14),
            // Department
            _CellText(tx.department, flex: 13),
            // Date
            _CellText(
                (tx.status == 'منجزة' || tx.status == 'تم الرفض') &&
                        tx.completedAt != null
                    ? tx.completedAt!
                    : tx.date,
                flex: 10,
                color: AppColors.charcoal.withValues(alpha: 0.70)),
            // Priority
            Expanded(
              flex: 9,
              child: Center(child: _PriorityBadge(priority: tx.priority)),
            ),
            // Status
            Expanded(
              flex: 14,
              child: Center(child: _StatusBadge(tx: tx)),
            ),
            // Actions
            Expanded(
              flex: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIconButton(
                    icon: LucideIcons.eye,
                    tooltip: 'عرض التفاصيل',
                    onTap: () {
                      final numericId = tx.transactionId?.toString() ??
                          (int.tryParse(tx.idTask) != null ? tx.idTask : '');
                      context.go(
                        '/my-transactions/${tx.idTask}',
                        extra: {
                          'status': tx.status,
                          'transaction_id': numericId,
                          'is_locked_by_me': tx.isLockedByMe,
                        },
                      );
                    },
                  ),
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
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge
              .copyWith(fontWeight: AppTextStyles.semiBold, height: 1),
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
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
              fontWeight: fontWeight,
              color: color ?? AppColors.charcoalDark,
              height: 1.25),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (priority) {
      case 'عالية':
        bg = AppColors.umber.withValues(alpha: 0.08);
        fg = AppColors.umber;
        break;
      case 'عادية':
        bg = AppColors.gold.withValues(alpha: 0.14);
        fg = AppColors.goldDark;
        break;
      default: // منخفضة
        bg = AppColors.forestLight.withValues(alpha: 0.12);
        fg = AppColors.forest;
    }

    return Tooltip(
      message: 'درجة الأولوية: $priority',
      waitDuration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          priority,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium
              .copyWith(fontWeight: AppTextStyles.semiBold, color: fg, height: 1),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MyTransactionEntity tx;

  const _StatusBadge({required this.tx});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;
    IconData icon;
    String label;
    String tooltip;

    switch (tx.status) {
      case 'بانتظار الاستلام':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        border = Colors.blue.shade200;
        icon = LucideIcons.clock;
        label = 'بانتظار الاستلام';
        tooltip = 'معاملة واردة بانتظار استلامها للبدء في تنفيذها';
        break;
      case 'قيد التنفيذ':
        if (tx.isLockedByMe) {
          bg = const Color(0xFFECFDF5);
          fg = const Color(0xFF047857);
          border = const Color(0xFFA7F3D0);
          icon = LucideIcons.userCheck;
          label = 'مستلمة بواسطتي';
          tooltip = 'هذه المعاملة قيد التنفيذ ومستلمة بواسطتك حالياً';
        } else {
          bg = const Color(0xFFFFFBEB);
          fg = const Color(0xFFB45309);
          border = const Color(0xFFFDE68A);
          icon = LucideIcons.users;
          label = 'موظف آخر';
          tooltip = 'هذه المعاملة قيد التنفيذ ومستلمة من قِبل موظف آخر';
        }
        break;
      case 'منجزة':
        bg = AppColors.forestLight.withValues(alpha: 0.14);
        fg = AppColors.forest;
        border = AppColors.forest.withValues(alpha: 0.25);
        icon = LucideIcons.checkCheck;
        label = 'منجزة';
        tooltip = 'تم إنجاز وتوقيع هذه المعاملة بنجاح';
        break;
      default: // تم الرفض
        bg = AppColors.umber.withValues(alpha: 0.10);
        fg = AppColors.umber;
        border = AppColors.umber.withValues(alpha: 0.25);
        icon = LucideIcons.xCircle;
        label = 'تم الرفض';
        tooltip = 'تم رفض هذه المعاملة';
    }

    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: fg,
                  fontSize: 10.5,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.forestLight.withOpacity(0.10),
            borderRadius: BorderRadius.circular(6),
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
