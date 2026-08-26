import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/training_course_entity.dart';

class SelfCardTrainingCoursesTable extends StatelessWidget {
  final List<TrainingCourseEntity> trainingCourses;

  const SelfCardTrainingCoursesTable({
    super.key,
    required this.trainingCourses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.gold.withValues(alpha: 0.25)),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.graduationCap, color: AppColors.forest, size: 20),
                const SizedBox(width: 10),
                Text(
                  'الدورات التدريبية المعتمدة',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forest,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${trainingCourses.length} دورة',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          if (trainingCourses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.bookOpenCheck,
                        size: 30,
                        color: AppColors.goldDark.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'لا توجد دورات تدريبية مسجلة',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'لم يتم تسجيل أي دورات تدريبية لهذا الموظف في السجلات الحالية',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 850),
                child: DataTable(
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.goldLight.withValues(alpha: 0.35),
                  ),
                  headingTextStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.forest,
                  ),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (states.contains(WidgetState.hovered)) {
                        return AppColors.forest.withValues(alpha: 0.04);
                      }
                      return null;
                    },
                  ),
                  columns: const [
                    DataColumn(label: Text('م')),
                    DataColumn(label: Text('عنوان الدورة')),
                    DataColumn(label: Text('الجهة المنظمة')),
                    DataColumn(label: Text('الموضوع')),
                    DataColumn(label: Text('تاريخ البدء')),
                    DataColumn(label: Text('تاريخ الانتهاء')),
                    DataColumn(label: Text('المدة')),
                    DataColumn(label: Text('رقم الشهادة')),
                    DataColumn(label: Text('ملاحظات')),
                  ],
                  rows: List<DataRow>.generate(
                    trainingCourses.length,
                    (index) {
                      final course = trainingCourses[index];
                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(
                            Text(
                              course.title,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                          ),
                          DataCell(Text(course.provider.isNotEmpty ? course.provider : '-')),
                          DataCell(Text(course.topic.isNotEmpty ? course.topic : '-')),
                          DataCell(Text(course.startDate ?? '-')),
                          DataCell(Text(course.endDate ?? '-')),
                          DataCell(Text(course.duration ?? '-')),
                          DataCell(
                            Text(
                              course.certificateNumber?.isNotEmpty == true
                                  ? course.certificateNumber!
                                  : '-',
                            ),
                          ),
                          DataCell(
                            Text(
                              course.notes?.isNotEmpty == true ? course.notes! : '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
