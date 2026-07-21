import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/process_definition_entity.dart';
import '../../domain/entities/transaction_type_entity.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: .48),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.workflow,
                  color: AppColors.surface,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة معاملات المديرية',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'استعراض أنواع المعاملات والقوالب المرتبطة بها',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .12),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'اختر نوع المعاملة لعرض القوالب المرتبطة به',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth >= 850
                  ? (constraints.maxWidth - 16) / 3
                  : constraints.maxWidth >= 540
                      ? (constraints.maxWidth - 8) / 2
                      : constraints.maxWidth;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeaderStatCard(
                    width: cardWidth,
                    label: 'إجمالي أنواع المعاملات',
                    value: totalTypes,
                    icon: LucideIcons.layers3,
                  ),
                  _HeaderStatCard(
                    width: cardWidth,
                    label: 'الأنواع النشطة',
                    value: activeTypes,
                    icon: LucideIcons.circleCheck,
                  ),
                  _HeaderStatCard(
                    width: cardWidth,
                    label: 'الأنواع غير النشطة',
                    value: inactiveTypes,
                    icon: LucideIcons.circlePause,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class DirectorateComplaintsHeader extends StatelessWidget {
  final int total;

  const DirectorateComplaintsHeader({super.key, required this.total});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: .48),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                LucideIcons.messageSquareText,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الشكاوى',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'إجمالي الشكاوى: $total',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _HeaderStatCard extends StatelessWidget {
  final double width;
  final String label;
  final int value;
  final IconData icon;

  const _HeaderStatCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withValues(alpha: .38),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .035),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.primary, size: 15),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              value.toString(),
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
            const SizedBox(width: 14),
          ],
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: .18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(LucideIcons.workflow, color: AppColors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 5),
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

class TransactionTypesSectionHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const TransactionTypesSectionHeader({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            SizedBox(
              width: constraints.maxWidth >= 700
                  ? constraints.maxWidth - 440
                  : constraints.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أنواع المعاملات',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'اختر نوع المعاملة لعرض القوالب التابعة له',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: constraints.maxWidth >= 700 ? 420 : constraints.maxWidth,
              child: DirectorateSearchBar(onChanged: onSearchChanged),
            ),
          ],
        ),
      );
}

class _DirectorateSearchBarState extends State<DirectorateSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode
        .addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused
                ? AppColors.forest.withValues(alpha: .55)
                : AppColors.charcoal.withValues(alpha: .10),
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                      color: AppColors.forest.withValues(alpha: .08),
                      blurRadius: 18)
                ]
              : const [],
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.charcoal.withValues(alpha: .45),
            ),
            prefixIcon: const Icon(
              LucideIcons.search,
              size: 19,
              color: AppColors.forest,
            ),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                      },
                      icon: const Icon(LucideIcons.x, size: 18),
                    ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
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
        child: AnimatedScale(
          scale: _hovered ? 1.018 : 1,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 170),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? AppColors.forest.withValues(alpha: .42)
                    : AppColors.gold.withValues(alpha: .32),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoalDark.withValues(
                    alpha: _hovered ? .11 : .055,
                  ),
                  blurRadius: _hovered ? 28 : 15,
                  offset: Offset(0, _hovered ? 12 : 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(LucideIcons.gitBranch,
                              color: AppColors.primary, size: 18),
                        ),
                        const Spacer(),
                        _StatusPill(active: widget.item.isActive),
                      ]),
                      const SizedBox(height: 12),
                      Text(widget.item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium),
                      const SizedBox(height: 6),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.charcoal.withValues(alpha: .055),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(widget.item.code,
                              textDirection: TextDirection.ltr,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        const Spacer(),
                        Text(
                          'عرض القوالب',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedSlide(
                          offset:
                              _hovered ? const Offset(-.15, 0) : Offset.zero,
                          duration: const Duration(milliseconds: 170),
                          child: const Icon(LucideIcons.arrowLeft,
                              size: 18, color: AppColors.goldDark),
                        ),
                      ]),
                    ],
                  ),
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

class DirectorateSkeletonGrid extends StatefulWidget {
  const DirectorateSkeletonGrid({super.key});
  @override
  State<DirectorateSkeletonGrid> createState() =>
      _DirectorateSkeletonGridState();
}

class _DirectorateSkeletonGridState extends State<DirectorateSkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            itemBuilder: (_, __) => AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-1.5 + _controller.value * 3, 0),
                  end: Alignment(-.5 + _controller.value * 3, 0),
                  colors: [
                    AppColors.gold.withValues(alpha: .28),
                    AppColors.white.withValues(alpha: .86),
                    AppColors.gold.withValues(alpha: .28),
                  ],
                ).createShader(bounds),
                blendMode: BlendMode.srcATop,
                child: child,
              ),
              child: Container(
                  decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: .24),
                borderRadius: BorderRadius.circular(22),
              )),
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
  Widget build(BuildContext context) => Center(
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
      ));
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
