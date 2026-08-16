import 'dart:io';
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../../../shared/utils/app_file_url.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/internal_transaction_first_stage_entity.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_bloc.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_event.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_state.dart';

class InternalTransactionFirstStagePage extends StatelessWidget {
  final int transactionId;

  const InternalTransactionFirstStagePage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: AppColors.background,
          child: BlocBuilder<InternalTransactionFirstStageBloc,
              InternalTransactionFirstStageState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (state.errorMessage != null) {
                return AppErrorWidget(
                  title: 'تعذر تحميل تفاصيل المعاملة',
                  message: 'حدث خطأ أثناء جلب البيانات، حاول مرة أخرى',
                  onRetry: () => context
                      .read<InternalTransactionFirstStageBloc>()
                      .add(LoadInternalTransactionFirstStage(transactionId)),
                );
              }
              final details = state.details;
              if (details == null) return const _EmptyState();
              return _DetailsContent(details: details);
            },
          ),
        ),
      );
}

class _DetailsContent extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;

  const _DetailsContent({required this.details});

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    final stageName = _stageName(details);
    final textWidgets = content.widgets
        .where((item) => item.widgetType != 'file_picker')
        .where((item) => !_isEmptyValue(item.value))
        .toList(growable: false);
    final fileWidgets = content.widgets
        .where((item) => item.widgetType == 'file_picker')
        .toList(growable: false);
    final enteredFingerprints =
        textWidgets.map((item) => _fingerprint(item.label, item.value)).toSet();
    final templateValues = _additionalTemplateValues(
      content.templates,
      enteredFingerprints,
    );
    final generatedDocuments = content.templates
        .where((template) => template.generatedPdfPath.trim().isNotEmpty)
        .toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: context.pop,
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: const Text('العودة للمعاملات'),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                duration: const Duration(milliseconds: 300),
                child: _Header(
                  details: details,
                  stageName: stageName,
                ),
              ),
              const SizedBox(height: 18),
              FadeInUp(
                duration: const Duration(milliseconds: 280),
                delay: const Duration(milliseconds: 50),
                child: _StageSummary(
                  details: details,
                  fieldCount: content.widgets.length,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 280),
                delay: const Duration(milliseconds: 90),
                child: _DataSection(widgets: textWidgets),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 280),
                delay: const Duration(milliseconds: 130),
                child: _FilesSection(widgets: fileWidgets),
              ),
              if (templateValues.isNotEmpty) ...[
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 280),
                  delay: const Duration(milliseconds: 170),
                  child: _TemplateValuesSection(values: templateValues),
                ),
              ],
              if (generatedDocuments.isNotEmpty) ...[
                const SizedBox(height: 16),
                FadeInUp(
                  duration: const Duration(milliseconds: 280),
                  delay: const Duration(milliseconds: 210),
                  child: _GeneratedDocumentsSection(
                    templates: generatedDocuments,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;
  final String stageName;

  const _Header({required this.details, required this.stageName});

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    final decision = _decisionLabel(content.decision);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: .14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.fileSearch,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل المعاملة',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 29,
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyles.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stageName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              _Chip(
                icon: LucideIcons.hash,
                text: 'رقم المعاملة: ${details.transactionId}',
              ),
              _Chip(
                icon: LucideIcons.calendarDays,
                text: 'تاريخ التقديم: ${_formatDate(content.completedAt)}',
              ),
              _Chip(
                icon: LucideIcons.circleCheck,
                text: 'الحالة: $decision',
                emphasized: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StageSummary extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;
  final int fieldCount;

  const _StageSummary({required this.details, required this.fieldCount});

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 0,
            runSpacing: 12,
            children: [
              const _SummaryItem(
                icon: LucideIcons.circleCheck,
                label: 'الحالة',
                value: 'مكتملة',
              ),
              _SummaryItem(
                icon: LucideIcons.calendarCheck,
                label: 'تاريخ الإكمال',
                value: _formatDate(content.completedAt),
              ),
              _SummaryItem(
                icon: LucideIcons.listChecks,
                label: 'عدد الحقول',
                value: '$fieldCount',
              ),
            ],
          ),
          if (content.note.trim().isNotEmpty ||
              content.rejectionReason.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: AppColors.border.withValues(alpha: .35)),
            if (content.note.trim().isNotEmpty)
              _InlineMessage(
                label: 'ملاحظات',
                value: content.note.trim(),
              ),
            if (content.rejectionReason.trim().isNotEmpty)
              _InlineMessage(
                label: 'سبب الرفض',
                value: content.rejectionReason.trim(),
                color: AppColors.error,
              ),
          ],
        ],
      ),
    );
  }
}

class _DataSection extends StatelessWidget {
  final List<FirstStageWidgetEntity> widgets;

  const _DataSection({required this.widgets});

  @override
  Widget build(BuildContext context) => _Section(
        title: 'البيانات المدخلة',
        icon: LucideIcons.listChecks,
        child: widgets.isEmpty
            ? const _Placeholder('لا توجد بيانات مدخلة لهذه المرحلة')
            : LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 12.0;
                  final twoColumns = constraints.maxWidth >= 680;
                  final width = twoColumns
                      ? (constraints.maxWidth - gap) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: widgets
                        .map(
                          (item) => SizedBox(
                            width: width,
                            child: _ReadOnlyField(
                              label: _readableLabel(item.label),
                              value: _formatValue(item.value),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  );
                },
              ),
      );
}

class _FilesSection extends StatelessWidget {
  final List<FirstStageWidgetEntity> widgets;

  const _FilesSection({required this.widgets});

  @override
  Widget build(BuildContext context) {
    final files = <_DisplayFile>[];
    for (final widget in widgets) {
      final values = widget.value is List ? widget.value as List : const [];
      for (final raw in values.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final url = map['url']?.toString() ?? '';
        if (url.trim().isEmpty) continue;
        files.add(_DisplayFile(
          label: _readableLabel(widget.label),
          url: url,
          mimeType: map['mime_type']?.toString() ?? '',
        ));
      }
    }
    return _Section(
      title: 'الملفات المرفقة',
      icon: LucideIcons.paperclip,
      child: files.isEmpty
          ? const _Placeholder('لا توجد ملفات مرفقة')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: files
                  .map(
                    (file) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FileCard(file: file),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _TemplateValuesSection extends StatelessWidget {
  final List<MapEntry<String, dynamic>> values;

  const _TemplateValuesSection({required this.values});

  @override
  Widget build(BuildContext context) => _Section(
        title: 'بيانات النموذج الرسمي',
        icon: LucideIcons.fileCheck2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final twoColumns = constraints.maxWidth >= 680;
            final width = twoColumns
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: values
                  .map(
                    (entry) => SizedBox(
                      width: width,
                      child: _ReadOnlyField(
                        label: _templateLabel(entry.key),
                        value: _formatValue(entry.value),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      );
}

class _GeneratedDocumentsSection extends StatelessWidget {
  final List<FirstStageTemplateEntity> templates;

  const _GeneratedDocumentsSection({required this.templates});

  @override
  Widget build(BuildContext context) => _Section(
        title: 'النماذج المولدة',
        icon: LucideIcons.files,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: templates
              .map(
                (template) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _FileCard(
                    file: _DisplayFile(
                      label: 'النموذج الرسمي للمعاملة',
                      url: template.generatedPdfPath,
                      mimeType: 'application/pdf',
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      );
}

class _DisplayFile {
  final String label;
  final String url;
  final String mimeType;

  const _DisplayFile({
    required this.label,
    required this.url,
    required this.mimeType,
  });

  bool get isPdf =>
      mimeType.toLowerCase().contains('pdf') ||
      url.split('?').first.toLowerCase().endsWith('.pdf');
}

class _FileCard extends StatefulWidget {
  final _DisplayFile file;

  const _FileCard({required this.file});

  @override
  State<_FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<_FileCard> {
  bool _hovered = false;
  bool _externalHovered = false;
  bool _downloading = false;

  String get _absoluteUrl => buildAbsoluteFileUrl(widget.file.url);

  void _open() {
    if (_absoluteUrl.isEmpty) return;
    context.push(
      widget.file.isPdf ? '/pdf-viewer' : '/image-viewer',
      extra: {
        'fileUrl': _absoluteUrl,
        'title': widget.file.label,
        if (widget.file.isPdf) 'readOnly': true,
      },
    );
  }

  Future<void> _download() async {
    if (_downloading || _absoluteUrl.isEmpty) return;
    setState(() => _downloading = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.get<List<int>>(
        _absoluteUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes =
          response.data != null ? Uint8List.fromList(response.data!) : null;
      final contentType = response.headers.value('content-type');

      final savePath = await AppFileDownloader.getSavePath(
        documentType: widget.file.label,
        originalFilename: widget.file.label,
        contentType: contentType,
        bytes: bytes,
        fallbackExtension: widget.file.isPdf ? 'pdf' : null,
      );

      if (bytes != null && bytes.isNotEmpty) {
        final file = File(savePath);
        await file.writeAsBytes(bytes);
      } else {
        await dio.download(_absoluteUrl, savePath);
      }

      if (mounted) {
        AppSnackBar.show(context, message: 'تم تحميل الملف بنجاح');
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'تعذر تحميل الملف',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _openExternally() async {
    if (_absoluteUrl.isEmpty) return;
    final uri = Uri.tryParse(_absoluteUrl);
    if (uri == null) return;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Some desktop platforms do not expose externalApplication directly.
    }
    if (!opened) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      AppSnackBar.show(
        context,
        message: 'تعذر فتح الملف خارج التطبيق',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final identity = Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.file.isPdf ? LucideIcons.fileText : LucideIcons.image,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.file.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyles.semiBold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.file.isPdf ? 'PDF • ملف مرفق' : 'صورة • ملف مرفق',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _open,
                icon: const Icon(LucideIcons.eye, size: 16),
                label: const Text('عرض'),
              ),
              OutlinedButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.download, size: 16),
                label: const Text('تحميل'),
              ),
              Tooltip(
                message: 'فتح خارج التطبيق',
                child: MouseRegion(
                  onEnter: (_) => setState(() => _externalHovered = true),
                  onExit: (_) => setState(() => _externalHovered = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    decoration: BoxDecoration(
                      color: _externalHovered
                          ? AppColors.lightPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _externalHovered
                            ? AppColors.primary.withValues(alpha: .3)
                            : AppColors.border.withValues(alpha: .35),
                      ),
                    ),
                    child: IconButton(
                      onPressed: _openExternally,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: Icon(
                        Icons.launch_rounded,
                        size: 19,
                        color: _externalHovered
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
          return MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              constraints: const BoxConstraints(minHeight: 86),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _hovered
                    ? AppColors.lightPrimary.withValues(alpha: .22)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: _hovered
                      ? AppColors.primary.withValues(alpha: .28)
                      : AppColors.border.withValues(alpha: .35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(
                      alpha: _hovered ? .05 : .018,
                    ),
                    blurRadius: _hovered ? 12 : 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        identity,
                        const SizedBox(height: 10),
                        Align(alignment: Alignment.centerLeft, child: actions),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: identity),
                        const SizedBox(width: 16),
                        actions,
                      ],
                    ),
            ),
          );
        },
      );
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 21),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: .4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 245,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.medium,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.semiBold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 34,
              color: AppColors.border.withValues(alpha: .35),
            ),
            const SizedBox(width: 14),
          ],
        ),
      );
}

class _InlineMessage extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InlineMessage({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: AppTextStyles.medium,
                ),
              ),
              TextSpan(
                text: value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ReadOnlyField extends StatefulWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  State<_ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<_ReadOnlyField> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.lightPrimary.withValues(alpha: .28)
                : AppColors.background.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: .22)
                  : AppColors.border.withValues(alpha: .28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: AppTextStyles.medium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.semiBold,
                ),
              ),
            ],
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasized;

  const _Chip({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: emphasized ? AppColors.lightPrimary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: .4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight:
                    emphasized ? AppTextStyles.bold : AppTextStyles.medium,
              ),
            ),
          ],
        ),
      );
}

class _Placeholder extends StatelessWidget {
  final String text;

  const _Placeholder(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Center(
        child: Text('لا توجد تفاصيل لهذه المعاملة'),
      );
}

const _templateLabels = <String, String>{
  'manager-name': 'اسم المدير',
  'manager_name': 'اسم المدير',
  'employee': 'اسم الموظف',
  'employee-name': 'اسم الموظف',
  'job': 'الوظيفة',
  'department': 'القسم',
};

String _stageName(InternalTransactionFirstStageEntity details) {
  final contentName = details.content.stageName.trim();
  if (contentName.isNotEmpty) return contentName;
  final stageName = details.stageName.trim();
  return stageName.isEmpty ? 'المرحلة الأولى' : stageName;
}

String _decisionLabel(String decision) {
  switch (decision.trim().toLowerCase()) {
    case 'submit':
      return 'تم تقديم الطلب';
    case 'approve':
      return 'تمت الموافقة';
    case 'reject':
      return 'تم الرفض';
    case 'return':
      return 'أعيدت للتعديل';
    default:
      return 'تم تنفيذ المرحلة';
  }
}

String _formatDate(String raw) {
  final parsed = DateTime.tryParse(raw)?.toLocal();
  if (parsed == null) return 'غير متوفر';
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _templateLabel(String key) =>
    _templateLabels[key.trim().toLowerCase()] ?? _readableLabel(key);

String _readableLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'بيان';
  final spaced = trimmed
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (spaced.isEmpty) return 'بيان';
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

List<MapEntry<String, dynamic>> _additionalTemplateValues(
  List<FirstStageTemplateEntity> templates,
  Set<String> enteredFingerprints,
) {
  final result = <MapEntry<String, dynamic>>[];
  final seen = <String>{...enteredFingerprints};
  for (final template in templates) {
    for (final entry in template.value.entries) {
      if (_isEmptyValue(entry.value)) continue;
      final label = _templateLabel(entry.key);
      final fingerprint = _fingerprint(label, entry.value);
      if (seen.add(fingerprint)) result.add(entry);
    }
  }
  return result;
}

String _fingerprint(String label, dynamic value) =>
    '${_normalize(label)}|${_normalize(_formatValue(value))}';

String _normalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[\s_-]+'), ' ')
    .replaceAll(RegExp(r'[^\w\u0600-\u06ff ]'), '');

bool _isEmptyValue(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

String _formatValue(dynamic value) {
  if (value == null) return 'غير متوفر';
  if (value is bool) return value ? 'نعم' : 'لا';
  if (value is List) return value.map(_formatValue).join('، ');
  if (value is Map) {
    return value.values.map(_formatValue).join('، ');
  }
  final text = value.toString().trim();
  return text.isEmpty ? 'غير متوفر' : text;
}

String _fileExtension(String url) {
  final path = Uri.tryParse(url)?.path ?? '';
  final dot = path.lastIndexOf('.');
  return dot < 0 ? '' : path.substring(dot);
}
