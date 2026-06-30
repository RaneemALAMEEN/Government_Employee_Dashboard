import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../bloc/internal_transactions_bloc.dart';
import '../bloc/internal_transactions_state.dart';
import '../widgets/internal_processes_table.dart';
import '../widgets/internal_stats_section.dart';

class InternalTransactionsPage extends StatelessWidget {
  const InternalTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          const SizedBox(height: 28),
          BlocBuilder<InternalTransactionsBloc, InternalTransactionsState>(
            builder: (context, state) {
              if (state.loadingCounts) {
                return const SizedBox(
                  height: 116,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.forest,
                    ),
                  ),
                );
              }

              return InternalStatsSection(
                total: state.counts.total,
                inProgress: state.counts.inProgress,
                completed: state.counts.completed,
              );
            },
          ),
          const SizedBox(height: 24),
          const InternalProcessesTable(),
        ],
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
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.start,
        spacing: 16,
        runSpacing: 16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المعاملات الداخلية',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.forest,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'المعاملات التي تنشئها وتديرها بنفسك',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.gold,
                    ),
              ),
            ],
          ),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/create-internal-transaction');
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('إنشاء معاملة جديدة'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                backgroundColor: AppColors.forest,
                foregroundColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
