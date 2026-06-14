import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/services/api_service.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_remote_data_source.dart';
import '../../domain/entities/internal_transaction_counts_entity.dart';
import '../widgets/internal_processes_table.dart';
import '../widgets/internal_stats_section.dart';

class InternalTransactionsPage extends StatefulWidget {
  const InternalTransactionsPage({super.key});

  @override
  State<InternalTransactionsPage> createState() =>
      _InternalTransactionsPageState();
}

class _InternalTransactionsPageState extends State<InternalTransactionsPage> {
  final _dataSource = InternalTransactionsRemoteDataSource(
    getIt<ApiService>(),
  );

  InternalTransactionCountsEntity _counts =
      const InternalTransactionCountsEntity(
    total: 0,
    inProgress: 0,
    completed: 0,
  );

  bool _loadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final counts = await _dataSource.getMyTransactionCounts();

      if (!mounted) return;

      setState(() {
        _counts = counts;
        _loadingCounts = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loadingCounts = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          const SizedBox(height: 28),
          if (_loadingCounts)
            const SizedBox(
              height: 116,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.forest),
              ),
            )
          else
            InternalStatsSection(
              total: _counts.total,
              inProgress: _counts.inProgress,
              completed: _counts.completed,
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
