import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../bloc/my_transactions_bloc.dart';
import '../bloc/my_transactions_event.dart';
import '../bloc/my_transactions_state.dart';
import '../widgets/my_tx_alert_banner.dart';
import '../widgets/my_tx_filter_bar.dart';
import '../widgets/my_tx_table.dart';

class MyTransactionsPage extends StatefulWidget {
  const MyTransactionsPage({super.key});

  @override
  State<MyTransactionsPage> createState() => _MyTransactionsPageState();
}

class _MyTransactionsPageState extends State<MyTransactionsPage> {
  late final ScrollController _scrollController;
  static const double contentPadding = 32;
  static const double gap = 20;
  static const double _scrollThreshold = 200;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    context.read<MyTransactionsBloc>().add(const LoadMyTransactions());
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
      final bloc = context.read<MyTransactionsBloc>();
      final currentState = bloc.state;
      if (currentState is MyTransactionsLoaded &&
          !currentState.isLoadingMore &&
          currentState.hasMore) {
        bloc.add(LoadMoreTransactions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTransactionsBloc, MyTransactionsState>(
      builder: (context, state) {
        // تحديد القيم حتى أثناء التحميل لعرض العناصر الثابتة
        String searchQuery = '';
        String statusFilter = 'all';
        int awaitingCount = 0;
        int urgentCount = 0;

        if (state is MyTransactionsLoaded) {
          searchQuery = state.searchQuery;
          statusFilter = state.statusFilter;
          awaitingCount = state.awaitingSignatureCount;
          urgentCount = state.urgentCount;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
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
                    // Header Title Section (ثابت)
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'معاملاتي',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.displayMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'المعاملات الموجهة إليك — $awaitingCount بانتظار الاستلام',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.goldDark),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                            ),
                            child: IconButton(
                              onPressed: () {
                                context.read<MyTransactionsBloc>().add(const LoadMyTransactions());
                              },
                              icon: const Icon(LucideIcons.refreshCw, color: AppColors.forest),
                              tooltip: 'تحديث البيانات',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Search & Filter Bar (ثابت)
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      delay: const Duration(milliseconds: 100),
                      child: IgnorePointer(
                        ignoring: state is MyTransactionsLoading || state is MyTransactionsInitial,
                        child: MyTxFilterBar(
                          activeFilter: statusFilter,
                          searchQuery: searchQuery,
                          onFilterChanged: (filter) {
                            context
                                .read<MyTransactionsBloc>()
                                .add(FilterMyTransactions(filter));
                          },
                          onSearchChanged: (query) {
                            context
                                .read<MyTransactionsBloc>()
                                .add(SearchMyTransactions(query));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: gap),

                    // Alert Banner (if urgent transactions exist)
                    if (urgentCount > 0)
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        delay: const Duration(milliseconds: 150),
                        child: Column(
                          children: [
                            MyTxAlertBanner(urgentCount: urgentCount),
                            const SizedBox(height: gap),
                          ],
                        ),
                      ),

                    // Dynamic Content (Skeleton OR Error OR Data)
                    if (state is MyTransactionsLoading ||
                        state is MyTransactionsInitial)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: const ListSkeletonLoader(
                          itemCount: 6,
                          itemHeight: 70, // يطابق ارتفاع صف الجدول تقريباً
                        ),
                      )
                    else if (state is MyTransactionsFailure)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: AppErrorWidget(
                          onRetry: () {
                            context
                                .read<MyTransactionsBloc>()
                                .add(const LoadMyTransactions());
                          },
                        ),
                      )
                    else if (state is MyTransactionsLoaded)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: MyTxTable(
                          transactions: state.transactions,
                          activeFilter: state.statusFilter,
                          searchQuery: state.searchQuery,
                          isLoadingMore: state.isLoadingMore,
                          hasMore: state.hasMore,
                          onSign: (number) {
                            context
                                .read<MyTransactionsBloc>()
                                .add(SignTransaction(number));
                          },
                          onReject: (number) {
                            context
                                .read<MyTransactionsBloc>()
                                .add(RejectTransaction(number));
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
