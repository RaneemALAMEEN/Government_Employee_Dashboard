import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/statistics_employee_entity.dart';
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
                if (state is StatisticsLoading || state is StatisticsInitial) {
                  return const SizedBox(
                    height: 620,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final loaded = state as StatisticsLoaded;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (loaded.isFallback) ...[
                      _WarningBanner(
                        message: loaded.warningMessage ??
                            'تعذر تحميل الإحصائيات من الخادم، يتم عرض بيانات تجريبية مؤقتة.',
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 760,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _EmployeeStatsView(employees: loaded.employees),
                          _TransactionStatsView(processes: loaded.processes),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            LucideIcons.chartNoAxesCombined,
            color: AppColors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإحصائيات',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.forest,
                  fontWeight: AppTextStyles.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'لوحة واحدة لمتابعة ضغط الموظفين وحالة المعاملات ضمن الدوائر.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {
            context.read<StatisticsBloc>().add(const RefreshStatistics());
          },
          icon: const Icon(LucideIcons.refreshCw, size: 17),
          label: const Text('تحديث'),
        ),
      ],
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

class _EmployeeStatsView extends StatelessWidget {
  final List<StatisticsEmployeeEntity> employees;

  const _EmployeeStatsView({required this.employees});

  @override
  Widget build(BuildContext context) {
    final active =
        employees.fold<int>(0, (sum, item) => sum + item.activeTotal);
    final completed =
        employees.fold<int>(0, (sum, item) => sum + item.completed);
    final overloaded =
        employees.where((item) => item.status == 'overloaded').length;
    final inactive =
        employees.where((item) => item.status == 'inactive').length;

    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
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
                  child: employees.isEmpty
                      ? const _EmptyState(text: 'لا توجد بيانات موظفين حالياً')
                      : Column(
                          children: employees.asMap().entries.map((entry) {
                            return FadeInUp(
                              duration: const Duration(milliseconds: 320),
                              delay: Duration(milliseconds: entry.key * 45),
                              child: _EmployeeRow(employee: entry.value),
                            );
                          }).toList(),
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
                          table,
                          const SizedBox(height: 20),
                          insights,
                        ],
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionStatsView extends StatefulWidget {
  final List<StatisticsProcessEntity> processes;

  const _TransactionStatsView({required this.processes});

  @override
  State<_TransactionStatsView> createState() => _TransactionStatsViewState();
}

class _TransactionStatsViewState extends State<_TransactionStatsView> {
  _ProcessMetricFilter? _activeFilter;

  void _toggleFilter(_ProcessMetricFilter filter) {
    setState(() {
      _activeFilter = _activeFilter == filter ? null : filter;
    });
  }

  @override
  Widget build(BuildContext context) {
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

    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              child: visibleProcesses.isEmpty
                  ? const _EmptyState(text: 'لا توجد معاملات ضمن هذا التصنيف')
                  : Column(
                      children: visibleProcesses.asMap().entries.map((entry) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 320),
                          delay: Duration(milliseconds: entry.key * 45),
                          child: _ProcessRow(process: entry.value),
                        );
                      }).toList(),
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
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
                ? 2
                : 1;
        final width = (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.asMap().entries.map((entry) {
            return FadeInUp(
              duration: const Duration(milliseconds: 350),
              delay: Duration(milliseconds: entry.key * 50),
              child: SizedBox(
                width: width,
                child: _MetricCard(
                  entry.value,
                  selected: entry.value.filter != null &&
                      entry.value.filter == selectedFilter,
                  onTap: entry.value.filter == null || onMetricTap == null
                      ? null
                      : () => onMetricTap!(entry.value.filter!),
                ),
              ),
            );
          }).toList(),
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
          height: 104,
          padding: const EdgeInsets.all(18),
          decoration: selected
              ? _cardDecoration(
                  borderColor: data.color.withValues(alpha: 0.55),
                  backgroundColor: data.color.withValues(alpha: 0.06),
                )
              : _cardDecoration(),
          child: Row(
            children: [
              _IconBox(icon: data.icon, color: data.color),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.value, style: AppTextStyles.displayMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selected) ...[
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: data.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        data.label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: selected ? data.color : AppColors.goldDark,
                          fontWeight: AppTextStyles.medium,
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
      onTap: () => context.go('/employees/${employee.id}'),
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
          _MiniStat('قيد العمل', process.inProgress.toString()),
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

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
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
          child,
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

class _WarningBanner extends StatelessWidget {
  final String message;

  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.info, color: AppColors.goldDark, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.goldDark,
                fontWeight: AppTextStyles.medium,
              ),
            ),
          ),
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
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color, size: 22),
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
