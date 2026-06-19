import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../bloc/my_transactions_bloc.dart';
import '../bloc/my_transactions_event.dart';
import '../bloc/my_transactions_state.dart';
import '../widgets/my_tx_alert_banner.dart';
import '../widgets/my_tx_filter_bar.dart';
import '../widgets/my_tx_table.dart';

class MyTransactionsPage extends StatelessWidget {
  const MyTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTransactionsBloc, MyTransactionsState>(
      builder: (context, state) {
        if (state is MyTransactionsLoading || state is MyTransactionsInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.forest,
            ),
          );
        }

        if (state is MyTransactionsFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(
                      color: AppColors.charcoalDark, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<MyTransactionsBloc>()
                        .add(LoadMyTransactions());
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

        if (state is MyTransactionsLoaded) {
          return MyTransactionsContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class MyTransactionsContent extends StatelessWidget {
  final MyTransactionsLoaded state;

  const MyTransactionsContent({
    super.key,
    required this.state,
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
                // Header Title Section
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'معاملاتي',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 30,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'المعاملات الموجهة إليك — ${state.awaitingSignatureCount} بانتظار الاستلام',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.2,
                          fontWeight: FontWeight.w400,
                          color: AppColors.goldDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Search & Filter Bar
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: MyTxFilterBar(
                    activeFilter: state.statusFilter,
                    searchQuery: state.searchQuery,
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
                const SizedBox(height: gap),

                // Alert Banner (if urgent transactions exist)
                if (state.urgentCount > 0)
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 150),
                    child: Column(
                      children: [
                        MyTxAlertBanner(urgentCount: state.urgentCount),
                        const SizedBox(height: gap),
                      ],
                    ),
                  ),

                // Transactions Table
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  delay: const Duration(milliseconds: 200),
                  child: MyTxTable(
                    transactions: state.filteredTransactions,
                    activeFilter: state.statusFilter,
                    searchQuery: state.searchQuery,
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
  }
}
