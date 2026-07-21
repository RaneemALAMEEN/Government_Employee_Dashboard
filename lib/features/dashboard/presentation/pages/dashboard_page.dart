import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
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
                BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _DashboardSkeleton(isSmall: isSmall);
                    }

                    if (state is DashboardFailure) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: AppErrorWidget(
                          onRetry: () {
                            context.read<DashboardBloc>().add(LoadDashboardEvent());
                          },
                        ),
                      );
                    }

                    if (state is DashboardLoaded) {
                      return _DashboardBody(
                        dashboard: state.dashboard,
                        isSmall: isSmall,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardEntity dashboard;
  final bool isSmall;

  const _DashboardBody({
    required this.dashboard,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSmall)
          FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: Wrap(
              spacing: DashboardPage.gap,
              runSpacing: DashboardPage.gap,
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
              const SizedBox(width: DashboardPage.gap),
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                  child: StatCard(stat: dashboard.stats[1]),
                ),
              ),
              const SizedBox(width: DashboardPage.gap),
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300),
                  child: StatCard(stat: dashboard.stats[2]),
                ),
              ),
              const SizedBox(width: DashboardPage.gap),
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
                CompletionTimeCard(
                  completionTime: dashboard.completionTime,
                ),
                const SizedBox(height: DashboardPage.gap),
                BottleneckCard(
                  items: dashboard.bottlenecks,
                ),
                const SizedBox(height: DashboardPage.gap),
                WeeklyIndicatorsCard(
                  indicators: dashboard.weeklyIndicators,
                ),
              ],
            ),
          )
        else
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      CompletionTimeCard(
                        completionTime: dashboard.completionTime,
                      ),
                      const SizedBox(height: DashboardPage.gap),
                      BottleneckCard(
                        items: dashboard.bottlenecks,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DashboardPage.gap),
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
                const SizedBox(height: DashboardPage.gap),
                AlertsCard(alerts: dashboard.alerts),
                const SizedBox(height: DashboardPage.gap),
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
              const SizedBox(width: DashboardPage.gap),
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
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  final bool isSmall;

  const _DashboardSkeleton({required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Stats Row
        if (isSmall)
          Wrap(
            spacing: DashboardPage.gap,
            runSpacing: DashboardPage.gap,
            children: List.generate(
              4,
              (index) => const SizedBox(
                width: 245,
                height: 135,
                child: CustomSkeletonLoader(width: 245, height: 135),
              ),
            ),
          )
        else
          Row(
            children: List.generate(
              4,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: index == 3 ? 0 : DashboardPage.gap),
                  child: const CustomSkeletonLoader(
                      width: double.infinity, height: 135),
                ),
              ),
            ),
          ),

        const SizedBox(height: 32),

        // 2. Charts Row
        if (isSmall)
          const Column(
            children: [
              CustomSkeletonLoader(width: double.infinity, height: 250),
              SizedBox(height: DashboardPage.gap),
              CustomSkeletonLoader(width: double.infinity, height: 250),
              SizedBox(height: DashboardPage.gap),
              CustomSkeletonLoader(width: double.infinity, height: 400),
            ],
          )
        else
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    CustomSkeletonLoader(width: double.infinity, height: 250),
                    SizedBox(height: DashboardPage.gap),
                    CustomSkeletonLoader(width: double.infinity, height: 250),
                  ],
                ),
              ),
              SizedBox(width: DashboardPage.gap),
              Expanded(
                child: CustomSkeletonLoader(width: double.infinity, height: 520),
              ),
            ],
          ),

        const SizedBox(height: 32),

        // 3. Quick Actions & Table Row
        if (isSmall)
          const Column(
            children: [
              CustomSkeletonLoader(width: double.infinity, height: 150),
              SizedBox(height: DashboardPage.gap),
              CustomSkeletonLoader(width: double.infinity, height: 150),
              SizedBox(height: DashboardPage.gap),
              CustomSkeletonLoader(width: double.infinity, height: 400),
            ],
          )
        else
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 335,
                child: Column(
                  children: [
                    CustomSkeletonLoader(width: double.infinity, height: 150),
                    SizedBox(height: 16),
                    CustomSkeletonLoader(width: double.infinity, height: 150),
                  ],
                ),
              ),
              SizedBox(width: DashboardPage.gap),
              Expanded(
                child: CustomSkeletonLoader(width: double.infinity, height: 400),
              ),
            ],
          ),
      ],
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
          const SizedBox(height: 6),
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