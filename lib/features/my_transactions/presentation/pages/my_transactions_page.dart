import '../../../../shared/theme/app_text_styles.dart';
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

class MyTransactionsPage extends StatefulWidget {
  const MyTransactionsPage({super.key});

  @override
  State<MyTransactionsPage> createState() => _MyTransactionsPageState();
}

class _MyTransactionsPageState extends State<MyTransactionsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MyTransactionsBloc>().add(LoadMyTransactions());
  }

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
                  style: AppTextStyles.titleMedium,
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
                        style: AppTextStyles.displayMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'المعاملات الموجهة إليك — ${state.awaitingSignatureCount} بانتظار الاستلام',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark),
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
