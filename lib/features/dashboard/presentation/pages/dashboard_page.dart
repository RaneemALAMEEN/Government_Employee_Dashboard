import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/alerts_card.dart';
import '../widgets/bottleneck_card.dart';
import '../widgets/completion_time_card.dart';
import '../widgets/latest_transactions_table.dart';
import '../widgets/quick_actions_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_indicators_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(LoadDashboardEvent());
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is DashboardLoaded) {
          return DashboardContent(dashboard: state.dashboard);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class DashboardContent extends StatelessWidget {
  final DashboardEntity dashboard;

  const DashboardContent({
    super.key,
    required this.dashboard,
  });

  static const double contentPadding = 32;
  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 1050;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            contentPadding,
            32,
            contentPadding,
            36,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: const _Header(),
                ),
                const SizedBox(height: 32),

                if (isSmall)
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 100),
                    child: Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: dashboard.stats.map((e) {
                        return SizedBox(
                          width: 245,
                          height: 135,
                          child: StatCard(stat: e),
                        );
                      }).toList(),
                    ),
                  )
                else
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 100),
                          child: StatCard(stat: dashboard.stats[0]),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 200),
                          child: StatCard(stat: dashboard.stats[1]),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 300),
                          child: StatCard(stat: dashboard.stats[2]),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          delay: const Duration(milliseconds: 400),
                          child: StatCard(stat: dashboard.stats[3]),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                if (isSmall)
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        BottleneckCard(items: dashboard.bottlenecks),
                        const SizedBox(height: gap),
                        CompletionTimeCard(
                          completionTime: dashboard.completionTime,
                        ),
                        const SizedBox(height: gap),
                        WeeklyIndicatorsCard(
                          indicators: dashboard.weeklyIndicators,
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 200),
                          child: BottleneckCard(items: dashboard.bottlenecks),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 300),
                          child: CompletionTimeCard(
                            completionTime: dashboard.completionTime,
                          ),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 400),
                          child: WeeklyIndicatorsCard(
                            indicators: dashboard.weeklyIndicators,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                if (isSmall)
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        const QuickActionsCard(),
                        const SizedBox(height: gap),
                        AlertsCard(alerts: dashboard.alerts),
                        const SizedBox(height: gap),
                        LatestTransactionsTable(
                          transactions: dashboard.latestTransactions,
                        ),
                      ],
                    ),
                  )
                else
                  Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 335,
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const QuickActionsCard(),
                              const SizedBox(height: 16),
                              AlertsCard(alerts: dashboard.alerts),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: gap),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          delay: const Duration(milliseconds: 400),
                          child: LatestTransactionsTable(
                            transactions: dashboard.latestTransactions,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة رئيس الدائرة',
            textAlign: TextAlign.right,
            style: AppTextStyles.displayMedium,
          ),
          SizedBox(height: 6),
          Text(
            'الأحد، 31 يناير 2024 — نظرة شاملة على معاملات الدائرة',
            textAlign: TextAlign.right,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.goldDark),
          ),
        ],
      ),
    );
  }
}