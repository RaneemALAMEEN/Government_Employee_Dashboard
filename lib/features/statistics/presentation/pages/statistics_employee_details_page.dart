import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../../self_cards/presentation/widgets/self_card_details_view.dart';
import '../../domain/entities/statistics_employee_details_entity.dart';
import '../bloc/statistics_employee_details_bloc.dart';
import '../bloc/statistics_employee_details_event.dart';
import '../bloc/statistics_employee_details_state.dart';

class StatisticsEmployeeDetailsPage extends StatefulWidget {
  final int employeeId;

  const StatisticsEmployeeDetailsPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<StatisticsEmployeeDetailsPage> createState() =>
      _StatisticsEmployeeDetailsPageState();
}

class _StatisticsEmployeeDetailsPageState
    extends State<StatisticsEmployeeDetailsPage> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: BlocBuilder<StatisticsEmployeeDetailsBloc,
                  StatisticsEmployeeDetailsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Page Header
                      _PageHeader(
                        employeeName: state is EmployeeDetailsLoaded
                            ? state.employee.fullName
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Body Content
                      _buildBody(context, state),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StatisticsEmployeeDetailsState state,
  ) {
    if (state is EmployeeDetailsInitial || state is EmployeeDetailsLoading) {
      return const _EmployeeDetailsSkeleton();
    }

    if (state is EmployeeDetailsError) {
      return AppErrorWidget(
        title: 'تعذر تحميل بيانات الموظف',
        message: state.message,
        onRetry: () => context.read<StatisticsEmployeeDetailsBloc>().add(
              LoadEmployeeDetails(employeeId: widget.employeeId),
            ),
      );
    }

    if (state is EmployeeDetailsLoaded) {
      final employee = state.employee;
      if (employee.id == 0 && employee.fullName.isEmpty) {
        return const _EmptyDetails();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tab Selection Bar
          FadeInDown(
            duration: const Duration(milliseconds: 250),
            child: _TabSelector(
              selectedIndex: _selectedTabIndex,
              hasSelfCard: state.hasSelfCard,
              onTabSelected: (index) {
                setState(() => _selectedTabIndex = index);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Tab Content
          if (_selectedTabIndex == 0)
            FadeInUp(
              key: const ValueKey('self_card_tab'),
              duration: const Duration(milliseconds: 300),
              child: _buildSelfCardTab(state),
            )
          else
            FadeInUp(
              key: const ValueKey('account_info_tab'),
              duration: const Duration(milliseconds: 300),
              child: _EmployeeAccountDetailsView(employee: employee),
            ),
        ],
      );
    }

    return const _EmptyDetails();
  }

  Widget _buildSelfCardTab(EmployeeDetailsLoaded state) {
    if (state.selfCard != null) {
      return SelfCardDetailsView(
        selfCard: state.selfCard!,
        showChangeEmployeeButton: false,
      );
    }

    return _NoSelfCardPlaceholder(
      onViewAccountDetails: () {
        setState(() => _selectedTabIndex = 1);
      },
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String? employeeName;

  const _PageHeader({this.employeeName});

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: employeeName != null && employeeName!.isNotEmpty
          ? 'تفاصيل الموظف — $employeeName'
          : 'تفاصيل الموظف',
      subtitle:
          'استعراض البطاقة الذاتية المعتمدة والبيانات الوظيفية وسجلات الحساب',
      backButton: AppBackButton(
        label: 'العودة للإحصائيات',
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/statistics');
          }
        },
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final int selectedIndex;
  final bool hasSelfCard;
  final ValueChanged<int> onTabSelected;

  const _TabSelector({
    required this.selectedIndex,
    required this.hasSelfCard,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabButton(
            label: 'البطاقة الذاتية',
            icon: LucideIcons.contact,
            isSelected: selectedIndex == 0,
            badgeText: hasSelfCard ? 'متوفرة' : 'غير مرتبطة',
            badgeColor: hasSelfCard
                ? AppColors.forest.withValues(alpha: 0.12)
                : Colors.orange.shade50,
            badgeTextColor:
                hasSelfCard ? AppColors.forest : Colors.orange.shade800,
            onTap: () => onTabSelected(0),
          ),
          const SizedBox(width: 8),
          _TabButton(
            label: 'بيانات الحساب والنظام',
            icon: LucideIcons.userCog,
            isSelected: selectedIndex == 1,
            onTap: () => onTabSelected(1),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final String? badgeText;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forest : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.charcoal,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.charcoalDark,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.20)
                      : (badgeColor ?? Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText!,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (badgeTextColor ?? AppColors.charcoal),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoSelfCardPlaceholder extends StatelessWidget {
  final VoidCallback onViewAccountDetails;

  const _NoSelfCardPlaceholder({required this.onViewAccountDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  LucideIcons.contact,
                  size: 34,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'لا توجد بطاقة ذاتية مرتبطة بهذا الموظف حالياً',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم إنشاء أو ربط بطاقة ذاتية لهذا الموظف عبر المنظومة حتى الآن. يمكنك استعراض بيانات الحساب الأساسية أو إنشاء بطاقة ذاتية من قسم البطاقات الذاتية.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.65),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onViewAccountDetails,
                    icon: const Icon(LucideIcons.userCog, size: 16),
                    label: const Text('عرض بيانات الحساب والنظام'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/self-cards'),
                    icon: const Icon(LucideIcons.arrowUpLeft, size: 16),
                    label: const Text('الانتقال لقسم البطاقات الذاتية'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeAccountDetailsView extends StatelessWidget {
  final StatisticsEmployeeDetailsEntity employee;

  const _EmployeeAccountDetailsView({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Header Card
        _AccountHeaderCard(employee: employee),
        const SizedBox(height: 20),

        // Grid of Detail Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final cardWidth = isWide
                ? (constraints.maxWidth - 20) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 20,
              runSpacing: 20,
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
                    child: _AccountSectionCard(
                      icon: LucideIcons.user,
                      title: 'المعلومات الشخصية للحساب',
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
                    child: _AccountSectionCard(
                      icon: LucideIcons.mail,
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
                ]))
                  SizedBox(
                    width: cardWidth,
                    child: _AccountSectionCard(
                      icon: LucideIcons.building2,
                      title: 'المعلومات الإدارية والتنظيمية',
                      items: [
                        _InfoItem('الجهة', employee.organization.name),
                        _InfoItem('الدائرة', employee.department.name),
                        _InfoItem('الدور الوظيفي', employee.role.name),
                      ],
                    ),
                  ),
                SizedBox(
                  width: cardWidth,
                  child: _AccountSectionCard(
                    icon: LucideIcons.shieldCheck,
                    title: 'بيانات النظام والاعتماد',
                    items: [
                      _InfoItem(
                        'حالة الحساب',
                        employee.isActive ? 'فعال ومفعل' : 'غير فعال',
                      ),
                      _InfoItem(
                        'تاريخ إنشاء الحساب',
                        _formatDate(employee.createdAt),
                      ),
                      _InfoItem(
                        'آخر تحديث للنظام',
                        _formatDate(employee.updatedAt),
                      ),
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
}

class _AccountHeaderCard extends StatelessWidget {
  final StatisticsEmployeeDetailsEntity employee;

  const _AccountHeaderCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;

          final profile = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.forest.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _initials(employee.firstName, employee.lastName),
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.forest,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.charcoalDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (employee.role.name.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        employee.role.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w600,
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
                            size: 14,
                            color: AppColors.charcoal.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              employee.department.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal.withValues(alpha: 0.75),
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

          final statusBadge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: employee.isActive
                  ? AppColors.forest.withValues(alpha: 0.1)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: employee.isActive
                    ? AppColors.forest.withValues(alpha: 0.25)
                    : Colors.red.shade200,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: employee.isActive
                        ? AppColors.forest
                        : Colors.red.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  employee.isActive ? 'حساب نشط' : 'حساب غير نشط',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: employee.isActive
                        ? AppColors.forest
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profile,
                const SizedBox(height: 16),
                statusBadge,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: profile),
              const SizedBox(width: 20),
              statusBadge,
            ],
          );
        },
      ),
    );
  }
}

class _AccountSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_InfoItem> items;

  const _AccountSectionCard({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.06),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.forest, size: 19),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
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
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight.withValues(
                                alpha: 0.25,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.charcoal.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                SelectableText(
                                  item.value,
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.charcoalDark,
                                    fontWeight: FontWeight.bold,
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

class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}

class _EmployeeDetailsSkeleton extends StatelessWidget {
  const _EmployeeDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CustomSkeletonLoader(
          width: double.infinity,
          height: 120,
          borderRadius: 16,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 200,
          borderRadius: 14,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 180,
          borderRadius: 14,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 220,
          borderRadius: 14,
        ),
      ],
    );
  }
}

class _EmptyDetails extends StatelessWidget {
  const _EmptyDetails();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 360),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.userRoundX,
            size: 44,
            color: AppColors.charcoal,
          ),
          const SizedBox(height: 14),
          Text(
            'لا توجد بيانات متاحة لهذا الموظف',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalDark,
            ),
          ),
        ],
      ),
    );
  }
}

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
