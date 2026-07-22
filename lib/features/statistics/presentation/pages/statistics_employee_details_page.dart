import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/statistics_employee_details_entity.dart';
import '../bloc/statistics_employee_details_bloc.dart';
import '../bloc/statistics_employee_details_event.dart';
import '../bloc/statistics_employee_details_state.dart';

class StatisticsEmployeeDetailsPage extends StatelessWidget {
  final int employeeId;

  const StatisticsEmployeeDetailsPage({
    super.key,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: AppColors.background,
          child: BlocBuilder<StatisticsEmployeeDetailsBloc,
              StatisticsEmployeeDetailsState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                    sliver: SliverToBoxAdapter(child: _LegacyPageHeader()),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 36),
                    sliver: SliverToBoxAdapter(
                      child: _body(context, state),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );

  Widget _body(
    BuildContext context,
    StatisticsEmployeeDetailsState state,
  ) {
    if (state is EmployeeDetailsInitial || state is EmployeeDetailsLoading) {
      return const _EmployeeDetailsSkeleton();
    }
    if (state is EmployeeDetailsError) {
      return AppErrorWidget(
        onRetry: () => context
            .read<StatisticsEmployeeDetailsBloc>()
            .add(LoadEmployeeDetails(employeeId: employeeId)),
      );
    }
    if (state is EmployeeDetailsLoaded) {
      final employee = state.employee;
      if (employee.id == 0 && employee.fullName.isEmpty) {
        return const _EmptyDetails();
      }
      return _EmployeeProfile(employee: employee);
    }
    return const _EmptyDetails();
  }
}

// Kept temporarily as a visual reference while the legacy feature is retired.
// ignore: unused_element
class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
        children: [
          IconButton.filledTonal(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/statistics'),
            tooltip: 'العودة',
            icon: const Icon(LucideIcons.arrowRight, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'تفاصيل الموظف',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
}

class _EmployeeProfile extends StatelessWidget {
  final StatisticsEmployeeDetailsEntity employee;

  const _EmployeeProfile({required this.employee});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LegacyProfileHeaderCard(employee: employee),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoColumns = constraints.maxWidth >= 900;
              final cardWidth = twoColumns
                  ? (constraints.maxWidth - 18) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  if (_hasAny([
                    employee.firstName,
                    employee.lastName,
                    employee.fatherName,
                    employee.motherName,
                    employee.nationalId,
                  ]))
                    SizedBox(
                      width: cardWidth,
                      child: _LegacyDetailsSectionCard(
                        icon: LucideIcons.userRound,
                        title: 'المعلومات الشخصية',
                        items: [
                          _InfoItem('الاسم الأول', employee.firstName),
                          _InfoItem('الاسم الأخير', employee.lastName),
                          _InfoItem('اسم الأب', employee.fatherName),
                          _InfoItem('اسم الأم', employee.motherName),
                          _InfoItem('الرقم الوطني', employee.nationalId),
                        ],
                      ),
                    ),
                  if (_hasAny([
                    employee.email,
                    employee.phoneNumber,
                    employee.userName,
                  ]))
                    SizedBox(
                      width: cardWidth,
                      child: _LegacyDetailsSectionCard(
                        icon: LucideIcons.contactRound,
                        title: 'معلومات التواصل',
                        items: [
                          _InfoItem('البريد الإلكتروني', employee.email),
                          _InfoItem('رقم الهاتف', employee.phoneNumber),
                          _InfoItem('اسم المستخدم', employee.userName),
                        ],
                      ),
                    ),
                  if (_hasAny([
                    employee.organization.name,
                    employee.department.name,
                    employee.role.name,
                    employee.role.code,
                  ]))
                    SizedBox(
                      width: cardWidth,
                      child: _LegacyDetailsSectionCard(
                        icon: LucideIcons.briefcaseBusiness,
                        title: 'المعلومات الوظيفية',
                        items: [
                          _InfoItem('الجهة', employee.organization.name),
                          _InfoItem('الدائرة', employee.department.name),
                          _InfoItem('الدور', employee.role.name),
                          _InfoItem('كود الدور', employee.role.code,
                              isLtr: true),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: cardWidth,
                    child: _LegacyDetailsSectionCard(
                      icon: LucideIcons.settings2,
                      title: 'معلومات النظام',
                      items: [
                        _InfoItem(
                          'الحالة',
                          employee.isActive ? 'فعال' : 'غير فعال',
                        ),
                        _InfoItem(
                            'تاريخ الإنشاء', _formatDate(employee.createdAt)),
                        _InfoItem('آخر تحديث', _formatDate(employee.updatedAt)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
}

// ignore: unused_element
class _ProfileHeaderCard extends StatelessWidget {
  final StatisticsEmployeeDetailsEntity employee;

  const _ProfileHeaderCard({required this.employee});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 18,
          runSpacing: 16,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.lightPrimary,
                  child: Text(
                    _initials(employee.firstName, employee.lastName),
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _available(employee.fullName),
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _available(employee.role.name),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_available(employee.department.name)} · ${_available(employee.userName)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: employee.isActive
                    ? AppColors.lightPrimary
                    : AppColors.error.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: employee.isActive
                      ? AppColors.primary.withValues(alpha: .20)
                      : AppColors.error.withValues(alpha: .18),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: employee.isActive
                          ? AppColors.primary
                          : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    employee.isActive ? 'فعال' : 'غير فعال',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: employee.isActive
                          ? AppColors.primary
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ignore: unused_element
class _DetailsSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoItem> items;

  const _DetailsSectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              return Column(
                children: [
                  if (entry.key > 0)
                    Divider(color: AppColors.border.withValues(alpha: .30)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Text(
                            _available(item.value),
                            textDirection: item.isLtr
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            textAlign: TextAlign.end,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      );
}

class _InfoItem {
  final String label;
  final String value;
  final bool isLtr;

  const _InfoItem(this.label, this.value, {this.isLtr = false});
}

class _LegacyPageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: context.canPop() ? () => context.pop() : null,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.arrowRight,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'العودة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

class _LegacyProfileHeaderCard extends StatelessWidget {
  final StatisticsEmployeeDetailsEntity employee;

  const _LegacyProfileHeaderCard({required this.employee});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 620;
            final profile = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.textPrimary.withValues(alpha: .20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.surface.withValues(alpha: .20),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _initials(employee.firstName, employee.lastName),
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.surface,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.surface,
                        ),
                      ),
                      if (employee.role.name.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          employee.role.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.surface.withValues(alpha: .82),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (employee.department.name.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.building,
                              size: 15,
                              color: AppColors.surface.withValues(alpha: .62),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                employee.department.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color:
                                      AppColors.surface.withValues(alpha: .82),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );

            final status = Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.surface.withValues(alpha: .28),
                ),
              ),
              child: Text(
                employee.isActive ? 'فعال' : 'غير فعال',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profile,
                  const SizedBox(height: 16),
                  status,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: profile),
                const SizedBox(width: 20),
                status,
              ],
            );
          },
        ),
      );
}

class _LegacyDetailsSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoItem> items;

  const _LegacyDetailsSectionCard({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final visibleItems = items
        .where((item) => item.value.trim().isNotEmpty)
        .toList(growable: false);
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            color: AppColors.lightPrimary.withValues(alpha: .62),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 19),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.border.withValues(alpha: .20),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final twoColumns = constraints.maxWidth > 550;
                final fieldWidth = twoColumns
                    ? (constraints.maxWidth - 14) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: visibleItems
                      .map(
                        (item) => SizedBox(
                          width: fieldWidth,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.lightPrimary.withValues(
                                alpha: .34,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary.withValues(
                                      alpha: .72,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                SelectableText(
                                  item.value,
                                  textDirection: item.isLtr
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeDetailsSkeleton extends StatelessWidget {
  const _EmployeeDetailsSkeleton();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _skeletonBox(130),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (_, constraints) => Wrap(
              spacing: 18,
              runSpacing: 18,
              children: List.generate(
                4,
                (_) => SizedBox(
                  width: constraints.maxWidth >= 900
                      ? (constraints.maxWidth - 18) / 2
                      : constraints.maxWidth,
                  child: _skeletonBox(210),
                ),
              ),
            ),
          ),
        ],
      );

  Widget _skeletonBox(double height) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: .25)),
        ),
      );
}

class _EmployeeDetailsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EmployeeDetailsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => _CenteredState(
        icon: LucideIcons.triangleAlert,
        iconColor: AppColors.error,
        message: message,
        action: FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(LucideIcons.refreshCw, size: 17),
          label: const Text('إعادة المحاولة'),
        ),
      );
}

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();

  @override
  Widget build(BuildContext context) => const _CenteredState(
        icon: LucideIcons.userRoundX,
        iconColor: AppColors.textSecondary,
        message: 'لا توجد بيانات متاحة لهذا الموظف',
      );
}

class _CenteredState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;
  final Widget? action;

  const _CenteredState({
    required this.icon,
    required this.iconColor,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 360),
        alignment: Alignment.center,
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: iconColor),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      );
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border.withValues(alpha: .34)),
      boxShadow: [
        BoxShadow(
          color: AppColors.textPrimary.withValues(alpha: .035),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

String _available(String value) => value.trim().isEmpty ? 'غير متوفر' : value;

String _formatDate(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

bool _hasAny(List<String> values) =>
    values.any((value) => value.trim().isNotEmpty);

String _initials(String firstName, String lastName) {
  final first = firstName.trim();
  final last = lastName.trim();
  final initials =
      '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}';
  return initials.isEmpty ? '؟' : initials;
}
