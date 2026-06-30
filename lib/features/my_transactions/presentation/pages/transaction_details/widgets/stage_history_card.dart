import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:government_employee_dashboard/features/internal_transactions/data/models/dynamic_widget_model.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../shared/theme/app_colors.dart';
import '../../pdf_viewer_page.dart';
import '../../image_viewer_page.dart';

class StageHistoryCard extends StatelessWidget {
  final Map<String, dynamic> stage;
  final String Function(String) buildFileUrl;
  final void Function(String path, String filename) onDownloadFile;

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

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
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
                    color: AppColors.charcoal.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                if (completedAt.isNotEmpty)
                  Text(
                    'بتاريخ: $completedAt',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.charcoal.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: AppColors.charcoal.withOpacity(0.1)),
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
          ],
        ),
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
            children: filesList.map((fileMap) {
              final file = fileMap as Map;
              final filename =
                  file['original_name']?.toString() ?? 'ملف_مرفق.pdf';

              return Container(
                width: 320,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withOpacity(0.18)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDEEEF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.fileText,
                        color: Color(0xFFC62828),
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
                        final path = file['path']?.toString() ?? '';
                        if (path.isNotEmpty) {
                          final fileUrl = buildFileUrl(path);
                          final ext = path.split('.').last.toLowerCase();
                          final isImage = [
                            'jpg',
                            'jpeg',
                            'png',
                            'gif',
                            'bmp',
                            'webp'
                          ].contains(ext);

                          if (isImage) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ImageViewerPage(
                                  fileUrl: fileUrl,
                                  title: filename,
                                ),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPage(
                                  fileUrl: fileUrl,
                                  title: filename,
                                ),
                              ),
                            );
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
                        final path = file['path']?.toString() ?? '';
                        if (path.isNotEmpty) {
                          onDownloadFile(path, filename);
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
