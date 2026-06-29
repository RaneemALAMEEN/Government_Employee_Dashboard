import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../data/datasources/transactions_local_data_source.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/transaction_stats.dart';
import '../widgets/transactions_filters.dart';
import '../widgets/transactions_table.dart';
import '../widgets/urgent_warning_card.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _dataSource = TransactionsLocalDataSource();

  List<TransactionEntity> _transactions = [];
  String _selectedFilter = 'الكل';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _dataSource.getTransactions();

    if (!mounted) return;

    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  List<TransactionEntity> get _filteredTransactions {
    switch (_selectedFilter) {
      case 'بانتظار توقيعي':
        return _transactions
            .where((transaction) => transaction.status == 'بانتظار توقيعي')
            .toList();
      case 'منجزة':
        return _transactions
            .where((transaction) => transaction.status == 'منجزة')
            .toList();
      case 'تم الرفض':
        return _transactions
            .where((transaction) => transaction.status == 'تم الرفض')
            .toList();
      default:
        return _transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.forest),
      );
    }

    final waitingCount = _transactions
        .where((transaction) => transaction.status == 'بانتظار توقيعي')
        .length;

    final urgentCount =
        _transactions.where((transaction) => transaction.isUrgent).length;

    final completedCount = _transactions
        .where((transaction) => transaction.status == 'منجزة')
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            isSmall ? 18 : 32,
            isSmall ? 20 : 28,
            isSmall ? 18 : 32,
            36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TransactionsHeader(waitingCount: waitingCount),
              SizedBox(height: isSmall ? 20 : 28),
              TransactionStats(
                waitingCount: waitingCount,
                urgentCount: urgentCount,
                completedCount: completedCount,
              ),
              const SizedBox(height: 24),
              TransactionsFilters(
                selectedFilter: _selectedFilter,
                onFilterChanged: (value) {
                  setState(() => _selectedFilter = value);
                },
              ),
              const SizedBox(height: 24),
              UrgentWarningCard(urgentCount: urgentCount),
              const SizedBox(height: 24),
              TransactionsTable(transactions: _filteredTransactions),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionsHeader extends StatelessWidget {
  final int waitingCount;

  const _TransactionsHeader({
    required this.waitingCount,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.sizeOf(context).width < 900;

    return Directionality(
      textDirection: TextDirection.rtl, // لضمان اتجاه المحاذاة العربي الصحيح
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.zero, // للتأكد من عدم وجود أي هوامش داخلية تلقائية
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // يجعل العمود يأخذ حجم محتواه فقط ويزيح الفراغات
          crossAxisAlignment: CrossAxisAlignment
              .start, // مع الـ RTL، الـ start هو أقصى اليمين تماماً
          children: [
            Text(
              'معاملاتي',
              textAlign: TextAlign.right,
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: isSmall ? 34 : 42,
                fontWeight: AppTextStyles.black,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'المعاملات الموجهة إليك — $waitingCount بانتظار توقيعك',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.goldDark,
                fontSize: isSmall ? 14 : 16,
                fontWeight: AppTextStyles.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
