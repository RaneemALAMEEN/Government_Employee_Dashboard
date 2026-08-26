import 'package:flutter/material.dart';
import 'package:government_employee_dashboard/features/directorate_process_management/domain/entities/process_definition_entity.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/transaction_type_entity.dart';

class DirectorateStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;

  const DirectorateStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE3E7E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: .09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTextStyles.medium,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.toString(),
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: valueColor ?? AppColors.charcoalDark,
                    fontWeight: AppTextStyles.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DirectorateManagementHeader extends StatelessWidget {
  final List<TransactionTypeEntity> types;

  const DirectorateManagementHeader({
    super.key,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    final totalTypes = types.length;
    final activeTypes = types.where((item) => item.isActive).length;
    final inactiveTypes = types.where((item) => !item.isActive).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 850
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth >= 540
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: DirectorateStatCard(
                label: 'إجمالي أنواع المعاملات',
                value: totalTypes,
                icon: LucideIcons.layers3,
                iconColor: AppColors.primary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: DirectorateStatCard(
                label: 'الأنواع النشطة',
                value: activeTypes,
                icon: LucideIcons.checkCircle2,
                iconColor: AppColors.forest,
                valueColor: AppColors.forest,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: DirectorateStatCard(
                label: 'الأنواع غير النشطة',
                value: inactiveTypes,
                icon: LucideIcons.pauseCircle,
                iconColor: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DirectorateComplaintsHeader extends StatelessWidget {
  final int total;

  const DirectorateComplaintsHeader({super.key, required this.total});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE3E7E4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .025),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.messageSquareText,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة مسارات الشكاوى',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'استعراض ومتابعة قوالب ومسارات معالجة الشكاوى وبلاغات المراجعين',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'إجمالي الشكاوى: $total',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: AppTextStyles.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
}

class DirectorateHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  const DirectorateHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (onBack != null) ...[
            IconButton.filledTonal(
              onPressed: onBack,
              tooltip: 'العودة إلى أنواع المعاملات',
              icon: const Icon(LucideIcons.arrowRight, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: .18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(LucideIcons.workflow,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: AppTextStyles.bold,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class TransactionTypesSectionHeader extends StatelessWidget {
  final int totalCount;
  final ValueChanged<String> onSearchChanged;

  const TransactionTypesSectionHeader({
    super.key,
    this.totalCount = 0,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 680;
          final titleWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أنواع المعاملات',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: AppTextStyles.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              if (totalCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalCount',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTextStyles.bold,
                    ),
                  ),
                ),
              ],
            ],
          );

          final searchWidget = SizedBox(
            width: isCompact ? constraints.maxWidth : 340,
            child: DirectorateSearchBar(onChanged: onSearchChanged),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                titleWidget,
                const SizedBox(height: 12),
                searchWidget,
              ],
            );
          }

          return Row(
            children: [
              titleWidget,
              const Spacer(),
              searchWidget,
            ],
          );
        },
      );
}

class DirectorateSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  const DirectorateSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'ابحث بالاسم أو الكود...',
  });

  @override
  State<DirectorateSearchBar> createState() => _DirectorateSearchBarState();
}

class _DirectorateSearchBarState extends State<DirectorateSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSearchField(
      controller: _controller,
      onChanged: widget.onChanged,
      hintText: widget.hintText,
      onClear: () => widget.onChanged(''),
    );
  }
}

class TransactionTypeCard extends StatefulWidget {
  final TransactionTypeEntity item;
  final VoidCallback onTap;
  const TransactionTypeCard(
      {super.key, required this.item, required this.onTap});

  @override
  State<TransactionTypeCard> createState() => _TransactionTypeCardState();
}

class _TransactionTypeCardState extends State<TransactionTypeCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: .38)
                  : const Color(0xFFE3E7E4),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(18),
              hoverColor: AppColors.primary.withValues(alpha: .02),
              splashColor: AppColors.primary.withValues(alpha: .05),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            LucideIcons.workflow,
                            color: AppColors.primary,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: AppTextStyles.bold,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(active: widget.item.isActive),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6F4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E9E6)),
                          ),
                          child: Text(
                            widget.item.code,
                            textDirection: TextDirection.ltr,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: AppTextStyles.bold,
                              color: AppColors.charcoal,
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'عرض القوالب',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: AppTextStyles.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedSlide(
                              offset:
                                  _hovered ? const Offset(-.2, 0) : Offset.zero,
                              duration: const Duration(milliseconds: 180),
                              child: const Icon(
                                LucideIcons.arrowLeft,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class ProcessDefinitionCard extends StatefulWidget {
  final ProcessDefinitionEntity item;
  final VoidCallback onTap;
  final String subtitle;

  const ProcessDefinitionCard({
    super.key,
    required this.item,
    required this.onTap,
    this.subtitle = 'تعريف سير المعاملة ومراحلها',
  });

  @override
  State<ProcessDefinitionCard> createState() => _ProcessDefinitionCardState();
}

class _ProcessDefinitionCardState extends State<ProcessDefinitionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedScale(
          scale: _hovered ? 1.02 : 1,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? AppColors.primary.withValues(alpha: .48)
                    : AppColors.border.withValues(alpha: .30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(
                    alpha: _hovered ? .12 : .045,
                  ),
                  blurRadius: _hovered ? 24 : 12,
                  offset: Offset(0, _hovered ? 10 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                splashColor: AppColors.primary.withValues(alpha: .08),
                hoverColor: AppColors.primary.withValues(alpha: .025),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedRotation(
                            turns: _hovered ? .025 : 0,
                            duration: const Duration(milliseconds: 170),
                            child: AnimatedScale(
                              scale: _hovered ? 1.08 : 1,
                              duration: const Duration(milliseconds: 170),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 170),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _hovered
                                      ? AppColors.primary.withValues(alpha: .11)
                                      : AppColors.lightPrimary,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  LucideIcons.fileCog,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  widget.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _ProcessChip(
                            text: _priorityLabel(widget.item.priority),
                            color: _priorityColor(widget.item.priority),
                            icon: LucideIcons.flag,
                          ),
                          _ProcessChip(
                            text: _deploymentLabel(
                              widget.item.deploymentStatus,
                            ),
                            color: widget.item.deploymentStatus.toLowerCase() ==
                                    'deployed'
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          _ProcessChip(
                            text: _approvalLabel(widget.item.approvalStatus),
                            color: _approvalColor(widget.item.approvalStatus),
                          ),
                          _ProcessChip(
                            text: widget.item.isActive ? 'فعّال' : 'غير فعّال',
                            color: widget.item.isActive
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'عرض التفاصيل',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 7),
                          AnimatedSlide(
                            offset:
                                _hovered ? const Offset(-.18, 0) : Offset.zero,
                            duration: const Duration(milliseconds: 170),
                            child: const Icon(
                              LucideIcons.arrowLeft,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  String _approvalLabel(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return 'معتمد';
      case 'PENDING':
        return 'قيد المراجعة';
      case 'REJECTED':
        return 'مرفوض';
      default:
        return value;
    }
  }

  Color _approvalColor(String value) {
    switch (value.toUpperCase()) {
      case 'APPROVED':
        return AppColors.primary;
      case 'PENDING':
        return AppColors.goldDark;
      case 'REJECTED':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _deploymentLabel(String value) {
    switch (value.toLowerCase()) {
      case 'deployed':
        return 'منشور';
      case 'draft':
        return 'مسودة';
      default:
        return value;
    }
  }

  String _priorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'منخفضة';
      case 2:
        return 'متوسطة';
      case 3:
        return 'مرتفعة';
      default:
        return 'أولوية $priority';
    }
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 1:
        return AppColors.forestLight;
      case 2:
        return AppColors.goldDark;
      case 3:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _ProcessChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _ProcessChip({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: .14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class DirectorateSkeletonGrid extends StatelessWidget {
  const DirectorateSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          final columns = constraints.maxWidth >= 1250
              ? 4
              : constraints.maxWidth >= 850
                  ? 3
                  : 2;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
              mainAxisExtent: 218,
            ),
            itemCount: 8,
            itemBuilder: (_, __) => const CustomSkeletonLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 22,
            ),
          );
        },
      );
}

class DirectorateMessageState extends StatelessWidget {
  final bool isError;
  final String message;
  final VoidCallback? onRetry;
  const DirectorateMessageState(
      {super.key, required this.message, this.isError = false, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (!isError && (message.contains('بحث') || message.contains('نتائج'))) {
      return AppEmptySearchState(
        title: message,
        description: 'تأكد من كتابة الكلمات بشكل صحيح أو جرّب البحث بكلمات أخرى.',
        isCard: true,
      );
    }

    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .88, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        builder: (_, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: .34),
              )),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                    color: (isError ? AppColors.umber : AppColors.forest)
                        .withValues(alpha: .08),
                    shape: BoxShape.circle),
                child: Icon(
                    isError ? LucideIcons.triangleAlert : LucideIcons.inbox,
                    size: 35,
                    color: isError ? AppColors.umber : AppColors.forest)),
            const SizedBox(height: 20),
            Text(message,
                textAlign: TextAlign.center, style: AppTextStyles.titleMedium),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 17),
                  label: const Text('إعادة المحاولة')),
            ],
          ]),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool active;
  const _StatusPill({required this.active});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: (active ? AppColors.forest : AppColors.umber)
                .withValues(alpha: .08),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: active ? AppColors.forestLight : AppColors.umberLight,
                  shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(active ? 'مفعّل' : 'غير مفعّل',
              style: AppTextStyles.labelLarge.copyWith(
                  color: active ? AppColors.forest : AppColors.umber,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}
