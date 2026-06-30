import '../../../../shared/theme/app_text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/services/api_service.dart';

import '../../../../core/services/usb_signing_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_remote_data_source.dart';
import '../../domain/entities/dynamic_form_entity.dart';
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
  final _dataSource = InternalTransactionsRemoteDataSource(
    getIt<ApiService>(),
  );
  final _usbSigningService = UsbSigningService();

  final Map<String, dynamic> _formValues = {};

  bool _loading = true;
  bool _submitting = false;

  String? _errorMessage;
  DynamicFormEntity? _form;
  Map<String, dynamic>? _submittedTransaction;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final form = await _dataSource.getStageConfig(
        processId: widget.processId,
      );

      if (!mounted) return;

      setState(() {
        _form = form;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = _cleanError(e);
      });
    }
  }

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

  String? _validateForm(DynamicFormEntity form) {
    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final label = widget.data['label']?.toString() ?? 'هذا الحقل';
      final isRequired = widget.data['is_required'] == true;
      final value = _formValues[id];

      if (isRequired && _isEmptyValue(value)) {
        return 'يرجى تعبئة حقل: $label';
      }

      if (value == null) continue;

      if (widget.widgetType == 'text_field' && value is String) {
        final error = _validateTextField(
          label: label,
          value: value,
          data: widget.data,
        );

        if (error != null) return error;
      }

      if (widget.widgetType == 'check_list' && value is List) {
        final error = _validateCheckList(
          label: label,
          value: value,
          data: widget.data,
        );

        if (error != null) return error;
      }
    }

    return null;
  }

  String? _validateTextField({
    required String label,
    required String value,
    required Map<String, dynamic> data,
  }) {
    final trimmedValue = value.trim();

    final minLength = data['min_length'] as int?;
    final maxLength = data['max_length'] as int?;
    final inputType = data['input_type']?.toString();
    final regex = data['regex']?.toString();

    if (minLength != null && trimmedValue.length < minLength) {
      return 'حقل $label يجب أن يحتوي على $minLength أحرف على الأقل';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return 'حقل $label يجب ألا يتجاوز $maxLength حرف';
    }

    if (regex != null && regex.isNotEmpty) {
      final regExp = RegExp(regex);

      if (!regExp.hasMatch(trimmedValue)) {
        return 'قيمة حقل $label غير صحيحة';
      }
    }

    if (inputType == 'int' || inputType == 'number') {
      if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
        return 'حقل $label يجب أن يحتوي على أرقام فقط';
      }
    }

    if (inputType == 'phone' || inputType == 'phoneNumber') {
      if (!RegExp(r'^09\d{8}$').hasMatch(trimmedValue)) {
        return 'رقم الهاتف يجب أن يبدأ بـ 09 ويتكون من 10 أرقام';
      }
    }

    return null;
  }

  String? _validateCheckList({
    required String label,
    required List value,
    required Map<String, dynamic> data,
  }) {
    final minSelected = data['min_selected'] as int?;
    final maxSelected = data['max_selected'] as int?;

    if (minSelected != null && value.length < minSelected) {
      return 'يجب اختيار $minSelected خيار على الأقل في حقل $label';
    }

    if (maxSelected != null && value.length > maxSelected) {
      return 'لا يمكن اختيار أكثر من $maxSelected خيار في حقل $label';
    }

    return null;
  }

  bool _isEmptyValue(dynamic value) {
    return value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty);
  }

  Future<Map<String, dynamic>> _buildSubmitPayload(
    DynamicFormEntity form,
  ) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final value = _formValues[id];

      final finalValue = widget.widgetType == 'file_picker'
          ? await _uploadFilePickerValue(
              widgetId: id,
              widgetData: widget.data,
              value: value,
              )
          : value;

      widgetsPayload.add({
        'widget_type': widget.widgetType,
        'data': widget.data,
        'value': finalValue,
      });
    }

    return {
      'form_id': form.formId,
      'form_name': form.formName,
      'widgets': widgetsPayload,
      'templates': [],
      'note': '',
    };
  }

  Future<List<Map<String, dynamic>>> _uploadFilePickerValue({
    required String widgetId,
    required Map<String, dynamic> widgetData,
    required dynamic value,
  }) async {
    if (value is! List || value.isEmpty) return [];

    final uploadedFiles = <Map<String, dynamic>>[];
    final typeDocId = _parseTypeDocId(widgetData['type_doc_id']);

    for (final file in value) {
      final filePath = file.path?.toString();

      if (filePath == null || filePath.isEmpty) continue;

      final uploaded = await _dataSource.uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId,
        key: widgetId,
      );

      uploadedFiles.add(uploaded);
    }

    return uploadedFiles;
  }

<<<<<<< HEAD
  int _parseTypeDocId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 1;
=======
  void _setProgrammaticDecisionValue(List<dynamic> widgets, bool isApprove) {
    for (final widget in widgets) {
      final wData = widget.data;
      if (wData['is_gateway'] == true || wData['id'] == 'decision') {
        final id = wData['id']?.toString() ?? 'decision';
        final options = wData['options'] as List? ?? [];
        if (options.isNotEmpty) {
          String? selectedValue;
          for (final opt in options) {
            final val = (opt['value'] ?? opt['key'] ?? '').toString();
            if (isApprove) {
              if (val.contains('مقبول') || val.contains('موافق') || val.contains('نعم') || val.toLowerCase().contains('approve') || val.toLowerCase().contains('yes')) {
                selectedValue = val;
                break;
              }
            } else {
              if (val.contains('مرفوض') || val.contains('رفض') || val.contains('لا') || val.toLowerCase().contains('reject') || val.toLowerCase().contains('no')) {
                selectedValue = val;
                break;
              }
            }
          }
          if (selectedValue == null && options.isNotEmpty) {
            if (isApprove) {
              selectedValue = (options.last['value'] ?? options.last['key'] ?? '').toString();
            } else {
              selectedValue = (options.first['value'] ?? options.first['key'] ?? '').toString();
            }
          }
          if (selectedValue != null) {
            _formValues[id] = selectedValue;
            print('Programmatically set form value for $id to "$selectedValue"');
          }
        } else {
          _formValues[id] = isApprove ? 'الطلب مقبول' : 'الطلب مرفوض';
        }
      }
    }
  }

  String _determineDecision(DynamicFormEntity form,
      {required String defaultDecision}) {
    for (final widget in form.widgets) {
      final wData = widget.data;
      if (wData['is_gateway'] == true || wData['id'] == 'decision') {
        final id = wData['id']?.toString() ?? '';
        final val = _formValues[id];
        if (val != null && val.toString().isNotEmpty) {
          return val.toString();
        }
      }
    }
    return defaultDecision;
>>>>>>> f622de6252a0e071a03f6190dd26b9bc9710646f
  }

  Future<void> _submitSignedTransaction(DynamicFormEntity form) async {
    _setProgrammaticDecisionValue(form.widgets, true);
    final error = _validateForm(form);

    if (error != null) {
      _showSnackBar(error);
      return;
    }

    setState(() => _submitting = true);

    try {
      final keysDirectoryPath = await _pickKeysDirectory();
      if (keysDirectoryPath == null) {
        _stopSubmitting();
        return;
      }

      final pin = await _showPinDialog();
      if (pin == null || pin.isEmpty) {
        _stopSubmitting();
        return;
      }

      final payload = await _buildSubmitPayload(form);

      final challenge = await _dataSource.createSigningChallenge(
        processId: widget.processId,
        pin: pin,
      );

      final message = challenge['message']?.toString() ?? '';

      final signature = await _usbSigningService.signMessageFromUsb(
        keysDirectoryPath: keysDirectoryPath,
        pin: pin,
        message: message,
      );

<<<<<<< HEAD
      if (signature.isEmpty) {
        throw Exception('فشل إنشاء التوقيع الرقمي.');
      }
=======
      final decisionValue =
          _determineDecision(form, defaultDecision: 'approve');
      print('Determined internal transaction decision value: "$decisionValue"');
>>>>>>> f622de6252a0e071a03f6190dd26b9bc9710646f

      final completePayload = {
        ...payload,
        'decision': 'approve',
        'signature': {
          'challenge_id': challenge['challenge_id']?.toString() ?? '',
          'signature': signature,
        },
      };

      final completeResponse = await _dataSource.completeSignedTransaction(
        transactionId: challenge['transaction_id'] as int,
        payload: completePayload,
      );

      if (!mounted) return;

      final responseData = completeResponse['data'];
      final submittedData = responseData is Map<String, dynamic>
          ? responseData
          : <String, dynamic>{};

      setState(() {
        _submittedTransaction = submittedData;
        _submitting = false;
      });
    } catch (e) {
      _stopSubmitting();
      _showSnackBar(_cleanError(e));
    }
  }

  void _stopSubmitting() {
    if (!mounted) return;
    setState(() => _submitting = false);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _resetForm() {
    setState(() {
      _submittedTransaction = null;
      _formValues.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.forest),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.umber),
        ),
      );
    }

    if (_submittedTransaction != null) {
      return TransactionSuccessSummary(
        submittedTransaction: _submittedTransaction!,
        onBack: _resetForm,
      );
    }

    final form = _form!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
<<<<<<< HEAD
            _FormHeader(form: form),
            const SizedBox(height: 24),
            _FormCard(
              form: form,
              formValues: _formValues,
              onChanged: (id, value) {
                setState(() {
                  _formValues[id] = value;
                });
              },
=======
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.goldDark),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: form.widgets
                    .where((widgetConfig) {
                      final wData = widgetConfig.data;
                      return wData['is_gateway'] != true &&
                          wData['id'] != 'decision';
                    })
                    .map(
                      (widgetConfig) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: DynamicFormWidgetRenderer(
                          widgetEntity: widgetConfig,
                          value: _formValues[widgetConfig.data['id']],
                          onChanged: (value) {
                            setState(() {
                              _formValues[widgetConfig.data['id']] = value;
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
>>>>>>> f622de6252a0e071a03f6190dd26b9bc9710646f
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: _SubmitButton(
                submitting: _submitting,
                onPressed: () => _submitSignedTransaction(form),
              ),
            ),
          ],
        ),
      ),
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

<<<<<<< HEAD
class _SubmitButton extends StatelessWidget {
  final bool submitting;
  final VoidCallback onPressed;
=======
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 72,
              ),
              const SizedBox(height: 16),
              Text(
                'تم توقيع وتقديم المعاملة بنجاح',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(fontWeight: AppTextStyles.black, color: AppColors.forest),
              ),
              const SizedBox(height: 8),
              Text(
                'تم حفظ البيانات وإرسال المعاملة للمرحلة التالية.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.goldDark),
              ),
              const SizedBox(height: 28),
              _sectionTitle('ملخص المعاملة'),
              const SizedBox(height: 12),
              _summaryRow(
                'اسم المعاملة',
                transactionData['form_name']?.toString() ?? '-',
              ),
              _summaryRow(
                'المرحلة الحالية',
                transactionData['stage_name']?.toString() ?? '-',
              ),
              _summaryRow(
                'تاريخ التقديم',
                transactionData['completed_at']?.toString() ?? '-',
              ),
              _summaryRow(
                'حالة سير العمل',
                _workflowStatusText(
                  submittedTransaction['workflow_status']?.toString(),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('البيانات المقدّمة'),
              const SizedBox(height: 12),
              if (widgets.isEmpty)
                const Text(
                  'لا توجد بيانات إضافية.',
                  style: AppTextStyles.bodyMedium,
                )
              else
                ...widgets.map((item) {
                  final widget = item as Map<String, dynamic>;
                  final data = widget['data'] as Map<String, dynamic>? ?? {};
                  final label = data['label']?.toString() ?? '-';
                  final value = _formatValue(widget['value']);
>>>>>>> f622de6252a0e071a03f6190dd26b9bc9710646f

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
<<<<<<< HEAD
=======

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
    );
  }

  static Widget _summaryRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.charcoalDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.medium),
            ),
          ),
        ],
      ),
    );
  }

  static String _workflowStatusText(String? status) {
    switch (status) {
      case 'running':
        return 'قيد المعالجة';
      case 'completed':
        return 'مكتملة';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status ?? '-';
    }
  }

  static String _formatValue(dynamic value) {
    if (value == null) return '-';

    if (value is List) {
      if (value.isEmpty) return '-';

      return value.map((item) {
        if (item is Map) {
          return item['original_name']?.toString() ??
              item['path']?.toString() ??
              item.toString();
        }

        return item.toString();
      }).join('، ');
    }

    if (value is Map) {
      return value['value']?.toString() ??
          value['name']?.toString() ??
          value.toString();
    }

    return value.toString();
  }
>>>>>>> f622de6252a0e071a03f6190dd26b9bc9710646f
}
