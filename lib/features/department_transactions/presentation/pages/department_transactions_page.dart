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
      create: (_) => getIt<DeptTxBloc>()..add(const LoadDeptTx()),
      child: const _DepartmentTransactionsView(),
    );
  }
}

class _DepartmentTransactionsView extends StatefulWidget {
  const _DepartmentTransactionsView();

  @override
  State<_DepartmentTransactionsView> createState() => _DepartmentTransactionsViewState();
}

class _DepartmentTransactionsViewState extends State<_DepartmentTransactionsView> {
  static const double contentPadding = 32;
  static const double gap = 20;
  
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<DeptTxBloc>().add(LoadMoreDeptTx());
    }
  }

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
                    context.read<DeptTxBloc>().add(const LoadDeptTx());
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
                controller: _scrollController,
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
                                    label: 'الإجمالي (${state.statusFilter})',
                                    valueColor: AppColors.charcoalDark,
                                  ),
                                ],
                              )
                            : Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Expanded(
                                    child: DeptTxStatsCard(
                                      value: '${state.totalCount}',
                                      label: 'الإجمالي (${state.statusFilter})',
                                      valueColor: AppColors.charcoalDark,
                                    ),
                                  ),
                                  const SizedBox(width: gap),
                                  const Spacer(), // Placeholder for future stats
                                  const SizedBox(width: gap),
                                  const Spacer(),
                                  const SizedBox(width: gap),
                                  const Spacer(),
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
                          searchQuery: state.searchQuery,
                          fromDate: state.fromDate,
                          toDate: state.toDate,
                          onStatusFilterChanged: (filter) {
                            context.read<DeptTxBloc>().add(FilterDeptTxByStatus(filter));
                          },
                          onDateRangeChanged: (from, to) {
                            context.read<DeptTxBloc>().add(FilterDeptTxByDate(fromDate: from, toDate: to));
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
                          transactions: state.transactions,
                        ),
                      ),
                      
                      // Loading indicator at bottom
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.forest),
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
