import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:government_employee_dashboard/features/internal_transactions/data/models/dynamic_widget_model.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/utils/app_file_downloader.dart';

class StageHistoryCard extends StatelessWidget {
  final Map<String, dynamic> stage;
  final String Function(String) buildFileUrl;
  final void Function(String path, String filename, {String? documentType}) onDownloadFile;

  const StageHistoryCard({
    super.key,
    required this.stage,
    required this.buildFileUrl,
    required this.onDownloadFile,
  });

  @override
  Widget build(BuildContext context) {
    final stageName = stage['stage_name']?.toString() ??
        stage['form_name']?.toString() ??
        'مرحلة سابقة';
    final rawWidgets = stage['widgets'] as List? ?? [];

    final widgets = rawWidgets
        .map((w) => DynamicWidgetModel.fromJson(Map<String, dynamic>.from(w)))
        .toList();

    final completedBy =
        stage['completed_by_name']?.toString() ?? 'الموظف المختص';
    final completedAt = stage['completed_at']?.toString() ?? '';
    final decision = stage['decision']?.toString();
    final note = stage['note']?.toString();
    final rejectionReason = stage['rejection_reason']?.toString();

    // Decision display
    String decisionLabel = '';
    Color decisionBg = Colors.transparent;
    Color decisionFg = Colors.transparent;
    IconData decisionIcon = LucideIcons.circle;

    if (decision == 'approve') {
      decisionLabel = 'تمت الموافقة';
      decisionBg = AppColors.forest.withValues(alpha: 0.08);
      decisionFg = AppColors.forest;
      decisionIcon = LucideIcons.circleCheck;
    } else if (decision == 'reject') {
      decisionLabel = 'رفض';
      decisionBg = Colors.red.shade50;
      decisionFg = Colors.red.shade700;
      decisionIcon = LucideIcons.circleX;
    }

    // Set decision to null if it's submit so it won't be displayed
    final displayDecision = (decision == 'submit') ? null : decision;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.fileCheck,
                    color: AppColors.forest, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ),
                if (displayDecision != null && displayDecision.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: decisionBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(decisionIcon, size: 14, color: decisionFg),
                        const SizedBox(width: 4),
                        Text(
                          decisionLabel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: decisionFg,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'بواسطة: $completedBy',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.charcoal.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                if (completedAt.isNotEmpty)
                  Text(
                    'بتاريخ: $completedAt',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),

            // Rejection reason
            if (rejectionReason != null && rejectionReason.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.messageCircleX,
                        size: 16, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'سبب الرفض:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rejectionReason,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.red.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Note
            if (note != null && note.trim().isNotEmpty && note != rejectionReason) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(LucideIcons.messageSquare,
                        size: 16, color: AppColors.goldDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          const Text(
                            'ملاحظة:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            note,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Sealed badge if stage was sealed with USB signature
            if (stage['sealed'] == true) ...[
              const SizedBox(height: 8),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: AppColors.forest.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.shieldCheck,
                            size: 13, color: AppColors.forest),
                        SizedBox(width: 4),
                        Text(
                          'مرحلة مختومة وموقّعة رقمياً بالـ USB',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),
            Divider(height: 1, color: AppColors.charcoal.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            ...widgets.map((widgetConfig) {
              final val = widgetConfig.widgetType == 'file_picker'
                  ? null
                  : _findWidgetValue(rawWidgets, widgetConfig.data['id']);

              if (widgetConfig.widgetType == 'file_picker') {
                final filesVal =
                    _findWidgetValue(rawWidgets, widgetConfig.data['id']);
                return _buildFilePickerReadonly(
                    context, widgetConfig, filesVal);
              }

              return _buildReadonlyField(widgetConfig, val);
            }),

            // Render templates if present in the stage
            if ((stage['templates'] as List? ?? []).isNotEmpty) ...[
              const SizedBox(height: 16),
              Divider(
                  height: 1,
                  color: AppColors.charcoal.withValues(alpha: 0.1)),
              const SizedBox(height: 14),
              const Text(
                'المستندات والقوالب المولدة في هذه المرحلة:',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 10),
              ...(stage['templates'] as List).map((templateItem) {
                final templateMap = templateItem is Map<String, dynamic>
                    ? templateItem
                    : Map<String, dynamic>.from(templateItem as Map);
                return _buildTemplateItem(context, templateMap);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateItem(
      BuildContext context, Map<String, dynamic> template) {
    final templateId = template['id_template'] ??
        template['template_id'] ??
        template['id'];
    final templateName = template['name']?.toString() ??
        template['template_name']?.toString() ??
        template['title']?.toString() ??
        'قالب وثيقة';
    final val = template['value'];
    final valMap =
        val is Map ? Map<String, dynamic>.from(val) : <String, dynamic>{};

    final generatedPdfUrl = valMap['generated_pdf_url']?.toString() ??
        valMap['generated_pdf_path']?.toString() ??
        valMap['pdf_url']?.toString() ??
        valMap['file_url']?.toString() ??
        template['generated_pdf_url']?.toString() ??
        template['generated_pdf_path']?.toString() ??
        template['pdf_url']?.toString() ??
        template['file_url']?.toString();

    final stageName = stage['stage_name']?.toString() ??
        stage['form_name']?.toString() ??
        'مرحلة سابقة';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(LucideIcons.fileCode,
                    size: 16, color: AppColors.forest),
              ),
              const SizedBox(width: 8),
              Text(
                templateName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
          if (generatedPdfUrl != null && generatedPdfUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.forest.withValues(alpha: 0.2)),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEEEF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(LucideIcons.fileText,
                        color: Color(0xFFC62828), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          'المستند المولد للقالب (PDF)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoalDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'نسخة PDF معتمدة ومولدة تلقائياً',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(LucideIcons.eye,
                        size: 16, color: AppColors.forest),
                    tooltip: 'عرض المستند',
                    onPressed: () {
                      final fullUrl = buildFileUrl(generatedPdfUrl);
                      context.push('/pdf-viewer', extra: fullUrl);
                    },
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.download,
                        size: 16, color: AppColors.goldDark),
                    tooltip: 'تحميل المستند',
                    onPressed: () {
                      onDownloadFile(generatedPdfUrl, 'قالب_$templateId.pdf',
                          documentType: 'قالب مرحلة - $stageName');
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  dynamic _findWidgetValue(List<dynamic> rawWidgets, dynamic id) {
    for (final w in rawWidgets) {
      if (w is Map && w['data'] != null && w['data']['id'] == id) {
        return w['value'];
      }
    }
    return null;
  }

  String _formatValue(dynamic val) {
    if (val == null) return '-';
    if (val is List) {
      if (val.isEmpty) return '-';
      return val.map((item) {
        if (item is Map) {
          return item['original_name']?.toString() ??
              item['path']?.toString() ??
              item.toString();
        }
        return item.toString();
      }).join('، ');
    }
    if (val is Map) {
      return val['value']?.toString() ??
          val['name']?.toString() ??
          val.toString();
    }
    return val.toString();
  }

  Widget _buildReadonlyField(DynamicWidgetEntity widgetEntity, dynamic val) {
    final label = widgetEntity.data['label']?.toString() ?? '';
    final formattedVal = _formatValue(val);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formattedVal,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoalDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerReadonly(
      BuildContext context, DynamicWidgetEntity widgetEntity, dynamic val) {
    final label = widgetEntity.data['label']?.toString() ?? 'مرفقات';
    final filesList = val is List ? val : [];
    final stageName = stage['stage_name']?.toString() ??
        stage['form_name']?.toString() ??
        'مرحلة سابقة';

    if (filesList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            textDirection: TextDirection.rtl,
            spacing: 12,
            runSpacing: 12,
            children: filesList.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value as Map;
              final rawPath = file['url']?.toString() ?? file['path']?.toString() ?? '';
              final realExt = AppFileDownloader.extractExtension(
                rawPath,
                fallbackExtension: 'png',
              );
              final isImage = [
                'jpg',
                'jpeg',
                'png',
                'gif',
                'bmp',
                'webp'
              ].contains(realExt);

              var filename = label.trim().isNotEmpty && label.trim() != 'مرفقات'
                  ? (filesList.length > 1 ? '${label.trim()} (${index + 1})' : label.trim())
                  : (file['original_name']?.toString() ?? file['name']?.toString() ?? '');
              if (filename.isEmpty || filename == 'ملف_مرفق.pdf' || filename == 'ملف_مرفق') {
                filename = isImage ? 'صورة_مرفقة.$realExt' : 'مستند_مرفق.$realExt';
              } else if (isImage && filename.toLowerCase().endsWith('.pdf')) {
                filename = '${filename.substring(0, filename.length - 4)}.$realExt';
              }

              return Container(
                width: 320,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isImage ? const Color(0xFFEFF6FF) : const Color(0xFFFDEEEF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isImage ? LucideIcons.image : LucideIcons.fileText,
                        color: isImage ? const Color(0xFF1D4ED8) : const Color(0xFFC62828),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        filename,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View file button
                    IconButton(
                      icon: const Icon(LucideIcons.eye,
                          size: 16, color: AppColors.forest),
                      tooltip: 'عرض الملف',
                      onPressed: () {
                        if (rawPath.isNotEmpty) {
                          final fileUrl = buildFileUrl(rawPath);
                          if (isImage) {
                            context.push('/image-viewer', extra: {
                              'fileUrl': fileUrl,
                              'title': filename,
                            });
                          } else {
                            context.push('/pdf-viewer', extra: {
                              'fileUrl': fileUrl,
                              'title': filename,
                            });
                          }
                        }
                      },
                    ),
                    // Download file button
                    IconButton(
                      icon: const Icon(LucideIcons.download,
                          size: 16, color: AppColors.goldDark),
                      tooltip: 'تحميل الملف',
                      onPressed: () {
                        if (rawPath.isNotEmpty) {
                          onDownloadFile(rawPath, filename,
                              documentType: 'مرفق - $stageName');
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
