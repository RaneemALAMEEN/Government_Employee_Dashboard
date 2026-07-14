import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/my_transaction_entity.dart';

class MyTxTable extends StatefulWidget {
  final List<MyTransactionEntity> transactions;
  final ValueChanged<String> onSign;
  final ValueChanged<String> onReject;
  final String activeFilter;
  final String searchQuery;

  const MyTxTable({
    super.key,
    required this.transactions,
    required this.onSign,
    required this.onReject,
    required this.activeFilter,
    required this.searchQuery,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double minTableWidth = 900;
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
                    color: AppColors.gold.withOpacity(0.18),
                  ),
                  itemBuilder: (context, index) {
                    return FadeInUp(
                      duration: const Duration(milliseconds: 350),
                      delay: Duration(milliseconds: index * 50),
                      child: _TransactionRow(
                        tx: widget.transactions[index],
                        onSign: widget.onSign,
                        onReject: widget.onReject,
                      ),
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
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.charcoal.withOpacity(0.60), height: 1.4),
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
          _HeaderText('رقم المعاملة', flex: 18),
          _HeaderText('النوع', flex: 16),
          _HeaderText('مقدم الطلب', flex: 17),
          _HeaderText('الدائرة', flex: 17),
          _HeaderText('التاريخ', flex: 13),
          _HeaderText('الأولوية', flex: 11),
          _HeaderText('الحالة', flex: 13),
          _HeaderText('إجراء', flex: 19),
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
              flex: 18,
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
            // Type
            _CellText(tx.type, flex: 16),
            // Applicant
            _CellText(tx.applicant, flex: 17),
            // Department
            _CellText(tx.department, flex: 17),
            // Date
            _CellText(
                (tx.status == 'منجزة' || tx.status == 'تم الرفض') && tx.completedAt != null
                    ? tx.completedAt!
                    : tx.date,
                flex: 13,
                color: AppColors.charcoal.withOpacity(0.70)),
            // Priority
            Expanded(
              flex: 11,
              child: Center(child: _PriorityBadge(priority: tx.priority)),
            ),
            // Status
            Expanded(
              flex: 13,
              child: Center(child: _StatusBadge(tx: tx)),
            ),
            // Actions
            Expanded(
              flex: 19,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionIconButton(
                    icon: LucideIcons.eye,
                    tooltip: 'عرض التفاصيل',
                    onTap: () {
                      context.go('/my-transactions/${tx.idTask}');
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
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.labelLarge
            .copyWith(fontWeight: AppTextStyles.semiBold, height: 1),
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
        style: AppTextStyles.labelLarge.copyWith(
            fontWeight: fontWeight,
            color: color ?? AppColors.charcoalDark,
            height: 1.25),
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
        bg = AppColors.umber.withOpacity(0.08);
        fg = AppColors.umber;
        break;
      case 'عادية':
        bg = AppColors.gold.withOpacity(0.14);
        fg = AppColors.goldDark;
        break;
      default: // منخفضة
        bg = AppColors.forestLight.withOpacity(0.12);
        fg = AppColors.forest;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: AppTextStyles.labelMedium
            .copyWith(fontWeight: AppTextStyles.semiBold, color: fg, height: 1),
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
    String label = tx.status;

    switch (tx.status) {
      case 'بانتظار الاستلام':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade700;
        break;
      case 'قيد التنفيذ':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        break;
      case 'منجزة':
        bg = AppColors.forestLight.withOpacity(0.12);
        fg = AppColors.forest;
        break;
      default: // تم الرفض
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
        label,
        style: AppTextStyles.labelMedium
            .copyWith(fontWeight: AppTextStyles.semiBold, color: fg, height: 1),
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
