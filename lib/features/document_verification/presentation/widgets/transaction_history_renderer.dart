import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
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
      padding: const EdgeInsets.all(18),
      decoration: _historyDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.history,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سجل مراحل المعاملة',
                      style: AppTextStyles.titleMedium,
                    ),
                    if (widget.history.processName.isNotEmpty)
                      Text(
                        widget.history.processName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
  final bool expanded;
  final bool isLast;
  final VoidCallback onToggle;

  const _TimelineStage({
    required this.index,
    required this.stage,
    required this.expanded,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = stage.widgets;
    final valuedCount = widgets.where(_hasActualValue).length;
    return Stack(
      children: [
        if (!isLast)
          PositionedDirectional(
            start: 13.5,
            top: 28,
            bottom: 0,
            child: Container(
              width: 1,
              color: AppColors.border.withValues(alpha: .45),
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 38,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.surface,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: expanded
                        ? AppColors.primary.withValues(alpha: .32)
                        : AppColors.border.withValues(alpha: .28),
                  ),
                ),
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggle,
                        borderRadius: BorderRadius.circular(13),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(
                                stage.isDocumentGeneration
                                    ? LucideIcons.fileCog
                                    : LucideIcons.clipboardCheck,
                                size: 19,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stage.displayName,
                                      style: AppTextStyles.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 5,
                                      children: [
                                        if (stage.decision?.isNotEmpty == true)
                                          _MetaChip(
                                            text: decisionText(stage.decision!),
                                          ),
                                        if (stage.completedAt != null)
                                          _MetaChip(
                                            text: formatHistoryDate(
                                              stage.completedAt,
                                            ),
                                            icon: LucideIcons.calendarDays,
                                          ),
                                        if (valuedCount > 0)
                                          _MetaChip(
                                            text:
                                                '$valuedCount ${valuedCount == 1 ? 'حقل' : 'حقول'}',
                                            icon: LucideIcons.listChecks,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedRotation(
                                turns: expanded ? .5 : 0,
                                duration: const Duration(milliseconds: 180),
                                child: const Icon(
                                  LucideIcons.chevronDown,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox(width: double.infinity),
                      secondChild: _StageDetails(
                        stage: stage,
                        widgets: widgets,
                      ),
                      crossFadeState: expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                      sizeCurve: Curves.easeOutCubic,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StageDetails extends StatelessWidget {
  final TransactionHistoryStageEntity stage;
  final List<TransactionHistoryWidgetEntity> widgets;

  const _StageDetails({required this.stage, required this.widgets});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: AppColors.border.withValues(alpha: .25)),
            if (stage.note?.isNotEmpty == true)
              _MessageBox(label: 'ملاحظة', value: stage.note!),
            if (stage.rejectionReason?.isNotEmpty == true)
              _MessageBox(
                label: 'سبب الرفض',
                value: stage.rejectionReason!,
                warning: true,
              ),
            if (stage.isDocumentGeneration)
              _GeneratedDocumentStage(stage: stage)
            else if (widgets.isEmpty && stage.templates.isEmpty)
              Text(
                'لا توجد قيم مدخلة ضمن هذه المرحلة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
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
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
            if (!stage.isDocumentGeneration && stage.templates.isNotEmpty) ...[
              if (widgets.isNotEmpty) const SizedBox(height: 10),
              _TemplateValues(
                templates: stage.templates,
                excludedValues: widgets.map((item) => item.value).toList(),
              ),
            ],
          ],
        ),
      );
}

class _TemplateValues extends StatelessWidget {
  final List<TransactionHistoryTemplateEntity> templates;
  final List<dynamic> excludedValues;

  const _TemplateValues({
    required this.templates,
    required this.excludedValues,
  });

  @override
  Widget build(BuildContext context) {
    final excluded = excludedValues.map((value) => value?.toString()).toSet();
    final entries = <MapEntry<String, String>>[];
    for (final template in templates) {
      for (final entry in template.values.entries) {
        if (_technicalTemplateKeys.contains(entry.key.toLowerCase())) continue;
        final value = entry.value;
        if (value is! String && value is! num && value is! bool) continue;
        final readable =
            value is bool ? (value ? 'نعم' : 'لا') : value.toString();
        if (readable.trim().isEmpty || excluded.contains(value.toString())) {
          continue;
        }
        entries.add(MapEntry(_templateLabel(entry.key), readable));
      }
    }
    if (entries.isEmpty) return const SizedBox.shrink();
    return _ValueShell(
      label: 'بيانات القالب',
      icon: LucideIcons.layoutTemplate,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: entries
            .map(
              (entry) => _ValueChip(text: '${entry.key}: ${entry.value}'),
            )
            .toList(growable: false),
      ),
    );
  }
}

class TransactionHistoryValueRenderer extends StatelessWidget {
  final TransactionHistoryWidgetEntity widget;

  const TransactionHistoryValueRenderer({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    final type = widget.widgetType.toLowerCase();
    if (type == 'file_picker') return _FileValueCard(widget: widget);
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
        child: SelectableText(displayValue, style: AppTextStyles.bodyMedium),
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

  const _FileValueCard({required this.widget});

  @override
  Widget build(BuildContext context) {
    final rawFiles =
        widget.value is List ? widget.value as List : [widget.value];
    final files = rawFiles.whereType<Map>().map((value) {
      final map = Map<String, dynamic>.from(value);
      final typeDoc = map['type_doc'] is Map
          ? Map<String, dynamic>.from(map['type_doc'] as Map)
          : <String, dynamic>{};
      return (
        url: _firstReadable([map['url'], map['file_url']]),
        name: _firstReadable([map['original_name'], map['name']]),
        type: _firstReadable([typeDoc['name'], map['mime_type'], map['type']]),
      );
    }).toList(growable: false);
    return _ValueShell(
      label: _label(widget),
      icon: LucideIcons.paperclip,
      child: files.isEmpty
          ? const Text('لم يتم إرفاق ملف')
          : Column(
              children: files
                  .map(
                    (file) => _FileTile(
                      url: file.url,
                      name: file.name.isEmpty
                          ? 'عرض ${_label(widget)}'
                          : file.name,
                      type: file.type,
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _FileTile extends StatefulWidget {
  final String url;
  final String name;
  final String type;

  const _FileTile({required this.url, required this.name, required this.type});

  @override
  State<_FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<_FileTile> {
  bool _hovered = false;

  Future<void> _open() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null ||
        !uri.hasScheme ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        AppSnackBar.show(context, message: 'تعذر فتح الملف', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.url.isEmpty
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(top: 7),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.lightPrimary : AppColors.background,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border.withValues(alpha: .3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.file, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name, style: AppTextStyles.bodyMedium),
                    if (widget.type.isNotEmpty)
                      Text(
                        widget.type,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.url.isEmpty ? null : _open,
                child: const Text('عرض الملف'),
              ),
            ],
          ),
        ),
      );
}

class _GeneratedDocumentStage extends StatelessWidget {
  final TransactionHistoryStageEntity stage;

  const _GeneratedDocumentStage({required this.stage});

  @override
  Widget build(BuildContext context) {
    final url = stage.generatedPdfUrl ?? stage.generatedDocument?.url ?? '';
    return _ValueShell(
      label: 'توليد الوثيقة',
      icon: LucideIcons.fileCog,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            url.isEmpty
                ? 'لم يتم إنشاء ملف قابل للعرض في هذه المرحلة'
                : 'تم إنشاء ملف PDF خلال هذه المرحلة',
          ),
          if (url.isNotEmpty) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _openUrl(context, url),
              icon: const Icon(LucideIcons.externalLink, size: 16),
              label: const Text('عرض الملف المولّد'),
            ),
          ],
          const SizedBox(height: 7),
          Text(
            'هذا ملف ناتج عن مرحلة آلية، وليس بالضرورة الوثيقة النهائية المعتمدة.',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
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

  const _ValueShell(
      {required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: .28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            child,
          ],
        ),
      );
}

class _MessageBox extends StatelessWidget {
  final String label;
  final String value;
  final bool warning;

  const _MessageBox(
      {required this.label, required this.value, this.warning = false});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: warning
              ? AppColors.error.withValues(alpha: .07)
              : AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: warning ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 3),
            Text(value),
          ],
        ),
      );
}

class _MetaChip extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _MetaChip({required this.text, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
            ],
            Text(text, style: AppTextStyles.labelSmall),
          ],
        ),
      );
}

class _ValueChip extends StatelessWidget {
  final String text;

  const _ValueChip({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: .25)),
        ),
        child: Text(text, style: AppTextStyles.bodySmall),
      );
}

class _HistoryEmptyState extends StatelessWidget {
  final String message;

  const _HistoryEmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
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

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      !uri.hasScheme ||
      !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) {
      AppSnackBar.show(context, message: 'تعذر فتح الملف', isError: true);
    }
  }
}

BoxDecoration _historyDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: AppColors.border.withValues(alpha: .34)),
      boxShadow: [
        BoxShadow(
          color: AppColors.textPrimary.withValues(alpha: .04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
