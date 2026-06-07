import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dashboard_entity.dart';
import 'alerts_card.dart';
import 'bottleneck_card.dart';
import 'completion_time_card.dart';
import 'latest_transactions_table.dart';
import 'quick_actions_card.dart';
import 'side_menu.dart';
import 'stat_card.dart';
import 'top_bar.dart';
import 'weekly_indicators_card.dart';

class AppShell extends StatelessWidget {
  final DashboardEntity dashboard;

  const AppShell({
    super.key,
    required this.dashboard,
  });

  static const double sidebarWidth = 255;
  static const double contentPadding = 32;
  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 1050;
          final showSideBelow = constraints.maxWidth < 900;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const TopBar(),
              Expanded(
                child: SingleChildScrollView(
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
                        const _Header(),
                        const SizedBox(height: 32),

                        if (isSmall)
                          Wrap(
                            spacing: gap,
                            runSpacing: gap,
                            children: dashboard.stats.map((e) {
                              return SizedBox(
                                width: 245,
                                height: 135,
                                child: StatCard(stat: e),
                              );
                            }).toList(),
                          )
                        else
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(child: StatCard(stat: dashboard.stats[0])),
                              const SizedBox(width: gap),
                              Expanded(child: StatCard(stat: dashboard.stats[1])),
                              const SizedBox(width: gap),
                              Expanded(child: StatCard(stat: dashboard.stats[2])),
                              const SizedBox(width: gap),
                              Expanded(child: StatCard(stat: dashboard.stats[3])),
                            ],
                          ),

                        const SizedBox(height: 32),

                        if (isSmall)
                          Column(
                            children: [
                              BottleneckCard(items: dashboard.bottlenecks),
                              const SizedBox(height: gap),
                              CompletionTimeCard(completionTime: dashboard.completionTime),
                              const SizedBox(height: gap),
                              WeeklyIndicatorsCard(indicators: dashboard.weeklyIndicators),
                            ],
                          )
                        else
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: BottleneckCard(items: dashboard.bottlenecks)),
                              const SizedBox(width: gap),
                              Expanded(child: CompletionTimeCard(completionTime: dashboard.completionTime)),
                              const SizedBox(width: gap),
                              Expanded(child: WeeklyIndicatorsCard(indicators: dashboard.weeklyIndicators)),
                            ],
                          ),

                        const SizedBox(height: 32),

                        if (isSmall)
                          Column(
                            children: [
                              const QuickActionsCard(),
                              const SizedBox(height: gap),
                              AlertsCard(alerts: dashboard.alerts),
                              const SizedBox(height: gap),
                              LatestTransactionsTable(transactions: dashboard.latestTransactions),
                            ],
                          )
                        else
                          Row(
                            textDirection: TextDirection.rtl,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 335,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const QuickActionsCard(),
                                    const SizedBox(height: 16),
                                    AlertsCard(alerts: dashboard.alerts),
                                  ],
                                ),
                              ),
                              const SizedBox(width: gap),
                              Expanded(
                                child: LatestTransactionsTable(
                                  transactions: dashboard.latestTransactions,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );

          return showSideBelow
              ? Column(
                  children: [
                    Expanded(child: content),
                    const SizedBox(height: gap),
                    const SizedBox(width: double.infinity, child: SideMenu()),
                  ],
                )
              : Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(child: content),
                    const SizedBox(
                      width: sidebarWidth,
                      child: SideMenu(),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة رئيس الدائرة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: AppColors.forest,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'الأحد، 31 يناير 2024 — نظرة شاملة على معاملات الدائرة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w400,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}