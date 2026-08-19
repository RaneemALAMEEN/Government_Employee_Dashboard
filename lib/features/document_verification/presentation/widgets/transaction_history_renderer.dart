import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../../../shared/utils/app_file_url.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/document_verification_entity.dart';

class TransactionHistoryTimeline extends StatefulWidget {
  final TransactionHistoryEntity history;

  const TransactionHistoryTimeline({super.key, required this.history});

  @override
  State<TransactionHistoryTimeline> createState() =>
      _TransactionHistoryTimelineState();
}

class _TransactionHistoryTimelineState
    extends State<TransactionHistoryTimeline> {
  final Set<int> _expanded = {0};

  @override
  Widget build(BuildContext context) {
    final stages = widget.history.data.stages;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _historyDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.history,
                  color: AppColors.forest,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'سجل مراحل المعاملة',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: AppTextStyles.semiBold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    if (widget.history.processName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.history.processName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (stages.isEmpty)
            _HistoryEmptyState(
              message: widget.history.idProcess.isEmpty
                  ? 'لا يتوفر سجل تفصيلي لمراحل هذه المعاملة'
                  : 'لا توجد مراحل مسجلة لهذه المعاملة',
            )
          else
            ...List.generate(
              stages.length,
              (index) => _TimelineStage(
                index: index,
                stage: stages[index],
                applicantName: widget.history.data.applicant?.fullName,
                expanded: _expanded.contains(index),
                isLast: index == stages.length - 1,
                onToggle: () => setState(() {
                  if (!_expanded.remove(index)) _expanded.add(index);
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineStage extends StatelessWidget {
  final int index;
  final TransactionHistoryStageEntity stage;
  final String? applicantName;
  final bool expanded;
  final bool isLast;
  final VoidCallback onToggle;

  const _TimelineStage({
    required this.index,
    required this.stage,
    this.applicantName,
    required this.expanded,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = stage.widgets;
    final valuedCount = widgets.where(_hasActualValue).length;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          // Step indicator: Circle badge
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Main Stage Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: expanded
                      ? AppColors.forest.withValues(alpha: 0.35)
                      : AppColors.gold.withValues(alpha: 0.22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.forest.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stage.isDocumentGeneration
                                    ? LucideIcons.fileCog
                                    : LucideIcons.clipboardCheck,
                                size: 18,
                                color: AppColors.forest,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                textDirection: TextDirection.rtl,
                                children: [
                                  Text(
                                    stage.displayName,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.charcoalDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    textDirection: TextDirection.rtl,
                                    spacing: 8,
                                    runSpacing: 5,
                                    children: [
                                      if (stage.decision?.isNotEmpty == true)
                                        _DecisionBadge(
                                          decision: stage.decision!,
                                        ),
                                      if (stage.completedAt != null)
                                        _MetaChip(
                                          text: formatHistoryDate(
                                            stage.completedAt,
                                          ),
                                          icon: LucideIcons.calendarDays,
                                          type: _ChipType.date,
                                        ),
                                      if (valuedCount > 0)
                                        _MetaChip(
                                          text:
                                              '$valuedCount ${valuedCount == 1 ? 'حقل' : 'حقول'}',
                                          icon: LucideIcons.listChecks,
                                          type: _ChipType.count,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: expanded ? .5 : 0,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                LucideIcons.chevronDown,
                                size: 19,
                                color: AppColors.charcoal.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (expanded)
                    _StageDetails(
                      stage: stage,
                      widgets: widgets,
                      applicantName: applicantName,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageDetails extends StatelessWidget {
  final TransactionHistoryStageEntity stage;
  final List<TransactionHistoryWidgetEntity> widgets;
  final String? applicantName;

  const _StageDetails({
    required this.stage,
    required this.widgets,
    this.applicantName,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Divider(
              color: AppColors.gold.withValues(alpha: 0.18),
              height: 1,
            ),
            const SizedBox(height: 14),
            if (stage.note?.isNotEmpty == true &&
                stage.note != stage.rejectionReason)
              _MessageBox(label: 'ملاحظة', value: stage.note!),
            if (stage.rejectionReason?.isNotEmpty == true)
              _MessageBox(
                label: 'سبب الرفض',
                value: stage.rejectionReason!,
                warning: true,
              ),
            if (stage.isDocumentGeneration)
              _GeneratedDocumentStage(
                stage: stage,
                applicantName: applicantName,
              )
            else if (widgets.isEmpty && stage.templates.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'لا توجد قيم مدخلة ضمن هذه المرحلة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else if (widgets.isNotEmpty)
              LayoutBuilder(
                builder: (_, constraints) {
                  final oneColumn = constraints.maxWidth < 720;
                  final width = oneColumn
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    textDirection: TextDirection.rtl,
                    spacing: 10,
                    runSpacing: 10,
                    children: widgets
                        .map(
                          (item) => SizedBox(
                            width: _requiresFullWidth(item)
                                ? constraints.maxWidth
                                : width,
                            child: TransactionHistoryValueRenderer(
                              widget: item,
                              stageName: stage.displayName,
                              applicantName: applicantName,
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            if (!stage.isDocumentGeneration && stage.templates.isNotEmpty) ...[
              if (widgets.isNotEmpty) const SizedBox(height: 12),
              _TemplateValues(
                templates: stage.templates,
                stage: stage,
                applicantName: applicantName,
                excludedValues: widgets.map((item) => item.value).toList(),
              ),
            ],
          ],
        ),
      );
}

class _TemplateValues extends StatelessWidget {
  final List<TransactionHistoryTemplateEntity> templates;
  final TransactionHistoryStageEntity stage;
  final String? applicantName;
  final List<dynamic> excludedValues;

  const _TemplateValues({
    required this.templates,
    required this.stage,
    this.applicantName,
    required this.excludedValues,
  });

  @override
  Widget build(BuildContext context) {
    final excluded = excludedValues.map((value) => value?.toString()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.rtl,
      children: templates.map((template) {
        return _SingleTemplateCard(
          template: template,
          stage: stage,
          applicantName: applicantName,
          excluded: excluded,
        );
      }).toList(),
    );
  }
}

class _SingleTemplateCard extends StatelessWidget {
  final TransactionHistoryTemplateEntity template;
  final TransactionHistoryStageEntity stage;
  final String? applicantName;
  final Set<String?> excluded;

  const _SingleTemplateCard({
    required this.template,
    required this.stage,
    this.applicantName,
    required this.excluded,
  });

  @override
  Widget build(BuildContext context) {
    final values = template.values;

    // 1. Extract Template ID & Name
    final templateId = values['id_template'] ??
        values['template_id'] ??
        values['id_document_instance'] ??
        values['document_instance_id'] ??
        values['id'];

    final templateName = values['name']?.toString() ??
        values['template_name']?.toString() ??
        values['title']?.toString() ??
        (templateId != null ? 'قالب وثيقة #$templateId' : 'قالب الوثيقة');

    // 2. Extract PDF URL / Path
    final rawPdfUrl = _firstReadable([
      values['generated_pdf_url'],
      values['generated_pdf_path'],
      values['pdf_url'],
      values['file_url'],
      values['url'],
      stage.generatedPdfUrl,
      stage.generatedDocument?.url,
    ]);

    // 3. Extract user-facing template field entries (filtering out technical metadata)
    final entries = <MapEntry<String, String>>[];
    for (final entry in values.entries) {
      if (_technicalTemplateKeys.contains(entry.key.toLowerCase())) continue;
      final value = entry.value;
      if (value == null) continue;
      if (value is! String && value is! num && value is! bool) continue;
      final readable =
          value is bool ? (value ? 'نعم' : 'لا') : value.toString().trim();
      if (readable.isEmpty || excluded.contains(value.toString())) {
        continue;
      }
      entries.add(MapEntry(_templateLabel(entry.key), readable));
    }

    final hasPdf = rawPdfUrl.isNotEmpty;
    final hasFields = entries.isNotEmpty;

    if (!hasPdf && !hasFields) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          // Template Header
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.forest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  LucideIcons.layoutTemplate,
                  size: 16,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'بيانات ومستند القالب: $templateName',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalDark,
                ),
              ),
              const Spacer(),
              if (templateId != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    'ID: $templateId',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ),
            ],
          ),

          // PDF Document Preview & Download Box
          if (hasPdf) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.forest.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDEEEF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.fileText,
                      color: Color(0xFFC62828),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        const Text(
                          'المستند المولد للقالب (PDF)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoalDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'نسخة PDF معتمدة ومولدة تلقائياً من القالب',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.charcoal.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // View PDF Button
                  OutlinedButton.icon(
                    onPressed: () => _openPdfInsideApp(
                      context,
                      rawPdfUrl,
                      'قالب_$templateName',
                    ),
                    icon: const Icon(LucideIcons.eye, size: 15),
                    label: const Text('عرض المستند'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: BorderSide(color: AppColors.forest.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Download PDF Button
                  ElevatedButton.icon(
                    onPressed: () => _downloadFileFromUrl(
                      context,
                      rawUrl: rawPdfUrl,
                      defaultFilename: 'قالب_${templateId ?? "وثيقة"}.pdf',
                      documentType: 'قالب مرحلة - ${stage.displayName}',
                      applicantName: applicantName,
                    ),
                    icon: const Icon(LucideIcons.download, size: 15),
                    label: const Text('تنزيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Dynamic Field Values
          if (hasFields) ...[
            const SizedBox(height: 12),
            const Text(
              'البيانات المدخلة في القالب:',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              textDirection: TextDirection.rtl,
              spacing: 8,
              runSpacing: 8,
              children: entries
                  .map(
                    (entry) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${entry.key}: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoal.withValues(alpha: 0.65),
                            ),
                          ),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class TransactionHistoryValueRenderer extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;
  final String stageName;
  final String? applicantName;

  const TransactionHistoryValueRenderer({
    super.key,
    required this.widget,
    required this.stageName,
    this.applicantName,
  });

  @override
  Widget build(BuildContext context) {
    final type = widget.widgetType.toLowerCase();
    if (type == 'file_picker') {
      return _FileValueCard(
        widget: widget,
        stageName: stageName,
        applicantName: applicantName,
      );
    }
    if (type == 'check_list' || widget.value is List) {
      return _ListValueCard(widget: widget);
    }
    if (type == 'dropdown') return _SelectionValueCard(widget: widget);
    if (type == 'date_picker') {
      return _SimpleValueCard(
        widget: widget,
        icon: LucideIcons.calendarDays,
        displayValue: formatInputDate(widget.value),
      );
    }
    return _SimpleValueCard(
      widget: widget,
      icon:
          type == 'text_field' ? LucideIcons.textCursorInput : LucideIcons.info,
      displayValue: readableValue(widget),
    );
  }
}

class _SimpleValueCard extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;
  final IconData icon;
  final String displayValue;

  const _SimpleValueCard({
    required this.widget,
    required this.icon,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) => _ValueShell(
        label: _label(widget),
        icon: icon,
        child: SelectableText(
          displayValue,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalDark,
          ),
        ),
      );
}

class _SelectionValueCard extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;

  const _SelectionValueCard({required this.widget});

  @override
  Widget build(BuildContext context) => _ValueShell(
        label: _label(widget),
        icon: LucideIcons.listFilter,
        child: _ValueChip(text: readableValue(widget)),
      );
}

class _ListValueCard extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;

  const _ListValueCard({required this.widget});

  @override
  Widget build(BuildContext context) {
    final values = widget.value is List ? widget.value as List : const [];
    final readable = values
        .where((value) => value != null)
        .map(_simpleDynamicValue)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return _ValueShell(
      label: _label(widget),
      icon: LucideIcons.listChecks,
      child: readable.isEmpty
          ? const Text('لم يتم إدخال قيمة')
          : Wrap(
              textDirection: TextDirection.rtl,
              spacing: 6,
              runSpacing: 6,
              children: readable
                  .map((value) => _ValueChip(text: value))
                  .toList(growable: false),
            ),
    );
  }
}

class _FileValueCard extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;
  final String stageName;
  final String? applicantName;

  const _FileValueCard({
    required this.widget,
    required this.stageName,
    this.applicantName,
  });

  @override
  Widget build(BuildContext context) {
    final rawFiles =
        widget.value is List ? widget.value as List : [widget.value];
    final label = _label(widget);
    final validFiles = rawFiles.whereType<Map>().toList();
    final files = validFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final map = Map<String, dynamic>.from(entry.value);
      final typeDoc = map['type_doc'] is Map
          ? Map<String, dynamic>.from(map['type_doc'] as Map)
          : <String, dynamic>{};

      String computedName = label;
      if (validFiles.length > 1 && label.isNotEmpty && label != 'بيانات الحقل') {
        computedName = '$label (${index + 1})';
      } else if (label.isEmpty || label == 'بيانات الحقل') {
        computedName = _firstReadable([map['original_name'], map['name']]);
      }

      return (
        url: _firstReadable([map['url'], map['file_url'], map['path']]),
        name: computedName,
        type: _firstReadable([typeDoc['name'], map['mime_type'], map['type']]),
      );
    }).toList(growable: false);

    return _ValueShell(
      label: label,
      icon: LucideIcons.paperclip,
      child: files.isEmpty
          ? const Text('لم يتم إرفاق ملف')
          : Column(
              children: files
                  .map(
                    (file) => _FileTile(
                      url: file.url,
                      name: file.name.isEmpty
                          ? 'عرض $label'
                          : file.name,
                      type: file.type,
                      stageName: stageName,
                      applicantName: applicantName,
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final String url;
  final String name;
  final String type;
  final String stageName;
  final String? applicantName;

  const _FileTile({
    required this.url,
    required this.name,
    required this.type,
    required this.stageName,
    this.applicantName,
  });

  @override
  Widget build(BuildContext context) {
    final isPdfFile = _isPdf(url, name, type);
    final realExt = AppFileDownloader.extractExtension(
      url,
      fallbackExtension: isPdfFile ? 'pdf' : 'png',
    );
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp']
        .contains(realExt.toLowerCase());

    var displayName = name;
    if (displayName.isEmpty ||
        displayName == 'ملف_مرفق.pdf' ||
        displayName == 'ملف_مرفق') {
      displayName = isImage ? 'صورة_مرفقة.$realExt' : 'مستند_مرفق.$realExt';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: isImage
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFFDEEEF),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              isImage ? LucideIcons.image : LucideIcons.fileText,
              color: isImage
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFFC62828),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
                if (type.isNotEmpty)
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.charcoal.withValues(alpha: 0.55),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // View Button
          IconButton(
            icon: const Icon(LucideIcons.eye, size: 16, color: AppColors.forest),
            tooltip: 'عرض الملف',
            onPressed: url.isEmpty
                ? null
                : () {
                    if (isImage) {
                      _openImageInsideApp(context, url, displayName);
                    } else {
                      _openPdfInsideApp(context, url, displayName);
                    }
                  },
          ),
          // Download Button
          IconButton(
            icon: const Icon(
              LucideIcons.download,
              size: 16,
              color: AppColors.goldDark,
            ),
            tooltip: 'تحميل الملف',
            onPressed: url.isEmpty
                ? null
                : () => _downloadFileFromUrl(
                      context,
                      rawUrl: url,
                      defaultFilename: displayName,
                      documentType: 'مرفق - $stageName',
                      applicantName: applicantName,
                    ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedDocumentStage extends StatelessWidget {
  final TransactionHistoryStageEntity stage;
  final String? applicantName;

  const _GeneratedDocumentStage({
    required this.stage,
    this.applicantName,
  });

  @override
  Widget build(BuildContext context) {
    final url = stage.generatedPdfUrl ?? stage.generatedDocument?.url ?? '';
    final hasUrl = url.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.forest.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  color: Color(0xFFC62828),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'توليد الوثيقة الرسمية (PDF)',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUrl
                          ? 'تم إنشاء ملف PDF معتمد خلال هذه المرحلة.'
                          : 'لم يتم إنشاء ملف قابل للعرض في هذه المرحلة.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.charcoal.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasUrl) ...[
            const SizedBox(height: 14),
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _openPdfInsideApp(
                      context,
                      url,
                      'الملف المولّد',
                    ),
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('عرض الملف المولّد'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: BorderSide(color: AppColors.forest.withValues(alpha: 0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadFileFromUrl(
                      context,
                      rawUrl: url,
                      defaultFilename: 'وثيقة_${stage.displayName}.pdf',
                      documentType: 'وثيقة مولدة - ${stage.displayName}',
                      applicantName: applicantName,
                    ),
                    icon: const Icon(LucideIcons.download, size: 16),
                    label: const Text('تحميل الملف'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'هذا ملف ناتج عن مرحلة آلية، وليس بالضرورة الوثيقة النهائية المعتمدة.',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueShell extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const _ValueShell({
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE8E4DC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(icon, size: 14, color: AppColors.forest),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal.withValues(alpha: 0.75),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
}

class _MessageBox extends StatelessWidget {
  final String label;
  final String value;
  final bool warning;

  const _MessageBox({
    required this.label,
    required this.value,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: warning
              ? const Color(0xFFFEF2F2)
              : AppColors.goldLight.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: warning
                ? const Color(0xFFFCA5A5)
                : AppColors.gold.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              warning ? LucideIcons.messageCircleX : LucideIcons.messageSquare,
              size: 16,
              color: warning ? const Color(0xFFDC2626) : AppColors.goldDark,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    '$label:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: warning
                          ? const Color(0xFF991B1B)
                          : AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: warning
                          ? const Color(0xFFB91C1C)
                          : AppColors.charcoalDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

enum _ChipType { date, count }

class _MetaChip extends StatelessWidget {
  final String text;
  final IconData? icon;
  final _ChipType type;

  const _MetaChip({
    required this.text,
    this.icon,
    this.type = _ChipType.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDate = type == _ChipType.date;
    final bg = isDate
        ? const Color(0xFFF3F4F6)
        : AppColors.forest.withValues(alpha: 0.06);
    final border = isDate
        ? const Color(0xFFE5E7EB)
        : AppColors.forest.withValues(alpha: 0.18);
    final fg = isDate ? AppColors.charcoal : AppColors.forest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionBadge extends StatelessWidget {
  final String decision;

  const _DecisionBadge({required this.decision});

  @override
  Widget build(BuildContext context) {
    final lower = decision.trim().toLowerCase();
    String label = decisionText(decision);
    Color bg;
    Color fg;
    Color border;
    IconData icon;

    if (lower == 'approve') {
      bg = AppColors.forest.withValues(alpha: 0.08);
      fg = AppColors.forest;
      border = AppColors.forest.withValues(alpha: 0.25);
      icon = LucideIcons.circleCheck;
    } else if (lower == 'reject') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
      border = const Color(0xFFFECACA);
      icon = LucideIcons.circleX;
    } else if (lower == 'submit') {
      bg = AppColors.goldLight.withValues(alpha: 0.7);
      fg = AppColors.charcoalDark;
      border = AppColors.gold.withValues(alpha: 0.4);
      icon = LucideIcons.send;
    } else {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFB45309);
      border = const Color(0xFFFDE68A);
      icon = LucideIcons.rotateCcw;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final String text;

  const _ValueChip({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalDark,
          ),
        ),
      );
}

class _HistoryEmptyState extends StatelessWidget {
  final String message;

  const _HistoryEmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFA),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
}

// Download & File View Helper Methods
Future<void> _downloadFileFromUrl(
  BuildContext context, {
  required String rawUrl,
  required String defaultFilename,
  String? documentType,
  String? applicantName,
}) async {
  try {
    final absoluteUrl = buildAbsoluteFileUrl(rawUrl);
    if (absoluteUrl.isEmpty) {
      AppSnackBar.show(context, message: 'رابط الملف غير صالح', isError: true);
      return;
    }

    AppSnackBar.show(context, message: 'جاري تحميل الملف...');

    final dio = getIt<Dio>();
    final response = await dio.get<List<int>>(
      absoluteUrl,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': '*/*'},
      ),
    );

    final bytes =
        response.data != null ? Uint8List.fromList(response.data!) : null;

    if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
      throw Exception('فشل في تنزيل الملف');
    }

    final contentType = response.headers.value('content-type');
    final savePath = await AppFileDownloader.getSavePath(
      applicantName: applicantName,
      documentType: documentType ?? 'مستند',
      originalFilename: defaultFilename,
      contentType: contentType,
      bytes: bytes,
      fallbackExtension: 'pdf',
    );

    final file = File(savePath);
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      AppSnackBar.show(
        context,
        title: 'تم التحميل بنجاح',
        message: 'تم حفظ الملف في:\n$savePath',
        isError: false,
      );
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackBar.show(
        context,
        title: 'فشل التحميل',
        message: 'تعذر تحميل الملف، يرجى التأكد من توفره على الخادم.',
        isError: true,
      );
    }
  }
}

Future<void> _openPdfInsideApp(
  BuildContext context,
  String url,
  String title,
) async {
  final absoluteUrl = buildAbsoluteFileUrl(url);
  final uri = Uri.tryParse(absoluteUrl);
  if (uri == null || !uri.hasScheme) {
    AppSnackBar.show(context, message: 'تعذر فتح الملف', isError: true);
    return;
  }
  context.push('/pdf-viewer', extra: {
    'fileUrl': absoluteUrl,
    'title': title,
    'readOnly': true,
  });
}

Future<void> _openImageInsideApp(
  BuildContext context,
  String url,
  String title,
) async {
  final absoluteUrl = buildAbsoluteFileUrl(url);
  final uri = Uri.tryParse(absoluteUrl);
  if (uri == null || !uri.hasScheme) {
    AppSnackBar.show(context, message: 'تعذر فتح الصورة', isError: true);
    return;
  }
  context.push('/image-viewer', extra: {
    'fileUrl': absoluteUrl,
    'title': title,
  });
}

bool _hasActualValue(TransactionHistoryWidgetEntity widget) {
  final value = widget.value;
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  return true;
}

bool _requiresFullWidth(TransactionHistoryWidgetEntity widget) =>
    widget.widgetType.toLowerCase() == 'file_picker' ||
    (widget.value is List && (widget.value as List).length > 4);

String _label(TransactionHistoryWidgetEntity widget) =>
    widget.data.label.trim().isEmpty
        ? 'بيانات الحقل'
        : widget.data.label.trim();

String readableValue(TransactionHistoryWidgetEntity widget) {
  final value = widget.value;
  if (value == null || (value is String && value.trim().isEmpty)) {
    return 'لم يتم إدخال قيمة';
  }
  if (_label(widget).contains('الرقم الوطني')) {
    return _maskNationalId(value.toString());
  }
  if (value is bool) return value ? 'نعم' : 'لا';
  if (value is num || value is String) return value.toString();
  if (kDebugMode) {
    debugPrint('[DocumentVerification] Unsupported widget value: $value');
  }
  return 'توجد بيانات إضافية لهذه الخطوة';
}

String _simpleDynamicValue(dynamic value) {
  if (value is bool) return value ? 'نعم' : 'لا';
  if (value is String || value is num) return value.toString();
  if (value is Map) {
    return _firstReadable([value['label'], value['name'], value['value']]);
  }
  return '';
}

String formatInputDate(dynamic value) {
  final raw = value?.toString() ?? '';
  final parsed = DateTime.tryParse(raw);
  return parsed == null
      ? (raw.isEmpty ? 'لم يتم إدخال قيمة' : raw)
      : formatHistoryDate(parsed);
}

String formatHistoryDate(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String decisionText(String value) {
  switch (value.trim().toLowerCase()) {
    case 'submit':
      return 'تم الإرسال';
    case 'approve':
      return 'تمت الموافقة';
    case 'reject':
      return 'تم الرفض';
    case 'return':
      return 'تمت الإعادة';
    case 'cancel':
      return 'تم الإلغاء';
    default:
      return value.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}

String _maskNationalId(String value) {
  if (value.length <= 4) return '*' * value.length;
  return '${value.substring(0, 3)}${'*' * (value.length - 5)}${value.substring(value.length - 2)}';
}

String _firstReadable(List<dynamic> values) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return '';
}

const _technicalTemplateKeys = {
  'id',
  'template_id',
  'id_template',
  'form_id',
  'stage_code',
  'completed_by',
  'generated_pdf_url',
  'generated_pdf_path',
  'pdf_url',
  'file_url',
  'url',
  'path',
  'id_document_instance',
  'document_instance_id',
  'created_at',
  'updated_at',
  'deleted_at',
  'config',
  'is_active',
};

String _templateLabel(String key) {
  const known = {
    'manager-name': 'اسم المدير',
    'manager_name': 'اسم المدير',
    'employee': 'الموظف',
    'job': 'الوظيفة',
    'department': 'الدائرة',
  };
  final normalized = key.trim().toLowerCase();
  return known[normalized] ??
      normalized
          .replaceAll('_', ' ')
          .replaceAll('-', ' ')
          .split(' ')
          .where((part) => part.isNotEmpty)
          .join(' ');
}

bool _isPdf(String url, String name, String type) {
  final combined = '$url $name $type'.toLowerCase().split('?').first;
  return combined.contains('application/pdf') || combined.contains('.pdf');
}

BoxDecoration _historyDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
