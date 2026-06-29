import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../bloc/dept_tx_bloc.dart';
import '../bloc/dept_tx_event.dart';
import '../bloc/dept_tx_state.dart';
import '../widgets/dept_tx_filter_bar.dart';
import '../widgets/dept_tx_stats_card.dart';
import '../widgets/dept_tx_table.dart';

class DepartmentTransactionsPage extends StatelessWidget {
  const DepartmentTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeptTxBloc>(
      create: (_) => getIt<DeptTxBloc>()..add(LoadDeptTx()),
      child: const _DepartmentTransactionsView(),
    );
  }
}

class _DepartmentTransactionsView extends StatelessWidget {
  const _DepartmentTransactionsView();

  static const double contentPadding = 32;
  static const double gap = 20;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeptTxBloc, DeptTxState>(
      builder: (context, state) {
        if (state is DeptTxLoading || state is DeptTxInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.forest,
            ),
          );
        }

        if (state is DeptTxFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<DeptTxBloc>().add(LoadDeptTx());
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

        if (state is DeptTxLoaded) {
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
                      // Header Title Section
                      FadeInDown(
                        duration: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'معاملات الدائرة',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.displayMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'جميع المعاملات الجارية والمنجزة ضمن الدائرة — للعرض والمتابعة فقط',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark.withOpacity(0.85)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Stats Cards Row
                      FadeInUp(
                        duration: const Duration(milliseconds: 450),
                        delay: const Duration(milliseconds: 80),
                        child: isSmall
                            ? Column(
                                children: [
                                  DeptTxStatsCard(
                                    value: '${state.totalCount}',
                                    label: 'الإجمالي',
                                    valueColor: AppColors.charcoalDark,
                                  ),
                                  const SizedBox(height: gap),
                                  DeptTxStatsCard(
                                    value: '${state.pendingCount}',
                                    label: 'قيد الانتظار',
                                    valueColor: Colors.blue.shade700,
                                  ),
                                  const SizedBox(height: gap),
                                  DeptTxStatsCard(
                                    value: '${state.processingCount}',
                                    label: 'قيد المعالجة',
                                    valueColor: AppColors.goldDark,
                                  ),
                                  const SizedBox(height: gap),
                                  DeptTxStatsCard(
                                    value: '${state.completedCount}',
                                    label: 'منجزة',
                                    valueColor: AppColors.forest,
                                  ),
                                ],
                              )
                            : Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: DeptTxStatsCard(
                                      value: '${state.totalCount}',
                                      label: 'الإجمالي',
                                      valueColor: AppColors.charcoalDark,
                                    ),
                                  ),
                                  const SizedBox(width: gap),
                                  Expanded(
                                    child: DeptTxStatsCard(
                                      value: '${state.pendingCount}',
                                      label: 'قيد الانتظار',
                                      valueColor: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: gap),
                                  Expanded(
                                    child: DeptTxStatsCard(
                                      value: '${state.processingCount}',
                                      label: 'قيد المعالجة',
                                      valueColor: AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(width: gap),
                                  Expanded(
                                    child: DeptTxStatsCard(
                                      value: '${state.completedCount}',
                                      label: 'منجزة',
                                      valueColor: AppColors.forest,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 32),

                      // Search & Filter Bar
                      FadeInUp(
                        duration: const Duration(milliseconds: 450),
                        delay: const Duration(milliseconds: 140),
                        child: DeptTxFilterBar(
                          activeStatusFilter: state.statusFilter,
                          activeClassificationFilter: state.classificationFilter,
                          searchQuery: state.searchQuery,
                          onStatusFilterChanged: (filter) {
                            context.read<DeptTxBloc>().add(FilterDeptTxByStatus(filter));
                          },
                          onClassificationFilterChanged: (filter) {
                            context.read<DeptTxBloc>().add(FilterDeptTxByClassification(filter));
                          },
                          onSearchChanged: (query) {
                            context.read<DeptTxBloc>().add(SearchDeptTx(query));
                          },
                        ),
                      ),
                      const SizedBox(height: gap),

                      // Transactions Table
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 220),
                        child: DeptTxTable(
                          transactions: state.filteredTransactions,
                        ),
                      ),
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
