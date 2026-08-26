import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../../../shared/widgets/permission_denied_card.dart';
import '../../../department_transactions/presentation/widgets/dept_tx_date_range_picker_dialog.dart';
import '../../domain/entities/employee_search_result_entity.dart';
import '../../domain/entities/process_search_result_entity.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_pagination_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatisticsBloc>()..add(const LoadStatistics()),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatefulWidget {
  const _StatisticsView();

  @override
  State<_StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<_StatisticsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: const _Header(),
            ),
            const SizedBox(height: 22),
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 100),
              child: _Tabs(controller: _tabController),
            ),
            const SizedBox(height: 22),
            BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
// ... (inside build)
                if (state is StatisticsLoading || state is StatisticsInitial) {
                  return const Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 160)),
                          SizedBox(width: 16),
                          Expanded(
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 160)),
                          SizedBox(width: 16),
                          Expanded(
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 160)),
                          SizedBox(width: 16),
                          Expanded(
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 160)),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 7,
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 400)),
                          SizedBox(width: 24),
                          Expanded(
                              flex: 3,
                              child: CustomSkeletonLoader(
                                  width: double.infinity, height: 400)),
                        ],
                      ),
                    ],
                  );
                }

                final loaded = state as StatisticsLoaded;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 820,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _EmployeeStatsView(
                            state: loaded,
                          ),
                          _TransactionStatsView(
                            state: loaded,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsSectionState extends StatelessWidget {
  final StatisticsSectionStatus status;
  final String emptyMessage;

  const _StatisticsSectionState({
    required this.status,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final forbidden = status == StatisticsSectionStatus.forbidden;
    if (forbidden) {
      return const PermissionDeniedCard(
        title: 'لا تملك صلاحية عرض هذه الإحصائيات',
        description: 'تواصل مع مسؤول النظام لمنحك الصلاحية المناسبة',
      );
    }
    final empty = status == StatisticsSectionStatus.empty;
    final icon = empty ? LucideIcons.inbox : LucideIcons.triangleAlert;
    final title = empty ? emptyMessage : 'تعذر تحميل الإحصائيات';
    final description =
        empty ? null : 'تعذر جلب البيانات من الخادم. حاول التحديث لاحقاً.';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 42),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: .25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.goldDark),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.charcoalDark,
                fontWeight: AppTextStyles.bold,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'الإحصائيات',
      subtitle: 'لوحة واحدة لمتابعة ضغط الموظفين وحالة المعاملات ضمن الدوائر',
      trailing: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: IconButton(
          onPressed: () {
            context.read<StatisticsBloc>().add(const RefreshStatistics());
          },
          icon: const Icon(LucideIcons.refreshCw, color: AppColors.forest),
          tooltip: 'تحديث البيانات',
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  final TabController controller;

  const _Tabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: AppColors.forest,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.charcoalDark,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: AppTextStyles.bold,
        ),
        tabs: const [
          Tab(child: _TabLabel(icon: LucideIcons.users, text: 'الموظفين')),
          Tab(child: _TabLabel(icon: LucideIcons.workflow, text: 'المعاملات')),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TabLabel({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class _EmployeeStatsView extends StatefulWidget {
  final StatisticsLoaded state;

  const _EmployeeStatsView({
    required this.state,
  });

  @override
  State<_EmployeeStatsView> createState() => _EmployeeStatsViewState();
}

class _EmployeeStatsViewState extends State<_EmployeeStatsView> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.state.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _EmployeeStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.searchQuery != _searchController.text &&
        !widget.state.isSearchActive) {
      _searchController.text = '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<StatisticsBloc>().add(SearchEmployeesEvent(query: query));
      }
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<StatisticsBloc>().add(const ClearEmployeeSearchEvent());
  }

  void _submitSearch() {
    _debounce?.cancel();
    context.read<StatisticsBloc>().add(
          SearchEmployeesEvent(query: _searchController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isSearching = state.isSearchActive;

    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmployeeSearchBar(
            controller: _searchController,
            isLoading: state.isSearching,
            onChanged: _onSearchChanged,
            onSubmit: _submitSearch,
            onClear: _clearSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isSearching
                ? _EmployeeSearchResultsView(
                    state: state,
                    onRetry: _submitSearch,
                    onClear: _clearSearch,
                  )
                : _EmployeeWorkloadStatsView(
                    employees: state.employees,
                    status: state.employeesStatus,
                    pagination: state.employeesPagination,
                    isLoadingMore: state.isLoadingMoreEmployees,
                    loadMoreErrorMessage: state.employeesLoadMoreErrorMessage,
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const _EmployeeSearchBar({
    required this.controller,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: controller,
              isLoading: isLoading,
              hintText: 'ابحث بالاسم الكامل، الرقم الوطني، البريد، أو اسم المستخدم...',
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(),
              onClear: onClear,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(LucideIcons.search, size: 18),
            label: const Text('بحث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeSearchResultsView extends StatelessWidget {
  final StatisticsLoaded state;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  const _EmployeeSearchResultsView({
    required this.state,
    required this.onRetry,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isSearching && state.searchResults.isEmpty) {
      return const Column(
        children: [
          CustomSkeletonLoader(width: double.infinity, height: 110),
          SizedBox(height: 12),
          CustomSkeletonLoader(width: double.infinity, height: 110),
          SizedBox(height: 12),
          CustomSkeletonLoader(width: double.infinity, height: 110),
        ],
      );
    }

    if (state.searchErrorMessage != null && state.searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: _cardDecoration(),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert,
                color: AppColors.umber, size: 42),
            const SizedBox(height: 14),
            Text(
              'حدث خطأ أثناء البحث',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: AppTextStyles.bold,
                color: AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.searchErrorMessage!,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.goldDark),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return AppEmptySearchState(
        title: 'لا توجد نتائج تطابق بحثك',
        description:
            'تأكد من كتابة الاسم أو الرقم الوطني بشكل صحيح وحاول مرة أخرى.',
        action: AppBackButton(
          label: 'العودة للإحصائيات',
          onPressed: onClear,
        ),
      );
    }

    final hasNext = state.searchPagination?.hasNext == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.users, color: AppColors.forest, size: 20),
              const SizedBox(width: 8),
              Text(
                'نتائج البحث عن «${state.searchQuery}»',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(width: 10),
              _Pill(
                text: '${state.searchResults.length} موظف',
                color: AppColors.forest,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(LucideIcons.x, size: 16),
                label: const Text('إلغاء البحث'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.goldDark),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: state.searchResults.length + (hasNext ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= state.searchResults.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: state.isLoadingMoreSearch
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.forest,
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {
                                context
                                    .read<StatisticsBloc>()
                                    .add(const LoadMoreSearchEmployeesEvent());
                              },
                              icon: const Icon(LucideIcons.plus, size: 16),
                              label: const Text('تحميل المزيد من النتائج'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.forest,
                                side:
                                    const BorderSide(color: AppColors.forest),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                    ),
                  );
                }

                final employee = state.searchResults[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 250),
                  delay: Duration(milliseconds: (index % 10) * 30),
                  child: _EmployeeSearchResultCard(employee: employee),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeSearchResultCard extends StatelessWidget {
  final EmployeeSearchItemEntity employee;

  const _EmployeeSearchResultCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/statistics/employees/${employee.id}');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.goldLight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _Avatar(name: employee.displayName),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.displayName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (employee.userName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '@${employee.userName}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.goldDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.building,
                          size: 14, color: AppColors.forest),
                      const SizedBox(width: 4),
                      Text(
                        employee.departmentName.isNotEmpty
                            ? employee.departmentName
                            : employee.organizationName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (employee.roleName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '•  ${employee.roleName}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoalDark,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (employee.nationalId.isNotEmpty)
                    Row(
                      children: [
                        const Icon(LucideIcons.idCard,
                            size: 14, color: AppColors.goldDark),
                        const SizedBox(width: 6),
                        Text(
                          'الرقم الوطني: ${employee.nationalId}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.charcoalDark,
                          ),
                        ),
                      ],
                    ),
                  if (employee.phoneNumber.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.phone,
                            size: 14, color: AppColors.goldDark),
                        const SizedBox(width: 6),
                        Text(
                          employee.phoneNumber,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.charcoalDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Pill(
              text: employee.isActive ? 'نشط' : 'غير نشط',
              color: employee.isActive ? AppColors.forest : AppColors.goldDark,
            ),
            const SizedBox(width: 12),
            const Icon(
              LucideIcons.chevronLeft,
              color: AppColors.forest,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeWorkloadStatsView extends StatelessWidget {
  final List<StatisticsEmployeeEntity> employees;
  final StatisticsSectionStatus status;
  final StatisticsPaginationEntity? pagination;
  final bool isLoadingMore;
  final String? loadMoreErrorMessage;

  const _EmployeeWorkloadStatsView({
    required this.employees,
    required this.status,
    this.pagination,
    this.isLoadingMore = false,
    this.loadMoreErrorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (status != StatisticsSectionStatus.success) {
      return _StatisticsSectionState(
        status: status,
        emptyMessage: 'لا يوجد موظفون ضمن هذه الدائرة حالياً',
      );
    }
    final active =
        employees.fold<int>(0, (sum, item) => sum + item.activeTotal);
    final completed =
        employees.fold<int>(0, (sum, item) => sum + item.completed);
    final overloaded =
        employees.where((item) => item.status == 'overloaded').length;
    final inactive =
        employees.where((item) => item.status == 'inactive').length;
    final hasNext = pagination?.hasNext == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricsGrid(
          cards: [
            _Metric(
                'مهام نشطة', '$active', LucideIcons.clock3, AppColors.forest),
            _Metric('منجزة', '$completed', LucideIcons.circleCheck,
                AppColors.forestLight),
            _Metric('موظفون مثقلون', '$overloaded', LucideIcons.trendingUp,
                AppColors.umber),
            _Metric('غير نشطين', '$inactive', LucideIcons.userX,
                AppColors.goldDark),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 1040;
              final table = _Panel(
                title: 'توزيع عبء الموظفين',
                subtitle: 'بيانات موظفي الدوائر حسب المهام النشطة والمنجزة',
                icon: LucideIcons.users,
                expandChild: true,
                child: employees.isEmpty
                    ? const _EmptyState(text: 'لا توجد بيانات موظفين حالياً')
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: employees.length + 1,
                        itemBuilder: (context, index) {
                          if (index == employees.length) {
                            if (isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.forest,
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (loadMoreErrorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      loadMoreErrorMessage!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.umber,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () {
                                        context
                                            .read<StatisticsBloc>()
                                            .add(const RetryStatisticsEmployeesLoadMore());
                                      },
                                      icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                      label: const Text('إعادة المحاولة'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.forest,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            if (hasNext) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      context
                                          .read<StatisticsBloc>()
                                          .add(const LoadMoreStatisticsEmployees());
                                    },
                                    icon: const Icon(LucideIcons.plus, size: 16),
                                    label: const Text('تحميل المزيد من الموظفين'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.forest,
                                      side: const BorderSide(color: AppColors.forest),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'تم عرض جميع الموظفين (${employees.length})',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.charcoal.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          return FadeInUp(
                            duration: const Duration(milliseconds: 320),
                            delay: Duration(milliseconds: (index % 6) * 45),
                            child: _EmployeeRow(employee: employees[index]),
                          );
                        },
                      ),
              );
              final insights = _InsightsPanel(employees: employees);

              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 7, child: table),
                        const SizedBox(width: 20),
                        Expanded(flex: 3, child: insights),
                      ],
                    )
                  : ListView(
                      children: [
                        SizedBox(height: 520, child: table),
                        const SizedBox(height: 20),
                        insights,
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }
}

class _TransactionStatsView extends StatefulWidget {
  final StatisticsLoaded state;

  const _TransactionStatsView({
    required this.state,
  });

  @override
  State<_TransactionStatsView> createState() => _TransactionStatsViewState();
}

class _TransactionStatsViewState extends State<_TransactionStatsView> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: widget.state.processSearchQuery);
  }

  @override
  void didUpdateWidget(covariant _TransactionStatsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.processSearchQuery != _searchController.text &&
        !widget.state.isProcessSearchActive) {
      _searchController.text = '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<StatisticsBloc>().add(SearchProcessesEvent(query: query));
      }
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    context.read<StatisticsBloc>().add(const ClearProcessSearchEvent());
  }

  void _submitSearch() {
    _debounce?.cancel();
    context.read<StatisticsBloc>().add(
          SearchProcessesEvent(query: _searchController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isSearching = state.isProcessSearchActive;

    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProcessSearchBar(
            controller: _searchController,
            isLoading: state.isSearchingProcesses,
            onChanged: _onSearchChanged,
            onSubmit: _submitSearch,
            onClear: _clearSearch,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: isSearching
                ? _ProcessSearchResultsView(
                    state: state,
                    onRetry: _submitSearch,
                    onClear: _clearSearch,
                  )
                : _ProcessDefaultStatsView(
                    processes: state.processes,
                    status: state.transactionsStatus,
                    fromDate: state.processFromDate,
                    toDate: state.processToDate,
                    pagination: state.processesPagination,
                    isLoadingMore: state.isLoadingMoreProcesses,
                    loadMoreErrorMessage:
                        state.processesLoadMoreErrorMessage,
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProcessSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final VoidCallback onClear;

  const _ProcessSearchBar({
    required this.controller,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmit,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: AppSearchField(
              controller: controller,
              isLoading: isLoading,
              hintText: 'ابحث باسم المعاملة أو الرمز أو نوع المعاملة...',
              onChanged: onChanged,
              onSubmitted: (_) => onSubmit(),
              onClear: onClear,
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onSubmit,
            icon: const Icon(LucideIcons.search, size: 18),
            label: const Text('بحث'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessSearchResultsView extends StatefulWidget {
  final StatisticsLoaded state;
  final VoidCallback onRetry;
  final VoidCallback onClear;

  const _ProcessSearchResultsView({
    required this.state,
    required this.onRetry,
    required this.onClear,
  });

  @override
  State<_ProcessSearchResultsView> createState() =>
      _ProcessSearchResultsViewState();
}

class _ProcessSearchResultsViewState extends State<_ProcessSearchResultsView> {
  final ScrollController _scrollController = ScrollController();
  static const double _scrollThreshold = 200.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - _scrollThreshold) {
      final bloc = context.read<StatisticsBloc>();
      final currentState = bloc.state;
      if (currentState is StatisticsLoaded &&
          !currentState.isLoadingMoreProcessSearch &&
          currentState.processSearchPagination?.hasNext == true &&
          currentState.processSearchPagination?.nextCursor != null) {
        bloc.add(const LoadMoreSearchProcessesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isSearchingProcesses && state.processSearchResults.isEmpty) {
      return const Column(
        children: [
          CustomSkeletonLoader(width: double.infinity, height: 110),
          SizedBox(height: 12),
          CustomSkeletonLoader(width: double.infinity, height: 110),
          SizedBox(height: 12),
          CustomSkeletonLoader(width: double.infinity, height: 110),
        ],
      );
    }

    if (state.processSearchErrorMessage != null &&
        state.processSearchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: _cardDecoration(),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert,
                color: AppColors.umber, size: 42),
            const SizedBox(height: 14),
            Text(
              'حدث خطأ أثناء البحث',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: AppTextStyles.bold,
                color: AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.processSearchErrorMessage!,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.goldDark),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: widget.onRetry,
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forest,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state.processSearchResults.isEmpty) {
      return AppEmptySearchState(
        title: 'لا توجد نتائج تطابق بحثك',
        description:
            'تأكد من كتابة اسم المعاملة أو رمزها بشكل صحيح وحاول مرة أخرى.',
        action: AppBackButton(
          label: 'العودة للإحصائيات',
          onPressed: widget.onClear,
        ),
      );
    }

    final hasNext = state.processSearchPagination?.hasNext == true;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.workflow,
                  color: AppColors.forest, size: 20),
              const SizedBox(width: 8),
              Text(
                'نتائج البحث عن «${state.processSearchQuery}»',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(width: 10),
              _Pill(
                text: '${state.processSearchResults.length} معاملة',
                color: AppColors.forest,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.onClear,
                icon: const Icon(LucideIcons.x, size: 16),
                label: const Text('إلغاء البحث'),
                style:
                    TextButton.styleFrom(foregroundColor: AppColors.goldDark),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.goldLight),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              itemCount: state.processSearchResults.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.processSearchResults.length) {
                  if (state.isLoadingMoreProcessSearch) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    );
                  }
                  if (hasNext) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context
                                .read<StatisticsBloc>()
                                .add(const LoadMoreSearchProcessesEvent());
                          },
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('تحميل المزيد من النتائج'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.forest,
                            side: const BorderSide(color: AppColors.forest),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'تم عرض جميع المعاملات',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }

                final process = state.processSearchResults[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 250),
                  delay: Duration(milliseconds: (index % 6) * 35),
                  child: _ProcessSearchResultCard(process: process),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessSearchResultCard extends StatelessWidget {
  final ProcessSearchItemEntity process;

  const _ProcessSearchResultCard({required this.process});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.forest.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(
              LucideIcons.workflow,
              color: AppColors.forest,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        process.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (process.isComplaint) ...[
                      const SizedBox(width: 8),
                      const _Pill(
                        text: 'شكوى',
                        color: AppColors.umber,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'الرمز: ${process.code}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.goldDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (process.typeTransName.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Text(
                        '•  ${process.typeTransName}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.forest,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (process.organizationName.isNotEmpty)
                  Row(
                    children: [
                      const Icon(LucideIcons.building,
                          size: 14, color: AppColors.goldDark),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          process.organizationName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoalDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.flag,
                        size: 14, color: AppColors.goldDark),
                    const SizedBox(width: 6),
                    Text(
                      'الأولوية: ${process.priorityLabel}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.charcoalDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Pill(
            text: process.isActive ? 'معتمد / نشط' : 'غير نشط',
            color: process.isActive ? AppColors.forest : AppColors.goldDark,
          ),
        ],
      ),
    );
  }
}

class _ProcessDefaultStatsView extends StatefulWidget {
  final List<StatisticsProcessEntity> processes;
  final StatisticsSectionStatus status;
  final String? fromDate;
  final String? toDate;
  final StatisticsPaginationEntity? pagination;
  final bool isLoadingMore;
  final String? loadMoreErrorMessage;

  const _ProcessDefaultStatsView({
    required this.processes,
    required this.status,
    required this.fromDate,
    required this.toDate,
    this.pagination,
    this.isLoadingMore = false,
    this.loadMoreErrorMessage,
  });

  @override
  State<_ProcessDefaultStatsView> createState() =>
      _ProcessDefaultStatsViewState();
}

class _ProcessDefaultStatsViewState extends State<_ProcessDefaultStatsView> {
  _ProcessMetricFilter? _activeFilter;

  void _toggleFilter(_ProcessMetricFilter filter) {
    setState(() {
      _activeFilter = _activeFilter == filter ? null : filter;
    });
  }

  void _pickDateRange(BuildContext context) {
    DeptTxDateRangePickerDialog.show(
      context: context,
      initialFromDate: widget.fromDate,
      initialToDate: widget.toDate,
      onApply: (from, to) {
        context.read<StatisticsBloc>().add(
              ApplyProcessDateFilter(
                fromDate: from,
                toDate: to,
              ),
            );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilter = null;
    });
    if (widget.fromDate != null || widget.toDate != null) {
      context.read<StatisticsBloc>().add(
            const ApplyProcessDateFilter(fromDate: null, toDate: null),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status != StatisticsSectionStatus.success) {
      return _StatisticsSectionState(
        status: widget.status,
        emptyMessage: 'لا توجد بيانات معاملات متاحة حالياً',
      );
    }
    final processes = widget.processes;
    final pending = processes.fold<int>(
      0,
      (sum, item) => sum + item.pendingPickup,
    );
    final progress =
        processes.fold<int>(0, (sum, item) => sum + item.inProgress);
    final completed =
        processes.fold<int>(0, (sum, item) => sum + item.completed);
    final rejected = processes.fold<int>(0, (sum, item) => sum + item.rejected);
    final visibleProcesses = _filteredProcesses(processes);
    final hasActiveFilter =
        (widget.fromDate != null && widget.toDate != null) ||
            _activeFilter != null;
    final hasNext = widget.pagination?.hasNext == true;

    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProcessDateFilterBar(
            fromDate: widget.fromDate,
            toDate: widget.toDate,
            hasActiveFilter: hasActiveFilter,
            activeFilterLabel: _activeFilter != null
                ? _filterLabel(_activeFilter!)
                : null,
            onPickRange: () => _pickDateRange(context),
            onResetFilters: _clearAllFilters,
          ),
          const SizedBox(height: 16),
          _MetricsGrid(
            cards: [
              _Metric('بانتظار الاستلام', '$pending', LucideIcons.inbox,
                  Colors.blue.shade700,
                  filter: _ProcessMetricFilter.pending),
              _Metric('قيد المعالجة', '$progress', LucideIcons.loaderCircle,
                  AppColors.goldDark,
                  filter: _ProcessMetricFilter.inProgress),
              _Metric('منجزة', '$completed', LucideIcons.circleCheck,
                  AppColors.forest,
                  filter: _ProcessMetricFilter.completed),
              _Metric(
                'مرفوضة',
                '$rejected',
                LucideIcons.circleX,
                AppColors.umber,
                filter: _ProcessMetricFilter.rejected,
              ),
            ],
            selectedFilter: _activeFilter,
            onMetricTap: _toggleFilter,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _Panel(
              title: 'إحصائيات أنواع المعاملات',
              subtitle: _activeFilter == null
                  ? 'حالة العمليات حسب تعريف المعاملة'
                  : 'تصفية حسب: ${_filterLabel(_activeFilter!)}',
              icon: LucideIcons.workflow,
              expandChild: true,
              child: visibleProcesses.isEmpty
                  ? const _EmptyState(text: 'لا توجد معاملات ضمن هذا التصنيف')
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: visibleProcesses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == visibleProcesses.length) {
                          if (widget.isLoadingMore) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.forest,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (widget.loadMoreErrorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.loadMoreErrorMessage!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.umber,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      context.read<StatisticsBloc>().add(
                                            const RetryStatisticsProcessesLoadMore(),
                                          );
                                    },
                                    icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                    label: const Text('إعادة المحاولة'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.forest,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          if (hasNext) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.read<StatisticsBloc>().add(
                                          const LoadMoreStatisticsProcesses(),
                                        );
                                  },
                                  icon: const Icon(LucideIcons.plus, size: 16),
                                  label: const Text('تحميل المزيد من المعاملات'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.forest,
                                    side: const BorderSide(
                                        color: AppColors.forest),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Center(
                                child: Text(
                                  'تم عرض جميع المعاملات (${widget.processes.length})',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.charcoal.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            );
                          }
                          return FadeInUp(
                            duration: const Duration(milliseconds: 320),
                            delay: Duration(milliseconds: (index % 6) * 45),
                            child: _ProcessRow(process: visibleProcesses[index]),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }

  List<StatisticsProcessEntity> _filteredProcesses(
    List<StatisticsProcessEntity> processes,
  ) {
    final filter = _activeFilter;
    if (filter == null) return processes;

    return processes.where((process) {
      return switch (filter) {
        _ProcessMetricFilter.pending => process.pendingPickup > 0,
        _ProcessMetricFilter.inProgress => process.inProgress > 0,
        _ProcessMetricFilter.completed => process.completed > 0,
        _ProcessMetricFilter.rejected => process.rejected > 0,
      };
    }).toList();
  }
}

class _ProcessDateFilterBar extends StatelessWidget {
  final String? fromDate;
  final String? toDate;
  final bool hasActiveFilter;
  final String? activeFilterLabel;
  final VoidCallback onPickRange;
  final VoidCallback onResetFilters;

  const _ProcessDateFilterBar({
    required this.fromDate,
    required this.toDate,
    required this.hasActiveFilter,
    this.activeFilterLabel,
    required this.onPickRange,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasDateFilter = fromDate != null && toDate != null;
    final label =
        hasDateFilter ? '$fromDate إلى $toDate' : 'اختيار فترة الإحصائيات';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickRange,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: hasDateFilter
                        ? AppColors.forest.withValues(alpha: 0.08)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasDateFilter
                          ? AppColors.forest
                          : AppColors.gold.withValues(alpha: 0.4),
                      width: hasDateFilter ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasDateFilter
                            ? LucideIcons.calendarCheck
                            : LucideIcons.calendar,
                        color: AppColors.forest,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: hasDateFilter
                              ? FontWeight.w700
                              : AppTextStyles.medium,
                          color: hasDateFilter
                              ? AppColors.forestDark
                              : AppColors.charcoalDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (activeFilterLabel != null) ...[
              const SizedBox(width: 10),
              _Pill(
                text: 'تصنيف: $activeFilterLabel',
                color: AppColors.forest,
              ),
            ],
          ],
        ),
        if (hasActiveFilter)
          FadeIn(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onResetFilters,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.umber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.umber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.rotateCcw,
                        size: 15,
                        color: AppColors.umber,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'إلغاء الفلترة',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.umber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<_Metric> cards;
  final _ProcessMetricFilter? selectedFilter;
  final ValueChanged<_ProcessMetricFilter>? onMetricTap;

  const _MetricsGrid({
    required this.cards,
    this.selectedFilter,
    this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 640) {
          return Row(
            children: cards.asMap().entries.map((entry) {
              final isLast = entry.key == cards.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: isLast ? 0 : 12),
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: entry.key * 40),
                    child: _MetricCard(
                      entry.value,
                      selected: entry.value.filter != null &&
                          entry.value.filter == selectedFilter,
                      onTap: entry.value.filter == null || onMetricTap == null
                          ? null
                          : () => onMetricTap!(entry.value.filter!),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cards.asMap().entries.map((entry) {
              final isLast = entry.key == cards.length - 1;
              return Padding(
                padding: EdgeInsets.only(left: isLast ? 0 : 12),
                child: SizedBox(
                  width: 175,
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    delay: Duration(milliseconds: entry.key * 40),
                    child: _MetricCard(
                      entry.value,
                      selected: entry.value.filter != null &&
                          entry.value.filter == selectedFilter,
                      onTap: entry.value.filter == null || onMetricTap == null
                          ? null
                          : () => onMetricTap!(entry.value.filter!),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _Metric data;
  final bool selected;
  final VoidCallback? onTap;

  const _MetricCard(
    this.data, {
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: selected
              ? _cardDecoration(
                  borderColor: data.color.withValues(alpha: 0.6),
                  backgroundColor: data.color.withValues(alpha: 0.08),
                )
              : _cardDecoration(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _IconBox(icon: data.icon, color: data.color),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.value,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: data.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        data.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: selected ? data.color : AppColors.goldDark,
                          fontWeight:
                              selected ? FontWeight.bold : AppTextStyles.medium,
                          fontSize: 12,
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
    );
  }
}

String _filterLabel(_ProcessMetricFilter filter) {
  return switch (filter) {
    _ProcessMetricFilter.pending => 'بانتظار الاستلام',
    _ProcessMetricFilter.inProgress => 'قيد المعالجة',
    _ProcessMetricFilter.completed => 'منجزة',
    _ProcessMetricFilter.rejected => 'مرفوضة',
  };
}

enum _ProcessMetricFilter {
  pending,
  inProgress,
  completed,
  rejected,
}

class _EmployeeRow extends StatelessWidget {
  final StatisticsEmployeeEntity employee;

  const _EmployeeRow({required this.employee});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        final employeeId = employee.employeeId;
        if (employeeId == null) {
          AppSnackBar.show(
            context,
            message: 'لم يُرجع الخادم employee_id لهذا الموظف',
            isError: true,
          );
          return;
        }
        context.push('/statistics/employees/$employeeId');
      },
      child: _DataRowShell(
        child: Row(
          children: [
            _Avatar(name: employee.fullName),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: _TitleSubtitle(
                title: employee.fullName,
                subtitle: '${employee.departmentName} - ${employee.roleName}',
              ),
            ),
            _MiniStat('بانتظار', employee.pendingPickup.toString()),
            _MiniStat('قيد العمل', employee.inProgress.toString()),
            _MiniStat('منجزة', employee.completed.toString()),
            Expanded(
              flex: 2,
              child: _WorkloadBar(percent: employee.workloadPercent),
            ),
            const SizedBox(width: 12),
            _Pill(
              text: employee.statusLabel,
              color: _employeeStatusColor(employee),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessRow extends StatelessWidget {
  final StatisticsProcessEntity process;

  const _ProcessRow({required this.process});

  @override
  Widget build(BuildContext context) {
    final total = process.pendingPickup +
        process.inProgress +
        process.completed +
        process.rejected;

    return _DataRowShell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _IconBox(icon: LucideIcons.fileStack, color: AppColors.forest),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: _TitleSubtitle(
              title: process.processName,
              subtitle:
                  '${process.transactionTypeName} - ${process.processCode}',
            ),
          ),
          _MiniStat('بانتظار', process.pendingPickup.toString()),
          _MiniStat('منجزة', process.completed.toString()),
          _MiniStat('مرفوضة', process.rejected.toString()),
          _Pill(
            text: 'الضغط الحالي ${process.pendingPickup + process.inProgress}',
            color: _processLoadColor(process),
          ),
          const SizedBox(width: 8),
          _Pill(text: 'الإجمالي $total', color: AppColors.forest),
        ],
      ),
    );
  }
}

class _InsightsPanel extends StatelessWidget {
  final List<StatisticsEmployeeEntity> employees;

  const _InsightsPanel({required this.employees});

  @override
  Widget build(BuildContext context) {
    final sorted = [...employees]
      ..sort((a, b) => b.workloadPercent.compareTo(a.workloadPercent));
    final highest = sorted.isNotEmpty ? sorted.first : null;
    StatisticsEmployeeEntity? available;
    for (final employee in employees) {
      if (employee.activeTotal == 0) {
        available = employee;
        break;
      }
    }

    return _Panel(
      title: 'قراءة سريعة',
      subtitle: 'مؤشرات تساعد المدير على توزيع العمل',
      icon: LucideIcons.sparkles,
      child: Column(
        children: [
          _Insight(
            icon: LucideIcons.alertTriangle,
            title: 'أعلى ضغط عمل',
            text: highest == null
                ? 'لا توجد بيانات كافية'
                : '${highest.fullName} بنسبة ${highest.workloadPercent}%',
            color: AppColors.umber,
          ),
          const SizedBox(height: 12),
          _Insight(
            icon: LucideIcons.userRoundCheck,
            title: 'متاح للاستلام',
            text: available == null
                ? 'لا يوجد موظف بلا مهام نشطة حالياً'
                : '${available.fullName} لا يملك مهام نشطة حالياً',
            color: AppColors.forest,
          ),
          const SizedBox(height: 12),
          const _Insight(
            icon: LucideIcons.route,
            title: 'الفكرة',
            text: 'يمكن لاحقاً اقتراح تحويل المعاملات للموظف الأقل ضغطاً.',
            color: AppColors.goldDark,
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool expandChild;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.forest, size: 22),
              const SizedBox(width: 10),
              Expanded(child: _TitleSubtitle(title: title, subtitle: subtitle)),
            ],
          ),
          const SizedBox(height: 16),
          if (expandChild) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

class _DataRowShell extends StatelessWidget {
  final Widget child;

  const _DataRowShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.charcoal.withValues(alpha: 0.08)),
        ),
      ),
      child: child,
    );
  }
}

class _TitleSubtitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TitleSubtitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleSmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldDark),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.forest,
              fontWeight: AppTextStyles.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkloadBar extends StatelessWidget {
  final int percent;

  const _WorkloadBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent >= 70
        ? AppColors.umber
        : percent == 0
            ? AppColors.goldDark
            : AppColors.forest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$percent%',
          textAlign: TextAlign.left,
          style: AppTextStyles.labelLarge.copyWith(
            color: color,
            fontWeight: AppTextStyles.bold,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percent.clamp(0, 100) / 100,
            minHeight: 7,
            backgroundColor: AppColors.goldLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _Insight({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: _TitleSubtitle(title: title, subtitle: text)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;

  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.goldDark),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join();

    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        initials,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: AppTextStyles.bold,
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          color: color,
          fontWeight: AppTextStyles.bold,
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration({
  Color? borderColor,
  Color? backgroundColor,
}) {
  return BoxDecoration(
    color: backgroundColor ?? AppColors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: borderColor ?? AppColors.gold.withValues(alpha: 0.22),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.charcoal.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

Color _employeeStatusColor(StatisticsEmployeeEntity employee) {
  if (employee.status == 'overloaded') return AppColors.umber;
  if (employee.status == 'inactive') return AppColors.goldDark;
  return AppColors.forest;
}

Color _processLoadColor(StatisticsProcessEntity process) {
  final load = process.pendingPickup + process.inProgress;
  if (load >= 10) return AppColors.umber;
  if (load > 0) return AppColors.goldDark;
  return AppColors.forest;
}

class _Metric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final _ProcessMetricFilter? filter;

  const _Metric(
    this.label,
    this.value,
    this.icon,
    this.color, {
    this.filter,
  });
}
