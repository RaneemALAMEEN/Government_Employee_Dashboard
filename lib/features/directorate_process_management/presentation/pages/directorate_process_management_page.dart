import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../bloc/directorate_complaints_bloc.dart';
import '../bloc/directorate_complaints_event.dart';
import '../bloc/directorate_complaints_state.dart';
import '../bloc/directorate_process_bloc.dart';
import '../bloc/directorate_process_event.dart';
import '../bloc/directorate_process_state.dart';
import '../widgets/directorate_process_widgets.dart';

enum _ManagementTab { transactions, complaints }

class DirectorateProcessManagementPage extends StatefulWidget {
  const DirectorateProcessManagementPage({super.key});

  @override
  State<DirectorateProcessManagementPage> createState() =>
      _DirectorateProcessManagementPageState();
}

class _DirectorateProcessManagementPageState
    extends State<DirectorateProcessManagementPage> {
  _ManagementTab _selectedTab = _ManagementTab.transactions;

  void _selectTab(_ManagementTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    if (tab == _ManagementTab.complaints) {
      context
          .read<DirectorateComplaintsBloc>()
          .add(const LoadDirectorateComplaints());
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<DirectorateProcessBloc, DirectorateProcessState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) => AppSnackBar.show(
            context,
            message: state.errorMessage!,
            title: 'تعذر تحميل البيانات',
            isError: true,
          ),
          builder: (context, state) => Container(
            color: AppColors.goldLight,
            padding: const EdgeInsets.fromLTRB(30, 28, 30, 0),
            child: Column(
              children: [
                _ManagementTabs(
                  selected: _selectedTab,
                  onSelected: _selectTab,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab.index,
                    sizing: StackFit.expand,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, .025),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: state.view == DirectorateView.types
                            ? _TypesView(
                                key: const ValueKey('types'),
                                state: state,
                              )
                            : _DefinitionsView(
                                key: ValueKey(
                                  'definitions-${state.selectedTypeId}',
                                ),
                                state: state,
                              ),
                      ),
                      const _ComplaintsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _ManagementTabs extends StatelessWidget {
  final _ManagementTab selected;
  final ValueChanged<_ManagementTab> onSelected;

  const _ManagementTabs({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: .30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: _ManagementTab.values
                .map(
                  (tab) => _ManagementTabButton(
                    label: tab == _ManagementTab.transactions
                        ? 'المعاملات'
                        : 'الشكاوى',
                    selected: selected == tab,
                    onTap: () => onSelected(tab),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      );
}

class _ManagementTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ManagementTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.surface : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
}

class _TypesView extends StatelessWidget {
  final DirectorateProcessState state;
  const _TypesView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 1100
          ? 3
          : constraints.maxWidth >= 650
              ? 2
              : 1;
      final cardAspectRatio = columns == 3
          ? 2.35
          : columns == 2
              ? 2.45
              : 3.1;
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DirectorateManagementHeader(types: state.types),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: TransactionTypesSectionHeader(
              onSearchChanged: (value) => context
                  .read<DirectorateProcessBloc>()
                  .add(SearchTransactionTypes(value)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (state.isTypesLoading)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 500,
                child: DirectorateSkeletonGrid(),
              ),
            )
          else if (state.errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorWidget(
                onRetry: () => context
                    .read<DirectorateProcessBloc>()
                    .add(const RetryCurrentRequest()),
              ),
            )
          else if (state.filteredTypes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: DirectorateMessageState(
                message: state.typesQuery.isEmpty
                    ? 'لا توجد أنواع معاملات متاحة حالياً'
                    : 'لا توجد نتائج مطابقة لبحثك',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 30),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cardAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = state.filteredTypes[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(
                        milliseconds: 260 + ((index > 8 ? 8 : index) * 45),
                      ),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 14 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: TransactionTypeCard(
                        item: item,
                        onTap: () => context.read<DirectorateProcessBloc>().add(
                              LoadProcessDefinitions(
                                typeId: item.id,
                                typeName: item.name,
                              ),
                            ),
                      ),
                    );
                  },
                  childCount: state.filteredTypes.length,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _DefinitionsView extends StatefulWidget {
  final DirectorateProcessState state;
  const _DefinitionsView({super.key, required this.state});

  @override
  State<_DefinitionsView> createState() => _DefinitionsViewState();
}

class _DefinitionsViewState extends State<_DefinitionsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context
          .read<DirectorateProcessBloc>()
          .add(const LoadMoreProcessDefinitions());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final visibleItems = state.filteredDefinitions;
    return LayoutBuilder(builder: (_, constraints) {
      final columns = constraints.maxWidth >= 1100 ? 3 : 2;
      return CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: DirectorateHeader(
              title: 'قوالب معاملات: ${state.selectedTypeName ?? ''}',
              subtitle: 'إجمالي القوالب: ${state.total}',
              onBack: () => context
                  .read<DirectorateProcessBloc>()
                  .add(const BackToTransactionTypes()),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          SliverToBoxAdapter(
            child: Align(
              alignment: Alignment.centerRight,
              child: DirectorateSearchBar(
                onChanged: (value) => context
                    .read<DirectorateProcessBloc>()
                    .add(SearchProcessDefinitions(value)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 22)),
          if (state.isInitialLoading)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 500,
                child: DirectorateSkeletonGrid(),
              ),
            )
          else if (state.errorMessage != null && state.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: AppErrorWidget(
                onRetry: () => context
                    .read<DirectorateProcessBloc>()
                    .add(const RetryCurrentRequest()),
              ),
            )
          else if (state.items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: DirectorateMessageState(
                message: state.definitionsQuery.isEmpty
                    ? 'لا توجد قوالب متاحة حالياً'
                    : 'لا توجد نتائج ضمن القوالب المحمّلة',
              ),
            )
          else if (visibleItems.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: DirectorateMessageState(
                message: 'لا توجد نتائج ضمن القوالب المحمّلة',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 18),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  mainAxisExtent: 210,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) => ProcessDefinitionCard(
                    item: visibleItems[index],
                    onTap: () => context.push(
                      '/directorate-process-management/process/${visibleItems[index].processId}',
                    ),
                  ),
                  childCount: visibleItems.length,
                ),
              ),
            ),
          if (!state.isInitialLoading && visibleItems.isNotEmpty)
            SliverToBoxAdapter(child: _PaginationFooter(state: state)),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      );
    });
  }
}

class _ComplaintsView extends StatefulWidget {
  const _ComplaintsView();

  @override
  State<_ComplaintsView> createState() => _ComplaintsViewState();
}

class _ComplaintsViewState extends State<_ComplaintsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      context
          .read<DirectorateComplaintsBloc>()
          .add(const LoadMoreDirectorateComplaints());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<DirectorateComplaintsBloc, DirectorateComplaintsState>(
        builder: (context, state) => LayoutBuilder(
          builder: (_, constraints) {
            final columns = constraints.maxWidth >= 1100
                ? 3
                : constraints.maxWidth >= 650
                    ? 2
                    : 1;
            final visibleItems = state.filteredItems;
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: DirectorateComplaintsHeader(total: state.total),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: constraints.maxWidth >= 650
                          ? 420
                          : constraints.maxWidth,
                      child: DirectorateSearchBar(
                        hintText: 'ابحث باسم الشكوى...',
                        onChanged: (value) => context
                            .read<DirectorateComplaintsBloc>()
                            .add(SearchDirectorateComplaints(value)),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                if (state.isInitialLoading)
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 500,
                      child: DirectorateSkeletonGrid(),
                    ),
                  )
                else if (state.errorMessage != null && state.items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: DirectorateMessageState(
                      isError: true,
                      message: state.errorMessage!,
                      onRetry: () => context
                          .read<DirectorateComplaintsBloc>()
                          .add(const RetryDirectorateComplaints()),
                    ),
                  )
                else if (state.items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: DirectorateMessageState(
                      message: 'لا توجد شكاوى متاحة حالياً',
                    ),
                  )
                else if (visibleItems.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: DirectorateMessageState(
                      message:
                          'لا توجد شكاوى مطابقة لبحثك ضمن النتائج المحمّلة',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 210,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) {
                          final item = visibleItems[index];
                          return ProcessDefinitionCard(
                            item: item,
                            subtitle: 'تعريف مسار الشكوى ومراحل معالجتها',
                            onTap: () => context.push(
                              '/directorate-process-management/process/${item.processId}',
                            ),
                          );
                        },
                        childCount: visibleItems.length,
                      ),
                    ),
                  ),
                if (!state.isInitialLoading && visibleItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _ComplaintsPaginationFooter(state: state),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            );
          },
        ),
      );
}

class _ComplaintsPaginationFooter extends StatelessWidget {
  final DirectorateComplaintsState state;

  const _ComplaintsPaginationFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('تعذر تحميل المزيد من الشكاوى'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context
                  .read<DirectorateComplaintsBloc>()
                  .add(const RetryMoreDirectorateComplaints()),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (!state.hasNext) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('تم عرض جميع الشكاوى')),
      );
    }
    return const SizedBox(height: 16);
  }
}

class _PaginationFooter extends StatelessWidget {
  final DirectorateProcessState state;
  const _PaginationFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('تعذر تحميل المزيد'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context
                  .read<DirectorateProcessBloc>()
                  .add(const RetryLoadMoreProcessDefinitions()),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    if (!state.hasNext) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('تم عرض جميع القوالب')),
      );
    }
    return const SizedBox(height: 16);
  }
}
