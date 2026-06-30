import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
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
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null;
      },
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
                _FormHeader(form: form),
                const SizedBox(height: 24),
                _FormCard(
                  form: form,
                  formValues: state.formValues,
                  onChanged: (id, value) {
                    context.read<InternalTransactionFormBloc>().add(
                          UpdateInternalTransactionFormValue(
                            id: id,
                            value: value,
                          ),
                        );
                  },
                ),
                const SizedBox(height: 20),
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

  const _FormHeader({required this.form});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 8),
        Text(
          'عدد الحقول: ${form.widgets.length}',
          style: const TextStyle(
            color: AppColors.goldDark,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final DynamicFormEntity form;
  final Map<String, dynamic> formValues;
  final void Function(String id, dynamic value) onChanged;

  const _FormCard({
    required this.form,
    required this.formValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: form.widgets.map((widgetConfig) {
          final id = widgetConfig.data['id']?.toString() ?? '';

          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: DynamicFormWidgetRenderer(
              widgetEntity: widgetConfig,
              value: formValues[id],
              onChanged: (value) => onChanged(id, value),
            ),
          );
        }).toList(),
      ),
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
      height: 44,
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
          padding: const EdgeInsets.symmetric(horizontal: 22),
        ),
      ),
    );
  }
}
