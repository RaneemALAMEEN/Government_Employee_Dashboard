import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/document_template_entity.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import '../bloc/internal_transaction_form/internal_transaction_form_bloc.dart';
import '../bloc/internal_transaction_form/internal_transaction_form_event.dart';
import '../bloc/internal_transaction_form/internal_transaction_form_state.dart';
import '../widgets/dynamic_form_widget_renderer.dart';
import '../widgets/pin_dialog.dart';
import '../widgets/transaction_success_summary.dart';

class InternalTransactionFormPage extends StatefulWidget {
  final int processId;

  const InternalTransactionFormPage({
    super.key,
    required this.processId,
  });

  @override
  State<InternalTransactionFormPage> createState() =>
      _InternalTransactionFormPageState();
}

class _InternalTransactionFormPageState
    extends State<InternalTransactionFormPage> {
  Future<String?> _pickKeysDirectory() {
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: 'اختاري مجلد مفاتيح الموظف من الفلاشة',
    );
  }

  Future<String?> _showPinDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PinDialog(),
    );
  }

  Future<void> _submit() async {
    final keysDirectoryPath = await _pickKeysDirectory();
    if (keysDirectoryPath == null) return;

    final pin = await _showPinDialog();
    if (pin == null || pin.isEmpty) return;

    if (!mounted) return;

    context.read<InternalTransactionFormBloc>().add(
          SubmitInternalTransactionForm(
            processId: widget.processId,
            keysDirectoryPath: keysDirectoryPath,
            pin: pin,
          ),
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InternalTransactionFormBloc,
        InternalTransactionFormState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        _showSnackBar(state.errorMessage!);
      },
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.forest),
          );
        }

        if (state.errorMessage != null && state.form == null) {
          return Center(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: AppColors.umber),
            ),
          );
        }

        if (state.submittedTransaction != null) {
          return TransactionSuccessSummary(
            submittedTransaction: state.submittedTransaction!,
            onBack: () {
              context.read<InternalTransactionFormBloc>().add(
                    const ResetInternalTransactionForm(),
                  );
            },
          );
        }

        final form = state.form;

        if (form == null) {
          return const Center(
            child: Text(
              'تعذر تحميل النموذج',
              style: TextStyle(color: AppColors.umber),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FormHeader(
                  form: form,
                  hasTemplate: state.template != null,
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'بيانات المرحلة',
                  subtitle: 'يرجى تعبئة الحقول المطلوبة لإكمال هذه المرحلة',
                  icon: Icons.dynamic_form_outlined,
                  child: _FormFields(
                    form: form,
                    values: state.formValues,
                    emptyMessage: 'لا توجد حقول مباشرة في هذه المرحلة.',
                    onChanged: (id, value) {
                      context.read<InternalTransactionFormBloc>().add(
                            UpdateInternalTransactionFormValue(
                              id: id,
                              value: value,
                            ),
                          );
                    },
                  ),
                ),
                if (state.template != null) ...[
                  const SizedBox(height: 22),
                  _TemplateSection(
                    template: state.template!,
                    values: state.templateValues,
                    onChanged: (id, value) {
                      context.read<InternalTransactionFormBloc>().add(
                            UpdateInternalTransactionTemplateValue(
                              id: id,
                              value: value,
                            ),
                          );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _SubmitButton(
                    submitting: state.submitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FormHeader extends StatelessWidget {
  final DynamicFormEntity form;
  final bool hasTemplate;

  const _FormHeader({
    required this.form,
    required this.hasTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final widgetsCount = form.widgets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          form.formName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.forest,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeaderBadge(
              icon: Icons.view_list_outlined,
              text: 'عدد حقول المرحلة: $widgetsCount',
            ),
            if (hasTemplate)
              const _HeaderBadge(
                icon: Icons.picture_as_pdf_outlined,
                text: 'يوجد قالب مرتبط بهذه المرحلة',
              ),
          ],
        ),
      ],
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.goldDark),
          const SizedBox(width: 7),
          Text(
            text,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.goldDark,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateSection extends StatelessWidget {
  final DocumentTemplateEntity template;
  final Map<String, dynamic> values;
  final void Function(String id, dynamic value) onChanged;

  const _TemplateSection({
    required this.template,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'القالب المرتبط',
      subtitle: 'املئي الحقول الخاصة بالقالب ليتم إرسالها ضمن المعاملة',
      icon: Icons.picture_as_pdf_outlined,
      trailing: _TemplateBadge(text: template.engineType),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TemplateInfo(template: template),
          const SizedBox(height: 18),
          _FormFields(
            form: template.config,
            values: values,
            emptyMessage: 'لا توجد حقول مطلوبة ضمن هذا القالب.',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TemplateInfo extends StatelessWidget {
  final DocumentTemplateEntity template;

  const _TemplateInfo({required this.template});

  String get _pdfUrl {
    final path = template.filePath.trim();

    if (path.isEmpty) return '';

    if (path.startsWith('http')) return path;

    if (path.startsWith('/')) {
      return 'https://dev-education-directorate.abukm.com$path';
    }

    return 'https://dev-education-directorate.abukm.com/$path';
  }

  void _openPdf(BuildContext context) {
    if (template.filePath.isEmpty) return;

    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 900,
              height: 720,
              child: Column(
                children: [
                  Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf_outlined,
                          color: AppColors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            template.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: AppTextStyles.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (Navigator.of(context, rootNavigator: true)
                                .canPop()) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _pdfUrl.isEmpty
                        ? const Center(
                            child: Text('لا يوجد ملف لعرضه'),
                          )
                        : SfPdfViewer.network(
                            _pdfUrl,
                            canShowScrollHead: true,
                            canShowScrollStatus: true,
                            onDocumentLoadFailed: (details) {
                              debugPrint('PDF ERROR: ${details.description}');
                              debugPrint('PDF DETAILS: ${details.error}');

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'فشل تحميل القالب: ${details.description}',
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.forestLight.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.forest.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.forest.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.forest,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoalDark,
                    fontWeight: AppTextStyles.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.filePath.isEmpty
                      ? 'لا يوجد ملف مرفق'
                      : template.filePath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.goldDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed:
                template.filePath.isEmpty ? null : () => _openPdf(context),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('عرض القالب'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.forest,
              side: BorderSide(color: AppColors.forest.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.forest, size: 18),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoalDark,
            fontWeight: AppTextStyles.bold,
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.charcoal,
            ),
          ),
        ),
      ],
    );
  }
}

class _TemplateBadge extends StatelessWidget {
  final String text;

  const _TemplateBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.goldDark,
          fontWeight: AppTextStyles.bold,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.forestLight.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.forest, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.forest,
                        fontWeight: AppTextStyles.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FormFields extends StatelessWidget {
  final DynamicFormEntity form;
  final Map<String, dynamic> values;
  final String emptyMessage;
  final void Function(String id, dynamic value) onChanged;

  const _FormFields({
    required this.form,
    required this.values,
    required this.emptyMessage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (form.widgets.isEmpty) {
      return Container(
        height: 76,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.goldLight.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emptyMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.goldDark,
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: form.widgets.map((widgetConfig) {
        final id = widgetConfig.data['id']?.toString() ?? '';

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: DynamicFormWidgetRenderer(
            widgetEntity: widgetConfig,
            value: values[id],
            onChanged: (value) => onChanged(id, value),
          ),
        );
      }).toList(),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool submitting;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.submitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: submitting ? null : onPressed,
        icon: submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.verified_user_outlined, size: 18),
        label: Text(
          submitting ? 'جارٍ التوقيع والتقديم...' : 'توقيع وتقديم المعاملة',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
