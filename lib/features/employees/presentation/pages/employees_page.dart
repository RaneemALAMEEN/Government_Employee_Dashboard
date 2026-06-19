import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../bloc/employees_bloc.dart';
import '../bloc/employees_event.dart';
import '../bloc/employees_state.dart';
import '../widgets/dept_workload_card.dart';
import '../widgets/employees_stats_card.dart';
import '../widgets/employees_table.dart';
import '../widgets/workload_recommendations_card.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmployeesBloc>(
      create: (_) => getIt<EmployeesBloc>()..add(const LoadEmployees()),
      child: const _EmployeesView(),
    );
  }
}

class _EmployeesView extends StatelessWidget {
  const _EmployeesView();

  static const double contentPadding = 28;
  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesBloc, EmployeesState>(
      builder: (context, state) {
        if (state is EmployeesLoading || state is EmployeesInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.forest,
            ),
          );
        }

        if (state is EmployeesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: AppColors.charcoalDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<EmployeesBloc>().add(const LoadEmployees());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is EmployeesLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 1150;

              final mainPanel = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الموظفين',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.allEmployees.length} موظف في الدائرة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.goldDark.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  LayoutBuilder(
                    builder: (context, statsConstraints) {
                      final cardWidth = (statsConstraints.maxWidth - (3 * gap)) / 4;
                      final useColumns = statsConstraints.maxWidth < 650;

                      if (useColumns) {
                        return Column(
                          children: [
                            EmployeesStatsCard(
                              value: '${state.activeTxCount}',
                              label: 'معاملات نشطة',
                              icon: LucideIcons.clock,
                              iconColor: AppColors.forest,
                              iconBgColor: AppColors.forestLight.withOpacity(0.12),
                            ),
                            const SizedBox(height: gap),
                            EmployeesStatsCard(
                              value: '${state.doneTxCount}',
                              label: 'منجزة هذا الشهر',
                              icon: LucideIcons.checkCircle,
                              iconColor: AppColors.forest,
                              iconBgColor: AppColors.forestLight.withOpacity(0.12),
                            ),
                            const SizedBox(height: gap),
                            EmployeesStatsCard(
                              value: '${state.overburdenedCount}',
                              label: 'موظفون مثقلون',
                              icon: LucideIcons.trendingUp,
                              iconColor: AppColors.umberLight,
                              iconBgColor: AppColors.umber.withOpacity(0.1),
                            ),
                            const SizedBox(height: gap),
                            EmployeesStatsCard(
                              value: '${state.inactiveCount}',
                              label: 'موظفون غير نشطين',
                              icon: LucideIcons.trendingDown,
                              iconColor: AppColors.goldDark,
                              iconBgColor: AppColors.gold.withOpacity(0.15),
                            ),
                          ],
                        );
                      }

                      return Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: EmployeesStatsCard(
                              value: '${state.activeTxCount}',
                              label: 'معاملات نشطة',
                              icon: LucideIcons.clock,
                              iconColor: AppColors.forest,
                              iconBgColor: AppColors.forestLight.withOpacity(0.12),
                            ),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: EmployeesStatsCard(
                              value: '${state.doneTxCount}',
                              label: 'منجزة هذا الشهر',
                              icon: LucideIcons.checkCircle,
                              iconColor: AppColors.forest,
                              iconBgColor: AppColors.forestLight.withOpacity(0.12),
                            ),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: EmployeesStatsCard(
                              value: '${state.overburdenedCount}',
                              label: 'موظفون مثقلون',
                              icon: LucideIcons.trendingUp,
                              iconColor: AppColors.umberLight,
                              iconBgColor: AppColors.umber.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: EmployeesStatsCard(
                              value: '${state.inactiveCount}',
                              label: 'موظفون غير نشطين',
                              icon: LucideIcons.trendingDown,
                              iconColor: AppColors.goldDark,
                              iconBgColor: AppColors.gold.withOpacity(0.15),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Search Field
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: TextField(
                        onChanged: (val) {
                          context.read<EmployeesBloc>().add(SearchEmployees(val));
                        },
                        decoration: InputDecoration(
                          hintText: 'بحث في الموظفين...',
                          prefixIcon: const Icon(LucideIcons.search, color: AppColors.charcoal, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Table of employees
                  EmployeesTable(employees: state.filteredEmployees),
                ],
              );

              final sidePanel = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: getIt<SessionService>().activeRoleNotifier,
                    builder: (context, activeRole, _) {
                      final showWorkload = activeRole == 'مدير التربية' || activeRole == 'معاون مدير التربية';
                      if (!showWorkload) return const SizedBox.shrink();
                      return const Column(
                        children: [
                          DeptWorkloadCard(),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                  const WorkloadRecommendationsCard(),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  contentPadding,
                  contentPadding,
                  contentPadding,
                  36,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: mainPanel),
                            const SizedBox(width: 24),
                            SizedBox(width: 320, child: sidePanel),
                          ],
                        )
                      : Column(
                          children: [
                            mainPanel,
                            const SizedBox(height: 24),
                            sidePanel,
                          ],
                        ),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
