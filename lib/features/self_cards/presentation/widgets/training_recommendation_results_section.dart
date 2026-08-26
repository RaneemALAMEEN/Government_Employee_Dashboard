import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/training_recommendation_entity.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';

class TrainingRecommendationResultsSection extends StatelessWidget {
  final SelfCardsState state;

  const TrainingRecommendationResultsSection({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isRecommending) {
      return const Column(
        children: [
          ListSkeletonLoader(itemCount: 4, itemHeight: 120),
        ],
      );
    }

    if (state.recommendationError != null) {
      return AppErrorWidget(
        title: 'تعذر ترشيح البطاقات الذاتية',
        message: state.recommendationError!,
        onRetry: () {
          if (state.lastRecommendedCourseTitle.isNotEmpty) {
            context.read<SelfCardsBloc>().add(
                  RecommendByTrainingEvent(
                    title: state.lastRecommendedCourseTitle,
                  ),
                );
          }
        },
      );
    }

    final result = state.recommendationResult;

    if (result == null) {
      return _buildInitialGuideContainer();
    }

    if (result.items.isEmpty) {
      return _buildEmptyResultsContainer(result);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary & Metric Cards
        FadeInDown(
          duration: const Duration(milliseconds: 250),
          child: _RecommendationSummaryCard(result: result),
        ),
        const SizedBox(height: 16),

        // List Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قائمة الموظفين المرشحين (${result.items.length} مرشح)',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              Text(
                'مرتبة حسب الأولوية وتاريخ التدريب',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Candidates List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: result.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final candidate = result.items[index];
            return FadeInUp(
              duration: const Duration(milliseconds: 300),
              delay: Duration(milliseconds: (index % 8) * 35),
              child: _CandidateCard(
                candidate: candidate,
                index: index + 1,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInitialGuideContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.forest.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 32,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'جاهز لترشيح الموظفين للدورات التدريبية',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Text(
                'أدخل اسم الدورة التدريبية في النموذج أعلاه واضغط على "بدء ترشيح الموظفين" لفحص السجلات الذاتية واستخراج قائمة بالموظفين المؤهلين للتدريب.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResultsContainer(TrainingRecommendationResultEntity result) {
    return AppEmptySearchState(
      title: 'لم يتم العثور على مرشحين جدد لهذه الدورة',
      description:
          'قد يكون جميع الموظفين في النطاق المحدد قد حضروا دورات مماثلة للدورة "${result.query.title}" مسبقاً، أو لا توجد بطاقات ذاتية مطابقة للمحددات.',
    );
  }
}

class _RecommendationSummaryCard extends StatelessWidget {
  final TrainingRecommendationResultEntity result;

  const _RecommendationSummaryCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.forest.withValues(alpha: 0.05),
            AppColors.gold.withValues(alpha: 0.12),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.25)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _buildStatItem(
                  icon: LucideIcons.users,
                  label: 'إجمالي المرشحين',
                  value: '${result.totalCandidates}',
                  color: AppColors.forest,
                ),
                const SizedBox(width: 24),
                _buildStatItem(
                  icon: LucideIcons.listFilter,
                  label: 'النتائج المعروضة',
                  value: '${result.returned}',
                  color: AppColors.charcoalDark,
                ),
                if (result.query.matchThreshold != null) ...[
                  const SizedBox(width: 24),
                  _buildStatItem(
                    icon: LucideIcons.percent,
                    label: 'حد التطابق',
                    value:
                        '${((result.query.matchThreshold!) * 100).toStringAsFixed(0)}%',
                    color: AppColors.goldDark,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                const Icon(
                  LucideIcons.graduationCap,
                  size: 16,
                  color: AppColors.forest,
                ),
                const SizedBox(width: 6),
                Text(
                  'الدورة: ${result.query.title}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.charcoal.withValues(alpha: 0.65),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final TrainingRecommendationCandidateEntity candidate;
  final int index;

  const _CandidateCard({
    required this.candidate,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      context.read<SelfCardsBloc>().add(SelectSelfCardEvent(candidate.id));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(14),
          hoverColor: AppColors.forest.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Candidate Index & Avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.forest.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.forest.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: AppColors.forest,
                        size: 26,
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$index',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Main Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Name + Reason Badge + Active status
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            candidate.displayName,
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Reason Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.rtl,
                              children: [
                                const Icon(
                                  LucideIcons.info,
                                  size: 12,
                                  color: AppColors.charcoalDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  candidate.reasonDescription,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.charcoalDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Active badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: candidate.isActive
                                  ? AppColors.forest.withValues(alpha: 0.1)
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              candidate.isActive ? 'نشط' : 'غير نشط',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: candidate.isActive
                                    ? AppColors.forest
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Details Tags Row
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        textDirection: TextDirection.rtl,
                        children: [
                          if (candidate.nationalId != null &&
                              candidate.nationalId!.isNotEmpty) ...[
                            _buildDetailItem(
                              icon: LucideIcons.hash,
                              text: 'الرقم الوطني: ${candidate.nationalId}',
                            ),
                          ],
                          if (candidate.selfNumber != null &&
                              candidate.selfNumber!.isNotEmpty) ...[
                            _buildDetailItem(
                              icon: LucideIcons.idCard,
                              text: 'الرقم الذاتي: ${candidate.selfNumber}',
                            ),
                          ],
                          if (candidate.publicEntity != null &&
                              candidate.publicEntity!.isNotEmpty) ...[
                            _buildDetailItem(
                              icon: LucideIcons.building2,
                              text: 'الجهة: ${candidate.publicEntity}',
                            ),
                          ],
                          _buildDetailItem(
                            icon: LucideIcons.graduationCap,
                            text:
                                'الدورات السابقة: ${candidate.trainingCoursesCount} دورة',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Open Full Self-Card Details Button
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

  Widget _buildDetailItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.rtl,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.charcoal.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
