import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../../../shared/theme/app_colors.dart';

class WorkflowTimelineWidget extends StatelessWidget {
  final List<dynamic> completedStages;
  final Map<String, dynamic>? currentStage;
  final bool isLocked;
  final String? status;

  const WorkflowTimelineWidget({
    super.key,
    required this.completedStages,
    required this.currentStage,
    required this.isLocked,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final steps = <Map<String, dynamic>>[];

    for (final stage in completedStages) {
      final name = stage['stage_name']?.toString() ??
          stage['form_name']?.toString() ??
          '';
      final completedBy = stage['completed_by_name']?.toString() ?? 'الموظف المختص';
      final completedAt = stage['completed_at']?.toString() ?? '';

      steps.add({
        'title': name,
        'operator': completedBy,
        'time': completedAt,
        'details': stage['note']?.toString() ?? '',
        'state': 'checked',
      });
    }

    if (currentStage != null) {
      final name = currentStage!['name']?.toString() ?? '';
      final completed = status == 'completed';
      final rejected = status == 'rejected';

      steps.add({
        'title': name,
        'operator': completed
            ? 'تم التوقيع والموافقة'
            : (rejected
                ? 'تم الرفض'
                : (isLocked
                    ? 'جاري اتخاذ القرار والتوقيع'
                    : 'بانتظار الاستلام والقرار')),
        'time': '',
        'details': '',
        'state': completed
            ? 'checked'
            : (rejected ? 'rejected' : (isLocked ? 'active_edit' : 'active')),
      });
    }

    if (status != 'completed' && status != 'rejected') {
      steps.add({
        'title': 'الجهة المختصة',
        'operator': 'للاطلاع والتوجيه',
        'time': '',
        'details': '',
        'state': 'pending_flag',
      });
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مسار سير العمل',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                return Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildTimelineNode(step['state'] as String),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            color: const Color(0xFFE0E0E0),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: step['state'] == 'checked'
                                        ? AppColors.charcoalDark
                                        : (step['state'] == 'active' ||
                                                step['state'] == 'active_edit'
                                            ? AppColors.forest
                                            : AppColors.charcoal
                                                .withOpacity(0.6)),
                                  ),
                                ),
                              ),
                              if ((step['time'] as String).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  step['time'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.charcoal.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['operator'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: step['state'] == 'active' ||
                                      step['state'] == 'active_edit'
                                  ? AppColors.forestLight
                                  : AppColors.charcoal.withOpacity(0.6),
                              fontWeight: step['state'] == 'active' ||
                                      step['state'] == 'active_edit'
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                          if ((step['details'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                step['details'] as String,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.charcoal.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode(String state) {
    if (state == 'checked') {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(LucideIcons.check, color: Color(0xFF2E7D32), size: 14),
      );
    } else if (state == 'active_edit') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.forest, width: 2),
        ),
        child: const Icon(LucideIcons.edit2, color: AppColors.forest, size: 12),
      );
    } else if (state == 'active') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.forest, width: 2),
        ),
        child: Center(
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    } else if (state == 'rejected') {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.x, color: Color(0xFFC62828), size: 14),
      );
    } else if (state == 'pending_flag') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.charcoal.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(LucideIcons.flag,
            color: AppColors.charcoal.withOpacity(0.5), size: 12),
      );
    } else {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.charcoal.withOpacity(0.3), width: 1.5),
        ),
      );
    }
  }
}
