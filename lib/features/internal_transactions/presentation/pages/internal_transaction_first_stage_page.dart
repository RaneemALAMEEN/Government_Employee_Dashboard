import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/internal_transaction_first_stage_entity.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_bloc.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_event.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_state.dart';
import '../../../my_transactions/presentation/pages/image_viewer_page.dart';
import '../../../my_transactions/presentation/pages/pdf_viewer_page.dart';

class InternalTransactionFirstStagePage extends StatelessWidget {
  final int transactionId;

  const InternalTransactionFirstStagePage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<InternalTransactionFirstStageBloc,
          InternalTransactionFirstStageState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            );
          }

          if (state.errorMessage != null) {
            return _ErrorState(
              message: state.errorMessage!,
              onRetry: () {
                context.read<InternalTransactionFirstStageBloc>().add(
                      LoadInternalTransactionFirstStage(transactionId),
                    );
              },
            );
          }

          final details = state.details;
          if (details == null) {
            return const _EmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/internal-transactions'),
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text('العودة للمعاملات'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      side: BorderSide(
                        color: AppColors.gold.withValues(alpha: 0.35),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  duration: const Duration(milliseconds: 350),
                  child: _Header(details: details),
                ),
                const SizedBox(height: 22),
                FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  delay: const Duration(milliseconds: 80),
                  child: _Overview(details: details),
                ),
                const SizedBox(height: 18),
                FadeInUp(
                  duration: const Duration(milliseconds: 350),
                  delay: const Duration(milliseconds: 130),
                  child: _WidgetsPanel(widgets: details.content.widgets),
                ),
                if (details.content.templates.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    delay: const Duration(milliseconds: 180),
                    child: _TemplatesPanel(
                      templates: details.content.templates,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;

  const _Header({required this.details});

  @override
  Widget build(BuildContext context) {
    final content = details.content;

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            LucideIcons.fileSearch,
            color: AppColors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل المعاملة الداخلية',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.forest,
                  fontWeight: AppTextStyles.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content.formName.isNotEmpty
                    ? content.formName
                    : details.stageName,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.goldDark,
                ),
              ),
            ],
          ),
        ),
        _TransactionPill(text: '#${details.transactionId}'),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;

  const _Overview({required this.details});

  @override
  Widget build(BuildContext context) {
    final content = details.content;

    return _Panel(
      title: 'بيانات المرحلة الأولى',
      icon: LucideIcons.badgeInfo,
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: [
          _InfoTile(label: 'اسم المرحلة', value: details.stageName),
          _InfoTile(label: 'نوع التحقق', value: details.authType),
          _InfoTile(label: 'معرف المرحلة', value: details.stageCode),
          _InfoTile(label: 'تاريخ الإكمال', value: content.completedAt),
          _InfoTile(
            label: 'أنجزها',
            value: content.completedBy?.toString() ??
                details.completedBy?.toString() ??
                '-',
          ),
          if (content.note.isNotEmpty)
            _InfoTile(label: 'ملاحظة', value: content.note),
          if (content.rejectionReason.isNotEmpty)
            _InfoTile(
              label: 'سبب الرفض',
              value: content.rejectionReason,
              color: AppColors.umber,
            ),
        ],
      ),
    );
  }
}

class _WidgetsPanel extends StatelessWidget {
  final List<FirstStageWidgetEntity> widgets;

  const _WidgetsPanel({required this.widgets});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'محتوى الطلب',
      icon: LucideIcons.listChecks,
      child: widgets.isEmpty
          ? const _PlaceholderText('لا توجد حقول محفوظة لهذه المرحلة')
          : Column(
              children: widgets
                  .map((widget) => _ReadOnlyWidgetTile(widget: widget))
                  .toList(),
            ),
    );
  }
}

class _TemplatesPanel extends StatelessWidget {
  final List<FirstStageTemplateEntity> templates;

  const _TemplatesPanel({required this.templates});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'النماذج المولدة',
      icon: LucideIcons.fileText,
      child: Column(
        children: templates
            .map((template) => _TemplateTile(template: template))
            .toList(),
      ),
    );
  }
}

class _ReadOnlyWidgetTile extends StatelessWidget {
  final FirstStageWidgetEntity widget;

  const _ReadOnlyWidgetTile({required this.widget});

  @override
  Widget build(BuildContext context) {
    if (widget.widgetType == 'file_picker') {
      final files = widget.value is List ? widget.value as List : const [];

      return _FieldShell(
        label: widget.label,
        child: files.isEmpty
            ? const _PlaceholderText('لا توجد مرفقات')
            : Column(
                children: files
                    .whereType<Map>()
                    .map(
                      (file) => _FileTile(
                        name: file['original_name']?.toString() ?? '',
                        mimeType: file['mime_type']?.toString() ?? '',
                        url: file['url']?.toString() ?? '',
                        path: file['path']?.toString() ?? '',
                      ),
                    )
                    .toList(),
              ),
      );
    }

    return _FieldShell(
      label: widget.label,
      child: Text(
        _formatValue(widget.value),
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.charcoalDark,
          fontWeight: AppTextStyles.medium,
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final FirstStageTemplateEntity template;

  const _TemplateTile({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _subtleDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.fileCheck2,
                color: AppColors.forest,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نموذج ${template.templateId ?? '-'}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.forest,
                  ),
                ),
              ),
              if (template.documentInstanceId != null)
                _TransactionPill(
                  text: 'نسخة ${template.documentInstanceId}',
                ),
            ],
          ),
          if (template.generatedPdfPath.isNotEmpty) ...[
            const SizedBox(height: 10),
            _FileTile(
              name: '',
              mimeType: 'application/pdf',
              path: template.generatedPdfPath,
              url: '',
            ),
          ],
          if (template.value.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: template.value.entries
                  .map(
                    (entry) => _InfoTile(
                      label: entry.key,
                      value: _formatValue(entry.value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Panel({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.forest, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.forest,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldShell({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _subtleDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.goldDark,
              fontWeight: AppTextStyles.bold,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _InfoTile({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _subtleDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.goldDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value.isEmpty ? '-' : value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color ?? AppColors.charcoalDark,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final String name;
  final String mimeType;
  final String url;
  final String path;

  const _FileTile({
    required this.name,
    required this.mimeType,
    required this.url,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    final fileUrl = _buildFileUrl(url.isNotEmpty ? url : path);
    final text = _fileDisplayName(name: name, path: path, url: url);
    final isPdf = _isPdfFile(name: text, mimeType: mimeType, url: fileUrl);
    final isImage = _isImageFile(name: text, mimeType: mimeType, url: fileUrl);
    final canOpen = fileUrl.isNotEmpty && (isPdf || isImage);

    return InkWell(
      onTap: canOpen
          ? () async {
              if (isPdf) {
                if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
                  final opened = await launchUrl(
                    Uri.parse(fileUrl),
                    mode: LaunchMode.externalApplication,
                    webOnlyWindowName: '_blank',
                  );
                  if (!opened && context.mounted) {
                    AppSnackBar.show(
                      context,
                      message: 'تعذر فتح ملف PDF',
                      isError: true,
                    );
                  }
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfViewerPage(
                      fileUrl: fileUrl,
                      title: text,
                    ),
                  ),
                );
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ImageViewerPage(
                    fileUrl: fileUrl,
                    title: text,
                  ),
                ),
              );
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(
              isPdf ? LucideIcons.fileText : LucideIcons.paperclip,
              color: AppColors.forest,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text.isEmpty ? 'ملف مرفق' : text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.charcoalDark,
                  fontWeight: AppTextStyles.medium,
                ),
              ),
            ),
            if (canOpen) ...[
              const SizedBox(width: 8),
              const Icon(
                LucideIcons.eye,
                color: AppColors.goldDark,
                size: 17,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _fileDisplayName({
  required String name,
  required String path,
  required String url,
}) {
  if (name.trim().isNotEmpty) return name.trim();

  final source = path.trim().isNotEmpty ? path.trim() : url.trim();
  if (source.isEmpty) return '';

  final normalized = source.split('?').first;
  final parts = normalized.split('/');

  return parts.lastWhere(
    (part) => part.trim().isNotEmpty,
    orElse: () => normalized,
  );
}

String _buildFileUrl(String pathOrUrl) {
  final trimmed = pathOrUrl.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http')) return trimmed;
  if (trimmed.startsWith('/')) {
    return 'https://dev-education-directorate.abukm.com$trimmed';
  }
  return 'https://dev-education-directorate.abukm.com/$trimmed';
}

bool _isPdfFile({
  required String name,
  required String mimeType,
  required String url,
}) {
  final lowerName = name.toLowerCase();
  final lowerMime = mimeType.toLowerCase();
  final lowerUrl = url.toLowerCase();

  return lowerMime.contains('pdf') ||
      lowerName.endsWith('.pdf') ||
      lowerUrl.endsWith('.pdf');
}

bool _isImageFile({
  required String name,
  required String mimeType,
  required String url,
}) {
  final lowerName = name.toLowerCase();
  final lowerMime = mimeType.toLowerCase();
  final lowerUrl = url.toLowerCase();
  const imageExtensions = ['.png', '.jpg', '.jpeg', '.webp'];

  return lowerMime.startsWith('image/') ||
      imageExtensions.any(
        (extension) =>
            lowerName.endsWith(extension) || lowerUrl.endsWith(extension),
      );
}

class _TransactionPill extends StatelessWidget {
  final String text;

  const _TransactionPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.forestLight.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.forest,
          fontWeight: AppTextStyles.bold,
        ),
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  final String text;

  const _PlaceholderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(color: AppColors.goldDark),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لا توجد تفاصيل لهذه المعاملة'));
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.umber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.umber.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.umber,
                fontWeight: AppTextStyles.semiBold,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
    boxShadow: [
      BoxShadow(
        color: AppColors.charcoal.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

BoxDecoration _subtleDecoration() {
  return BoxDecoration(
    color: AppColors.goldLight.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.gold.withValues(alpha: 0.16)),
  );
}

String _formatValue(dynamic value) {
  if (value == null) return '-';
  if (value is List) {
    return value.map(_formatValue).join('، ');
  }
  if (value is Map) {
    return value.entries
        .map((entry) => '${entry.key}: ${_formatValue(entry.value)}')
        .join('، ');
  }
  final text = value.toString();
  return text.isEmpty ? '-' : text;
}
