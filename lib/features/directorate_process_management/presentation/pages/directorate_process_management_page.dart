import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../bloc/directorate_process_bloc.dart';
import '../bloc/directorate_process_event.dart';
import '../bloc/directorate_process_state.dart';
import '../widgets/directorate_process_widgets.dart';

class DirectorateProcessManagementPage extends StatelessWidget {
  const DirectorateProcessManagementPage({super.key});

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
            child: AnimatedSwitcher(
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
                  ? _TypesView(key: const ValueKey('types'), state: state)
                  : _DefinitionsView(
                      key: ValueKey('definitions-${state.selectedTypeId}'),
                      state: state,
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
              child: DirectorateMessageState(
                isError: true,
                message: state.errorMessage!,
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
              child: DirectorateMessageState(
                isError: true,
                message: state.errorMessage!,
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
                  mainAxisExtent: 164,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, index) => ProcessDefinitionCard(
                    item: visibleItems[index],
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
