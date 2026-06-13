import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_local_data_source.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../widgets/internal_categories_section.dart';
import '../widgets/internal_processes_table.dart';
import '../widgets/internal_stats_section.dart';

class InternalTransactionsPage extends StatefulWidget {
  const InternalTransactionsPage({super.key});

  @override
  State<InternalTransactionsPage> createState() =>
      _InternalTransactionsPageState();
}

class _InternalTransactionsPageState extends State<InternalTransactionsPage> {
  final _dataSource = InternalTransactionsLocalDataSource();

  List<InternalCategoryEntity> _categories = [];

  int _selectedCategoryId = 1;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _dataSource.getCategories();

    if (!mounted) return;

    setState(() {
      _categories = categories;
      _selectedCategoryId = categories.first.id;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.forest,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        32,
        24,
        32,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Header(),
          const SizedBox(height: 28),
          InternalStatsSection(
            categoriesCount: _categories.length,
          ),
          const SizedBox(height: 24),
          InternalCategoriesSection(
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onSelected: (id) {
              setState(() {
                _selectedCategoryId = id;
              });
            },
          ),
          const SizedBox(height: 24),
          InternalProcessesTable(
            categoryId: _selectedCategoryId,
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إنشاء معاملة جديدة'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.zero,
                  fixedSize: null,
                  backgroundColor: AppColors.forest,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'المعاملات الداخلية',
                  style: TextStyle(
                    color: AppColors.forest,
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'المعاملات التي تنشئها وتديرها بنفسك',
                  style: TextStyle(
                    color: AppColors.goldDark,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
