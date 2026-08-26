import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';

class TrainingRecommendationHeader extends StatefulWidget {
  const TrainingRecommendationHeader({super.key});

  @override
  State<TrainingRecommendationHeader> createState() =>
      _TrainingRecommendationHeaderState();
}

class _TrainingRecommendationHeaderState
    extends State<TrainingRecommendationHeader> {
  late final TextEditingController _titleController;
  late final TextEditingController _publicEntityController;
  int _selectedLimit = 20;

  static const List<String> _suggestedCourses = [
    'إدارة المكاتب والمراسلات',
    'الأمن السيبراني وحماية البيانات',
    'القيادة الإدارية الحديثة',
    'استخدام البرمجيات الحكومية',
    'مهارات التواصل وخدمة المواطن',
  ];

  static const List<int> _limitOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _publicEntityController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _publicEntityController.dispose();
    super.dispose();
  }

  void _submitRecommendation() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال اسم الدورة التدريبية أولاً',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.umber,
        ),
      );
      return;
    }

    context.read<SelfCardsBloc>().add(
          RecommendByTrainingEvent(
            title: title,
            limit: _selectedLimit,
            publicEntity: _publicEntityController.text.trim().isNotEmpty
                ? _publicEntityController.text.trim()
                : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelfCardsBloc, SelfCardsState>(
      buildWhen: (prev, curr) =>
          prev.isRecommending != curr.isRecommending ||
          prev.lastRecommendedCourseTitle != curr.lastRecommendedCourseTitle,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title & Icon
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      color: AppColors.forest,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'ترشيح البطاقات الذاتية حسب الدورات التدريبية',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forest.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'خوارزمية المطابقة الذكية',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'أدخل اسم الدورة التدريبية ليقوم النظام بترشيح الموظفين الذين لم يحضروا هذه الدورة أو ما يماثلها، حسب الأولوية وتاريخ التدريب',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoal.withValues(alpha: 0.7),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Inputs Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: TextDirection.rtl,
                          children: [
                            // Course Title (Main)
                            Expanded(
                              flex: 5,
                              child: _buildCourseTitleField(state),
                            ),
                            const SizedBox(width: 14),
                            // Public Entity (Optional)
                            Expanded(
                              flex: 3,
                              child: _buildPublicEntityField(),
                            ),
                            const SizedBox(width: 14),
                            // Limit Dropdown
                            Expanded(
                              flex: 2,
                              child: _buildLimitSelector(),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCourseTitleField(state),
                            const SizedBox(height: 14),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Expanded(child: _buildPublicEntityField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildLimitSelector()),
                              ],
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 16),

              // Suggested Course Chips
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'اقتراحات سريعة:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _suggestedCourses.map((suggested) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ActionChip(
                              label: Text(
                                suggested,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor:
                                  AppColors.goldLight.withValues(alpha: 0.6),
                              side: BorderSide(
                                color: AppColors.gold.withValues(alpha: 0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onPressed: () {
                                _titleController.text = suggested;
                                _submitRecommendation();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  ElevatedButton.icon(
                    onPressed:
                        state.isRecommending ? null : _submitRecommendation,
                    icon: state.isRecommending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.sparkles, size: 18),
                    label: Text(
                      state.isRecommending
                          ? 'جاري فحص السجلات والترشيح...'
                          : 'بدء ترشيح الموظفين',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_titleController.text.isNotEmpty ||
                      state.recommendationResult != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _titleController.clear();
                          _publicEntityController.clear();
                        });
                        context
                            .read<SelfCardsBloc>()
                            .add(const ClearTrainingRecommendationEvent());
                      },
                      icon: const Icon(LucideIcons.rotateCcw, size: 16),
                      label: const Text('إعادة ضبط'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.charcoal,
                        side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseTitleField(SelfCardsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عنوان الدورة التدريبية المطلوبة *',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          textDirection: TextDirection.rtl,
          onSubmitted: (_) => _submitRecommendation(),
          decoration: InputDecoration(
            hintText: 'مثال: الذكاء الاصطناعي في الإدارة الحكومية...',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(
              LucideIcons.graduationCap,
              color: AppColors.forest,
              size: 20,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.forest,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublicEntityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الجهة العامة (اختياري)',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _publicEntityController,
          textDirection: TextDirection.rtl,
          onSubmitted: (_) => _submitRecommendation(),
          decoration: InputDecoration(
            hintText: 'فلترة حسب الجهة / الوزارة...',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
            prefixIcon: const Icon(
              LucideIcons.building2,
              color: AppColors.forest,
              size: 18,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.forest,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العدد الأقصى',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _selectedLimit,
          items: _limitOptions.map((limit) {
            return DropdownMenuItem<int>(
              value: limit,
              child: Text(
                '$limit موظف',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalDark,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedLimit = val);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.gold.withValues(alpha: 0.35),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.forest,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
