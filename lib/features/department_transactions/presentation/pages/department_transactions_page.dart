import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/accessible_department_entity.dart';
import '../bloc/dept_tx_bloc.dart';
import '../bloc/dept_tx_event.dart';
import '../bloc/dept_tx_state.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../widgets/dept_tx_export_dialog.dart';
import '../widgets/dept_tx_filter_bar.dart';
import '../widgets/dept_tx_stats_card.dart';
import '../widgets/dept_tx_table.dart';

class DepartmentTransactionsPage extends StatelessWidget {
  const DepartmentTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeptTxBloc>(
      create: (_) => getIt<DeptTxBloc>()..add(const LoadDeptTx()),
      child: const _DepartmentTransactionsView(),
    );
  }
}

class _DepartmentTransactionsView extends StatefulWidget {
  const _DepartmentTransactionsView();

  @override
  State<_DepartmentTransactionsView> createState() =>
      _DepartmentTransactionsViewState();
}

class _DepartmentTransactionsViewState
    extends State<_DepartmentTransactionsView> {
  static const double contentPadding = 32;
  static const double gap = 20;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DeptTxBloc>().add(LoadMoreDeptTx());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeptTxBloc, DeptTxState>(
      builder: (context, state) {
        // تحديد القيم الافتراضية أثناء التحميل
        String statusFilter = 'الكل';
        String searchQuery = '';
        String? fromDate;
        String? toDate;
        List<AccessibleDepartmentEntity> accessibleDepartments = [];
        int? selectedDepartmentId;
        String? selectedDepartmentName;

        if (state is DeptTxLoaded) {
          statusFilter = state.statusFilter;
          searchQuery = state.searchQuery;
          fromDate = state.fromDate;
          toDate = state.toDate;
          accessibleDepartments = state.accessibleDepartments;
          selectedDepartmentId = state.selectedDepartmentId;
          selectedDepartmentName = state.selectedDepartmentName;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 1050;

            return SingleChildScrollView(
              controller: _scrollController,
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
                      child: AppPageHeader(
                        title: 'معاملات الدائرة',
                        subtitle: selectedDepartmentName != null
                            ? 'معاملات $selectedDepartmentName — للعرض والمتابعة فقط'
                            : 'جميع المعاملات المنجزة والمرفوضة ضمن الدائرة — للعرض والمتابعة فقط',
                        trailing: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              DeptTxExportDialog.show(
                                context: context,
                                initialStatusFilter: statusFilter,
                                initialFromDate: fromDate,
                                initialToDate: toDate,
                                departmentId: selectedDepartmentId,
                                departmentName: selectedDepartmentName,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 42,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.forest.withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.charcoal.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.fileSpreadsheet,
                                    size: 17,
                                    color: AppColors.forest,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تصدير البيانات',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: AppTextStyles.semiBold,
                                      color: AppColors.forest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats Cards Row
                    FadeInUp(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 80),
                      child: (state is DeptTxLoading || state is DeptTxInitial)
                          ? (isSmall
                              ? const CustomSkeletonLoader(
                                  width: double.infinity, height: 100)
                              : const Row(
                                  children: [
                                    Expanded(
                                        child: CustomSkeletonLoader(
                                            width: double.infinity,
                                            height: 100)),
                                    SizedBox(width: gap),
                                    Spacer(),
                                    SizedBox(width: gap),
                                    Spacer(),
                                    SizedBox(width: gap),
                                    Spacer(),
                                  ],
                                ))
                          : (state is DeptTxLoaded
                              ? (isSmall
                                  ? Column(
                                      children: [
                                        DeptTxStatsCard(
                                          value: '${state.activeCount}',
                                          label: 'المعاملات النشطة',
                                          valueColor: AppColors.goldDark,
                                        ),
                                        const SizedBox(height: gap),
                                        DeptTxStatsCard(
                                          value: '${state.completedCount}',
                                          label: 'المنجزة (آخر 30 يوم)',
                                          valueColor: AppColors.forest,
                                        ),
                                        const SizedBox(height: gap),
                                        DeptTxStatsCard(
                                          value: '${state.rejectedCount}',
                                          label: 'المرفوضة (آخر 30 يوم)',
                                          valueColor: AppColors.primary,
                                        ),
                                      ],
                                    )
                                  : Row(
                                      textDirection: TextDirection.rtl,
                                      children: [
                                        Expanded(
                                          child: DeptTxStatsCard(
                                            value: '${state.activeCount}',
                                            label: 'المعاملات النشطة',
                                            valueColor: AppColors.goldDark,
                                          ),
                                        ),
                                        const SizedBox(width: gap),
                                        Expanded(
                                          child: DeptTxStatsCard(
                                            value: '${state.completedCount}',
                                            label: 'المنجزة (آخر 30 يوم)',
                                            valueColor: AppColors.forest,
                                          ),
                                        ),
                                        const SizedBox(width: gap),
                                        Expanded(
                                          child: DeptTxStatsCard(
                                            value: '${state.rejectedCount}',
                                            label: 'المرفوضة (آخر 30 يوم)',
                                            valueColor: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ))
                              : const SizedBox.shrink()),
                    ),
                    const SizedBox(height: 32),

                    // Search & Filter Bar
                    FadeInUp(
                      duration: const Duration(milliseconds: 450),
                      delay: const Duration(milliseconds: 140),
                      child: DeptTxFilterBar(
                        activeStatusFilter: statusFilter,
                        searchQuery: searchQuery,
                        fromDate: fromDate,
                        toDate: toDate,
                        accessibleDepartments: accessibleDepartments,
                        selectedDepartmentId: selectedDepartmentId,
                        onStatusFilterChanged: (filter) {
                          context
                              .read<DeptTxBloc>()
                              .add(FilterDeptTxByStatus(filter));
                        },
                        onDateRangeChanged: (from, to) {
                          context.read<DeptTxBloc>().add(
                              FilterDeptTxByDate(fromDate: from, toDate: to));
                        },
                        onSearchChanged: (query) {
                          context.read<DeptTxBloc>().add(SearchDeptTx(query));
                        },
                        onDepartmentChanged: (deptId, deptName) {
                          context.read<DeptTxBloc>().add(
                                FilterDeptTxByDepartment(
                                  departmentId: deptId,
                                  departmentName: deptName,
                                ),
                              );
                        },
                      ),
                    ),
                    const SizedBox(height: gap),

                    // Transactions Table & Errors
                    if (state is DeptTxLoading || state is DeptTxInitial)
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 220),
                        child: const ListSkeletonLoader(
                          itemCount: 8,
                          itemHeight: 70,
                        ),
                      )
                    else if (state is DeptTxFailure)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: AppErrorWidget(
                          onRetry: () {
                            context.read<DeptTxBloc>().add(const LoadDeptTx());
                          },
                        ),
                      )
                    else if (state is DeptTxLoaded) ...[
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 220),
                        child: DeptTxTable(
                          transactions: state.transactions,
                          isSearching: state.isSearching,
                          searchQuery: state.searchQuery,
                          activeFilter: state.statusFilter,
                        ),
                      ),
                      // Loading indicator at bottom
                      if (state.isFetchingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.forest),
                          ),
                        ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
