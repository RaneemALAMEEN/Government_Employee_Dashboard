import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/services/api_service.dart';

import '../../../../core/services/usb_signing_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../data/datasources/internal_transactions_remote_data_source.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import '../widgets/dynamic_form_widget_renderer.dart';

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
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<String?> _pickKeysDirectory() async {
    return FilePicker.platform.getDirectoryPath(
      dialogTitle: 'اختاري مجلد مفاتيح الموظف من الفلاشة',
    );
  }

  Future<String?> _showPinDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إدخال رمز PIN'),
            content: TextField(
              controller: controller,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'رمز PIN',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final pin = controller.text.trim();
                  if (pin.length != 6) return;

                  Navigator.of(dialogContext).pop(pin);
                },
                child: const Text('متابعة'),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateForm(DynamicFormEntity form) {
    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final label = widget.data['label']?.toString() ?? 'هذا الحقل';
      final isRequired = widget.data['is_required'] == true;
      final value = _formValues[id];

      if (isRequired) {
        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          return 'يرجى تعبئة حقل: $label';
        }
      }

      if (widget.widgetType == 'text_field' && value is String) {
        final minLength = widget.data['min_length'] as int?;
        final maxLength = widget.data['max_length'] as int?;

        if (minLength != null && value.trim().length < minLength) {
          return 'حقل $label يجب أن يحتوي على $minLength أحرف على الأقل';
        }

        if (maxLength != null && value.trim().length > maxLength) {
          return 'حقل $label يجب ألا يتجاوز $maxLength حرف';
        }
      }
    }

    return null;
  }

  Future<Map<String, dynamic>> _buildSubmitPayloadWithUploadedFiles(
    DynamicFormEntity form,
  ) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final value = _formValues[id];

      final dynamic finalValue = widget.widgetType == 'file_picker'
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
    if (value is! List || value.isEmpty) {
      return [];
    }

    final typeDocId = widgetData['type_doc_id'];
    final uploadedFiles = <Map<String, dynamic>>[];

    for (final file in value) {
      final filePath = file.path;

      if (filePath == null || filePath.toString().isEmpty) {
        continue;
      }

      final uploaded = await _dataSource.uploadTransactionFile(
        filePath: filePath.toString(),
        typeDocId: typeDocId is int
            ? typeDocId
            : int.tryParse(typeDocId.toString()) ?? 1,
        key: widgetId,
      );

      uploadedFiles.add(uploaded);
    }

    return uploadedFiles;
  }

  Future<void> _submitSignedTransaction(DynamicFormEntity form) async {
    final error = _validateForm(form);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final payload = await _buildSubmitPayloadWithUploadedFiles(form);

      final keysDirectoryPath = await _pickKeysDirectory();
      if (keysDirectoryPath == null) {
        if (!mounted) return;
        setState(() => _submitting = false);
        return;
      }

      final pin = await _showPinDialog();
      if (pin == null || pin.isEmpty) {
        if (!mounted) return;
        setState(() => _submitting = false);
        return;
      }

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
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
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
          style: const TextStyle(color: AppColors.umber),
        ),
      );
    }

    if (_submittedTransaction != null) {
      return _SuccessSummary(
        submittedTransaction: _submittedTransaction!,
        onCreateNew: () {
          setState(() {
            _submittedTransaction = null;
            _formValues.clear();
          });
        },
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
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed:
                      _submitting ? null : () => _submitSignedTransaction(form),
                  icon: _submitting
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
                    _submitting
                        ? 'جارٍ التوقيع والتقديم...'
                        : 'توقيع وتقديم المعاملة',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessSummary extends StatelessWidget {
  final Map<String, dynamic> submittedTransaction;
  final VoidCallback onCreateNew;

  const _SuccessSummary({
    required this.submittedTransaction,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    final transactionData =
        submittedTransaction['data'] as Map<String, dynamic>? ?? {};

    final widgets = transactionData['widgets'] as List? ?? [];

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
              const Text(
                'تم توقيع وتقديم المعاملة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.forest,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'تم حفظ البيانات وإرسال المعاملة للمرحلة التالية.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 14,
                ),
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
                  style: TextStyle(color: AppColors.charcoal),
                )
              else
                ...widgets.map((item) {
                  final widget = item as Map<String, dynamic>;
                  final data = widget['data'] as Map<String, dynamic>? ?? {};
                  final label = data['label']?.toString() ?? '-';
                  final value = _formatValue(widget['value']);

                  return _summaryRow(label, value);
                }),
              const SizedBox(height: 26),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: onCreateNew,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.forest,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
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
              style: const TextStyle(
                color: AppColors.charcoalDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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
}
