import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';

import '../../../../core/services/api_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_remote_data_source.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_process_entity.dart';

class CreateInternalTransactionPage extends StatefulWidget {
  const CreateInternalTransactionPage({super.key});

  @override
  State<CreateInternalTransactionPage> createState() =>
      _CreateInternalTransactionPageState();
}

class _CreateInternalTransactionPageState
    extends State<CreateInternalTransactionPage> {
  final _dataSource = InternalTransactionsRemoteDataSource(
    getIt<ApiService>(),
  );

  final _searchController = TextEditingController();

  List<InternalCategoryEntity> _categories = [];
  List<InternalProcessEntity> _processes = [];

  int _selectedCategoryId = -1;
  bool _loadingCategories = true;
  bool _loadingProcesses = false;
  String? _errorMessage;

  static const int _page = 1;
  static const int _limit = 6;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _dataSource.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _loadingCategories = false;
        _selectedCategoryId = categories.isNotEmpty ? categories.first.id : -1;
      });

      if (categories.isNotEmpty) {
        await _loadProcesses(categories.first.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _loadProcesses(int categoryId) async {
    setState(() {
      _loadingProcesses = true;
      _errorMessage = null;
    });

    try {
      final data = await _dataSource.getProcessesByCategory(
        categoryId: categoryId,
        page: _page,
        limit: _limit,
      );

      if (!mounted) return;

      setState(() {
        _processes = data.items;
        _loadingProcesses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _processes = [];
        _loadingProcesses = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _selectCategory(int id) {
    if (_selectedCategoryId == id) return;

    setState(() {
      _selectedCategoryId = id;
    });

    _loadProcesses(id);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProcesses = _searchController.text.trim().isEmpty
        ? _processes
        : _processes.where((item) {
            final query = _searchController.text.trim();
            return item.name.contains(query) || item.code.contains(query);
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BackButton(),
            const SizedBox(height: 36),
            const _Header(),
            const SizedBox(height: 28),
            _SearchBox(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            if (_loadingCategories)
              const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.forest),
                ),
              )
            else
              _CategoriesChips(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onSelected: _selectCategory,
              ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              _ErrorBox(message: _errorMessage!)
            else if (_loadingProcesses)
              const SizedBox(
                height: 220,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.forest),
                ),
              )
            else
              _ProcessesGrid(processes: filteredProcesses),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () => context.go('/internal-transactions'),
        icon: const Icon(Icons.arrow_forward, size: 18),
        label: const Text('العودة لمركز المعاملات'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر نوع المعاملة',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.forest,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'اختر التصنيف ثم نوع المعاملة التي تريد إنشاءها',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.goldDark,
              ),
        ),
      ],
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          hintText: 'البحث في أنواع المعاملات...',
          hintStyle: const TextStyle(
            color: AppColors.goldDark,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.goldDark,
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.22)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.gold.withOpacity(0.22)),
          ),
        ),
      ),
    );
  }
}

class _CategoriesChips extends StatelessWidget {
  final List<InternalCategoryEntity> categories;
  final int selectedCategoryId;
  final ValueChanged<int> onSelected;

  const _CategoriesChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        textDirection: TextDirection.rtl,
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: [
          ...categories.map(
            (category) {
              final selected = selectedCategoryId == category.id;

              return InkWell(
                onTap: () => onSelected(category.id),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.forest : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.forest
                          : AppColors.gold.withOpacity(0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        _iconForCategory(category.name),
                        size: 18,
                        color: selected ? AppColors.white : AppColors.charcoal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color:
                              selected ? AppColors.white : AppColors.charcoal,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.white.withOpacity(0.18)
                              : AppColors.goldLight,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            color:
                                selected ? AppColors.white : AppColors.goldDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String name) {
    if (name.contains('طالب')) return Icons.school_outlined;
    if (name.contains('البشرية')) return Icons.groups_outlined;
    if (name.contains('مدرس')) return Icons.menu_book_outlined;
    if (name.contains('مراسلات')) return Icons.send_outlined;
    if (name.contains('إحصائيات')) return Icons.bar_chart_outlined;
    if (name.contains('صيانة')) return Icons.apartment_outlined;
    if (name.contains('تقني')) return Icons.computer_outlined;
    return Icons.category_outlined;
  }
}

class _ProcessesGrid extends StatelessWidget {
  final List<InternalProcessEntity> processes;

  const _ProcessesGrid({
    required this.processes,
  });

  @override
  Widget build(BuildContext context) {
    if (processes.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'لا توجد معاملات ضمن هذا التصنيف',
            style: TextStyle(
              color: AppColors.goldDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1100
            ? 3
            : width >= 760
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: processes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 22,
            crossAxisSpacing: 22,
            mainAxisExtent: 208,
          ),
          itemBuilder: (context, index) {
            return _ProcessCard(process: processes[index]);
          },
        );
      },
    );
  }
}

class _ProcessCard extends StatefulWidget {
  final InternalProcessEntity process;

  const _ProcessCard({
    required this.process,
  });

  @override
  State<_ProcessCard> createState() => _ProcessCardState();
}

class _ProcessCardState extends State<_ProcessCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hovered ? -6.0 : 0.0),
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? AppColors.forest.withOpacity(0.45)
                : AppColors.gold.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(_hovered ? 0.12 : 0.04),
              blurRadius: _hovered ? 16 : 8,
              offset: Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            context.go(
              '/internal-transaction-form',
              extra: widget.process.processId,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.forestLight.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.groups_outlined,
                      color: AppColors.forest,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.process.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.charcoalDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(left: index == 4 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '5 خطوات',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _hovered
                          ? AppColors.forest
                          : AppColors.forestLight.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: _hovered ? AppColors.white : AppColors.forest,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'إنشاء هذه المعاملة',
                    style: TextStyle(
                      color: AppColors.forest,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.umber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.umber.withOpacity(0.18)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppColors.umber,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
