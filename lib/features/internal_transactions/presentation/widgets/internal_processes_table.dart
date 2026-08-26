import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/internal_transaction_entity.dart';
import '../bloc/internal_transactions_bloc.dart';
import '../bloc/internal_transactions_event.dart';
import '../bloc/internal_transactions_state.dart';

class InternalProcessesTable extends StatefulWidget {
  const InternalProcessesTable({super.key});

  @override
  State<InternalProcessesTable> createState() => _InternalProcessesTableState();
}

class _InternalProcessesTableState extends State<InternalProcessesTable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternalTransactionsBloc, InternalTransactionsState>(
      builder: (context, state) {
        if (state.loadingTransactions && state.transactionsPageData == null) {
          return const ListSkeletonLoader(
            itemCount: 5,
            itemHeight: 70,
          );
        }

        if (state.errorMessage != null && state.transactionsPageData == null) {
          return _ErrorBox(message: state.errorMessage!);
        }

        final data = state.transactionsPageData;

        if (data == null) {
          return const ListSkeletonLoader(
            itemCount: 5,
            itemHeight: 70,
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 600;
              final double availableWidth = constraints.maxWidth;

              final query = state.searchQuery.trim().toLowerCase();
              final filteredItems = data.items.where((t) {
                if (t.status.toLowerCase() == 'draft') return false;

                // Status filter matching
                if (state.statusFilter != 'الكل') {
                  final mapped = _mapStatusToInternal(t.status);
                  if (mapped != state.statusFilter) return false;
                }

                // Query matching
                if (query.isNotEmpty) {
                  final match = t.idProcess.toLowerCase().contains(query) ||
                      t.processDefinitionName.toLowerCase().contains(query) ||
                      t.stageName.toLowerCase().contains(query) ||
                      t.status.toLowerCase().contains(query) ||
                      t.transactionId.toString().contains(query);
                  if (!match) return false;
                }

                return true;
              }).toList();

              final isFilteredOrSearched = state.searchQuery.trim().isNotEmpty ||
                  state.statusFilter != 'الكل';

              final Widget tableContent = Column(
                children: [
                  const _TableHeader(),
                  if (filteredItems.isEmpty && state.loadingTransactions)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.forest),
                      ),
                    )
                  else if (filteredItems.isEmpty)
                    isFilteredOrSearched
                        ? _EmptySearchState(
                            query: state.searchQuery,
                            statusFilter: state.statusFilter,
                            onReset: () {
                              context.read<InternalTransactionsBloc>()
                                ..add(const FilterInternalTransactions('الكل'))
                                ..add(const SearchInternalTransactions(''));
                            },
                          )
                        : const _EmptyTransactionsState()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.18),
                      ),
                      itemBuilder: (context, index) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 350),
                          delay: Duration(milliseconds: (index % 10) * 45),
                          child: _TransactionRow(item: filteredItems[index]),
                        );
                      },
                    ),
                  if (state.loadingTransactions && filteredItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    )
                  else if (state.hasMoreTransactions)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Center(
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                ],
              );

              if (availableWidth < minTableWidth) {
                return Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: tableContent,
                    ),
                  ),
                );
              } else {
                return tableContent;
              }
            },
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      color: AppColors.goldLight,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderText('رقم المعاملة', flex: 17),
          _HeaderText('نوع المعاملة', flex: 20),
          _HeaderText('المرحلة الحالية', flex: 19),
          _HeaderText('نسبة الإنجاز', flex: 14),
          _HeaderText('الحالة', flex: 14),
          _HeaderText('إجراء', flex: 16),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final InternalTransactionEntity item;

  const _TransactionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Transaction ID
            _CellText(
              item.idProcess,
              flex: 17,
              color: AppColors.forest,
              fontWeight: AppTextStyles.semiBold,
            ),
            // Process Type
            _CellText(
              item.processDefinitionName,
              flex: 20,
              color: AppColors.charcoalDark,
              fontWeight: AppTextStyles.medium,
            ),
            // Current Stage
            _CellText(
              item.stageName,
              flex: 19,
              color: AppColors.charcoal,
            ),
            // Progress Percent
            Expanded(
              flex: 14,
              child: Center(
                child: _ProgressBadge(percent: item.progressPercent),
              ),
            ),
            // Status Badge
            Expanded(
              flex: 14,
              child: Center(
                child: _StatusBadge(status: item.status),
              ),
            ),
            // Action Button
            Expanded(
              flex: 16,
              child: Center(
                child: _DetailsButton(
                  onTap: () {
                    context.push(
                      '/internal-transactions/${item.transactionId}/first-stage',
                      extra: item,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderText(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: AppTextStyles.semiBold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _CellText extends StatelessWidget {
  final String text;
  final int flex;
  final Color? color;
  final FontWeight fontWeight;

  const _CellText(
    this.text, {
    required this.flex,
    this.color,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Tooltip(
        message: text,
        waitDuration: const Duration(milliseconds: 250),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: fontWeight,
            color: color ?? AppColors.charcoalDark,
            height: 1.25,
          ),
        ),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int percent;

  const _ProgressBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return Tooltip(
      message: 'نسبة الإنجاز: $safePercent%',
      waitDuration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.forestLight.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$safePercent%',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: AppTextStyles.bold,
            color: AppColors.forest,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final data = _statusData(status);

    return Tooltip(
      message: 'الحالة: ${data.text}',
      waitDuration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: data.background,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          data.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: AppTextStyles.semiBold,
            color: data.textColor,
            height: 1,
          ),
        ),
      ),
    );
  }

  _StatusViewData _statusData(String status) {
    switch (status) {
      case 'submitted':
        return const _StatusViewData(
          text: 'مقدمة',
          textColor: AppColors.forest,
          background: Color(0xFFEAF3F0),
        );
      case 'in_progress':
        return _StatusViewData(
          text: 'قيد المعالجة',
          textColor: AppColors.goldDark,
          background: AppColors.goldLight.withValues(alpha: 0.45),
        );
      case 'completed':
        return const _StatusViewData(
          text: 'منجزة',
          textColor: AppColors.forest,
          background: Color(0xFFE8F5E9),
        );
      case 'rejected':
        return const _StatusViewData(
          text: 'مرفوضة',
          textColor: AppColors.umber,
          background: Color(0xFFFFEBEE),
        );
      case 'cancelled':
        return const _StatusViewData(
          text: 'ملغاة',
          textColor: AppColors.umber,
          background: Color(0xFFF8EDEF),
        );
      default:
        return _StatusViewData(
          text: status,
          textColor: const Color(0xFF5A738E),
          background: const Color(0xFFEDF2F7),
        );
    }
  }
}

class _StatusViewData {
  final String text;
  final Color textColor;
  final Color background;

  const _StatusViewData({
    required this.text,
    required this.textColor,
    required this.background,
  });
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.forestLight.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.eye,
                size: 14,
                color: AppColors.forest,
              ),
              const SizedBox(width: 5),
              Text(
                'عرض التفاصيل',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.forest,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  const _EmptyTransactionsState();

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 350),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        alignment: Alignment.center,
        child: ZoomIn(
          duration: const Duration(milliseconds: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/vectors/waiting.svg',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              const Text(
                'لا توجد معاملات داخلية حالياً',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'عند إنشاء معاملة داخلية جديدة ستظهر هنا مع مرحلتها الحالية ونسبة الإنجاز.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.charcoal.withValues(alpha: 0.60),
                    height: 1.4,
                  ),
                ),
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

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.umber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.umber.withValues(alpha: 0.18)),
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

class _EmptySearchState extends StatelessWidget {
  final String query;
  final String statusFilter;
  final VoidCallback onReset;

  const _EmptySearchState({
    required this.query,
    required this.statusFilter,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    final hasStatus = statusFilter != 'الكل';

    String description = 'تأكد من صحة رقم المعاملة أو الكلمات المدخلة وحاول مجدداً.';
    if (hasQuery && hasStatus) {
      description =
          'لم يتم العثور على نتائج تطابق "$query" في حالة "$statusFilter".';
    } else if (hasQuery) {
      description = 'لم يتم العثور على نتائج تطابق "$query".';
    } else if (hasStatus) {
      description = 'لا توجد معاملات داخلية بحالة "$statusFilter".';
    }

    return AppEmptySearchState(
      title: 'لا توجد نتائج تطابق البحث',
      description: description,
      isCard: false,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      action: TextButton.icon(
        onPressed: onReset,
        icon: const Icon(LucideIcons.rotateCcw, size: 16),
        label: const Text('إعادة ضبط الفلاتر'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forest,
        ),
      ),
    );
  }
}

String _mapStatusToInternal(String status) {
  switch (status.toLowerCase()) {
    case 'in_progress':
    case 'قيد المعالجة':
    case 'قيد التنفيذ':
      return 'قيد المعالجة';
    case 'submitted':
    case 'مقدمة':
      return 'مقدمة';
    case 'completed':
    case 'منجزة':
    case 'منجز':
      return 'منجزة';
    case 'rejected':
    case 'مرفوضة':
    case 'تم الرفض':
      return 'مرفوضة';
    case 'cancelled':
    case 'ملغاة':
      return 'ملغاة';
    default:
      return status;
  }
}

