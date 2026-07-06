import '../../../../shared/theme/app_text_styles.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_process_entity.dart';
import '../bloc/create_internal_transaction/create_internal_transaction_bloc.dart';
import '../bloc/create_internal_transaction/create_internal_transaction_event.dart';
import '../bloc/create_internal_transaction/create_internal_transaction_state.dart';

class CreateInternalTransactionPage extends StatefulWidget {
  const CreateInternalTransactionPage({super.key});

  @override
  State<CreateInternalTransactionPage> createState() =>
      _CreateInternalTransactionPageState();
}

class _CreateInternalTransactionPageState
    extends State<CreateInternalTransactionPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<CreateInternalTransactionBloc>().add(
          SearchInternalTransactionProcesses(value),
        );
  }

  void _onCategorySelected(int id) {
    context.read<CreateInternalTransactionBloc>().add(
          SelectInternalTransactionCategory(id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateInternalTransactionBloc,
        CreateInternalTransactionState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: _BackButton(),
                ),
                const SizedBox(height: 36),
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: const _Header(),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: _SearchBox(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 20),
                if (state.loadingCategories)
                  const SizedBox(
                    height: 120,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.forest,
                      ),
                    ),
                  )
                else
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 150),
                    child: _CategoriesChips(
                      categories: state.categories,
                      selectedCategoryId: state.selectedCategoryId,
                      onSelected: _onCategorySelected,
                    ),
                  ),
                const SizedBox(height: 32),
                if (state.errorMessage != null)
                  FadeIn(
                    duration: const Duration(milliseconds: 300),
                    child: _ErrorBox(message: state.errorMessage!),
                  )
                else if (state.loadingProcesses)
                  const SizedBox(
                    height: 220,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.forest,
                      ),
                    ),
                  )
                else
                  FadeInUp(
                    duration: const Duration(milliseconds: 450),
                    delay: const Duration(milliseconds: 200),
                    child: _ProcessesGrid(processes: state.filteredProcesses),
                  ),
              ],
            ),
          ),
        );
      },
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
          textStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: AppTextStyles.bold,
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
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.goldDark,
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
    if (categories.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'لا توجد تصنيفات متاحة حالياً',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: AppTextStyles.semiBold,
              color: AppColors.goldDark,
            ),
          ),
        ),
      );
    }

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
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: AppTextStyles.semiBold,
                          color:
                              selected ? AppColors.white : AppColors.charcoal,
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
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'لا توجد معاملات ضمن هذا التصنيف',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.semiBold,
              color: AppColors.goldDark,
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
            return FadeInUp(
              duration: const Duration(milliseconds: 350),
              delay: Duration(milliseconds: (index % 9) * 45),
              child: _ProcessCard(process: processes[index]),
            );
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
                      style: AppTextStyles.titleMedium.copyWith(
                        fontSize: 17,
                        fontWeight: AppTextStyles.bold,
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
              Text(
                '5 خطوات',
                textAlign: TextAlign.left,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: AppTextStyles.medium,
                  color: AppColors.goldDark,
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
                  Text(
                    'إنشاء هذه المعاملة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: AppColors.forest,
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
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: AppTextStyles.semiBold,
          color: AppColors.umber,
        ),
      ),
    );
  }
}
