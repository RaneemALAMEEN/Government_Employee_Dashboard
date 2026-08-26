import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/self_card_search_item_entity.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';
import '../widgets/self_card_details_view.dart';
import '../widgets/self_card_mode_selector.dart';
import '../widgets/self_card_search_header.dart';
import '../widgets/training_recommendation_header.dart';
import '../widgets/training_recommendation_results_section.dart';

class SelfCardsPage extends StatelessWidget {
  const SelfCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      if (context.read<SelfCardsBloc?>() != null) {
        return const _SelfCardsView();
      }
    } catch (_) {}

    return BlocProvider(
      create: (_) => getIt<SelfCardsBloc>()
        ..add(const SearchSelfCardsEvent(query: '')),
      child: const _SelfCardsView(),
    );
  }
}

class _SelfCardsView extends StatelessWidget {
  const _SelfCardsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: BlocBuilder<SelfCardsBloc, SelfCardsState>(
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Page Top Breadcrumb / Title Bar
                      _PageTitleBar(
                        hasSelectedCard: state.selectedCard != null,
                        viewMode: state.viewMode,
                        onBack: () {
                          context
                              .read<SelfCardsBloc>()
                              .add(const ClearSelectedSelfCardEvent());
                        },
                      ),
                      const SizedBox(height: 20),

                      // Content Router
                      if (state.isLoadingDetails) ...[
                        const _DetailsSkeleton(),
                      ] else if (state.detailsError != null) ...[
                        AppErrorWidget(
                          title: 'تعذر تحميل تفاصيل البطاقة',
                          message: state.detailsError!,
                          onRetry: () {
                            context
                                .read<SelfCardsBloc>()
                                .add(const ClearSelectedSelfCardEvent());
                          },
                        ),
                      ] else if (state.selectedCard != null) ...[
                        FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: SelfCardDetailsView(
                            selfCard: state.selectedCard!,
                          ),
                        ),
                      ] else ...[
                        // Mode Switcher (Search vs Training Recommendation)
                        FadeInDown(
                          duration: const Duration(milliseconds: 200),
                          child: const SelfCardModeSelector(),
                        ),
                        const SizedBox(height: 18),

                        if (state.viewMode == SelfCardViewMode.search) ...[
                          // Standard Search Mode
                          FadeInDown(
                            duration: const Duration(milliseconds: 250),
                            child: const SelfCardSearchHeader(),
                          ),
                          const SizedBox(height: 24),
                          _SearchResultsSection(state: state),
                        ] else ...[
                          // Training Recommendation Mode
                          FadeInDown(
                            duration: const Duration(milliseconds: 250),
                            child: const TrainingRecommendationHeader(),
                          ),
                          const SizedBox(height: 24),
                          TrainingRecommendationResultsSection(state: state),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageTitleBar extends StatelessWidget {
  final bool hasSelectedCard;
  final SelfCardViewMode viewMode;
  final VoidCallback onBack;

  const _PageTitleBar({
    required this.hasSelectedCard,
    required this.viewMode,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;

    if (hasSelectedCard) {
      title = 'البطاقة الذاتية للموظفين — تفاصيل البطاقة';
      subtitle =
          'استعراض السجلات الذاتية، البيانات الوظيفية، والدورات التدريبية المعتمدة للموظف';
    } else if (viewMode == SelfCardViewMode.recommendByTraining) {
      title = 'البطاقة الذاتية — ترشيح الموظفين للدورات التدريبية';
      subtitle =
          'نظام ترشيح ذكي يستخرج البطاقات الذاتية للموظفين الذين لم يحضروا دورة تدريبية معينة';
    } else {
      title = 'البطاقة الذاتية للموظفين';
      subtitle =
          'استعراض السجلات الذاتية، البيانات الوظيفية، والدورات التدريبية المعتمدة للموظفين';
    }

    return AppPageHeader(
      title: title,
      subtitle: subtitle,
      backButton: hasSelectedCard
          ? AppBackButton(
              label: 'العودة للقائمة',
              onPressed: onBack,
            )
          : null,
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  final SelfCardsState state;

  const _SearchResultsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isSearching) {
      return const Column(
        children: [
          ListSkeletonLoader(itemCount: 4, itemHeight: 90),
        ],
      );
    }

    if (state.searchError != null) {
      return AppErrorWidget(
        title: 'تعذر جلب نتائج البحث',
        message: state.searchError!,
        onRetry: () {
          context.read<SelfCardsBloc>().add(
                SearchSelfCardsEvent(
                  query: state.searchQuery,
                  activeOnly: state.activeOnly,
                ),
              );
        },
      );
    }

    if (state.searchResults.isEmpty) {
      return AppEmptySearchState(
        title: 'لم يتم العثور على أي بطاقة ذاتية مطابقة',
        description: state.searchQuery.isNotEmpty
            ? 'تأكد من صحة الاسم الكامل أو الرقم الوطني (11 خانة) أو الرقم الذاتي، ثم حاول مجدداً.'
            : 'لا توجد سجلات ذاتية متاحة حالياً في النظام.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                'نتائج البحث (${state.searchResults.length} موظف)',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = state.searchResults[index];
            return FadeInUp(
              duration: const Duration(milliseconds: 300),
              delay: Duration(milliseconds: (index % 8) * 35),
              child: _EmployeeSearchResultCard(item: item),
            );
          },
        ),
      ],
    );
  }
}

class _EmployeeSearchResultCard extends StatelessWidget {
  final SelfCardSearchItemEntity item;

  const _EmployeeSearchResultCard({required this.item});

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      context.read<SelfCardsBloc>().add(SelectSelfCardEvent(item.id));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: AppColors.forest.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.user,
                    color: AppColors.forest,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.displayName,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.isActive
                                  ? AppColors.forest.withValues(alpha: 0.1)
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.isActive ? 'نشط' : 'غير نشط',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: item.isActive
                                    ? AppColors.forest
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (item.selfNumber != null &&
                              item.selfNumber!.isNotEmpty) ...[
                            Text(
                              'الرقم الذاتي: ${item.selfNumber}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (item.nationalId != null &&
                              item.nationalId!.isNotEmpty) ...[
                            Text(
                              'الرقم الوطني: ${item.nationalId}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (item.educationDegree != null &&
                              item.educationDegree!.isNotEmpty) ...[
                            Text(
                              'المؤهل: ${item.educationDegree}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.charcoal.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Open Details Button
                ElevatedButton.icon(
                  onPressed: handleTap,
                  icon: const Icon(LucideIcons.eye, size: 16),
                  label: const Text('عرض البطاقة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CustomSkeletonLoader(
          width: double.infinity,
          height: 110,
          borderRadius: 16,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 200,
          borderRadius: 14,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 180,
          borderRadius: 14,
        ),
        SizedBox(height: 20),
        CustomSkeletonLoader(
          width: double.infinity,
          height: 220,
          borderRadius: 14,
        ),
      ],
    );
  }
}
