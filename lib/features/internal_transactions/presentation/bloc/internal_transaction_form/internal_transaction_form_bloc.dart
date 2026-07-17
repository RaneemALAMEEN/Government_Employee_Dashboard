import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/usb_signing_service.dart';
import '../../../domain/entities/dynamic_form_entity.dart';
import '../../../domain/usecases/complete_signed_transaction_usecase.dart';
import '../../../domain/usecases/create_signing_challenge_usecase.dart';
import '../../../domain/usecases/get_document_template_usecase.dart';
import '../../../domain/usecases/get_stage_config_usecase.dart';
import '../../../domain/usecases/upload_transaction_file_usecase.dart';
import 'internal_transaction_form_event.dart';
import 'internal_transaction_form_state.dart';

class InternalTransactionFormBloc
    extends Bloc<InternalTransactionFormEvent, InternalTransactionFormState> {
  final GetStageConfigUseCase getStageConfig;
  final GetDocumentTemplateUseCase getDocumentTemplate;
  final UploadTransactionFileUseCase uploadTransactionFile;
  final CreateSigningChallengeUseCase createSigningChallenge;
  final CompleteSignedTransactionUseCase completeSignedTransaction;
  final UsbSigningService usbSigningService;

  InternalTransactionFormBloc({
    required this.getStageConfig,
    required this.getDocumentTemplate,
    required this.uploadTransactionFile,
    required this.createSigningChallenge,
    required this.completeSignedTransaction,
    required this.usbSigningService,
  }) : super(InternalTransactionFormState.initial()) {
    on<LoadInternalTransactionForm>(_onLoadForm);
    on<UpdateInternalTransactionFormValue>(_onUpdateValue);
    on<UpdateInternalTransactionTemplateValue>(_onUpdateTemplateValue);
    on<SubmitInternalTransactionForm>(_onSubmit);
    on<ResetInternalTransactionForm>(_onReset);
  }

  Future<void> _onLoadForm(
    LoadInternalTransactionForm event,
    Emitter<InternalTransactionFormState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    final result = await getStageConfig(processId: event.processId);

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            loading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (form) async {
        final formValues = _initialValuesFromWidgets(form.widgets);
        final templateValues = _initialValuesFromInlineTemplates(form);

        if (form.templates.isNotEmpty || form.templateIds.isEmpty) {
          emit(
            state.copyWith(
              loading: false,
              form: form,
              formValues: formValues,
              templateValues: templateValues,
            ),
          );
          return;
        }

        final templateId = form.templateIds.first;

        final templateResult = await getDocumentTemplate(
          templateId: templateId,
        );

        templateResult.fold(
          (failure) {
            emit(
              state.copyWith(
                loading: false,
                form: form,
                formValues: formValues,
                templateValues: templateValues,
                errorMessage: failure.message,
              ),
            );
          },
          (template) {
            emit(
              state.copyWith(
                loading: false,
                form: form,
                template: template,
                formValues: formValues,
                templateValues: {
                  ...templateValues,
                  ..._initialValuesFromWidgets(template.config.widgets),
                },
              ),
            );
          },
        );
      },
    );
  }

  void _onUpdateValue(
    UpdateInternalTransactionFormValue event,
    Emitter<InternalTransactionFormState> emit,
  ) {
    final updatedValues = Map<String, dynamic>.from(state.formValues);
    updatedValues[event.id] = event.value;

    emit(state.copyWith(formValues: updatedValues));
  }

  void _onUpdateTemplateValue(
    UpdateInternalTransactionTemplateValue event,
    Emitter<InternalTransactionFormState> emit,
  ) {
    final updatedValues = Map<String, dynamic>.from(state.templateValues);
    updatedValues[event.id] = event.value;

    emit(state.copyWith(templateValues: updatedValues));
  }

  String? validateCurrentForm() {
    final form = state.form;

    if (form == null) {
      return 'تعذر قراءة بيانات النموذج';
    }

    final formValidationError = _validateForm(form, state.formValues);
    if (formValidationError != null) return formValidationError;

    final template = state.template;
    if (template != null) {
      final templateValidationError = _validateForm(
        template.config,
        state.templateValues,
      );

      if (templateValidationError != null) return templateValidationError;
    }

    for (final inlineTemplate in form.templates) {
      final templateValidationError = _validateForm(
        inlineTemplate.config,
        state.templateValues,
      );

      if (templateValidationError != null) return templateValidationError;
    }

    return null;
  }

  Future<void> _onSubmit(
    SubmitInternalTransactionForm event,
    Emitter<InternalTransactionFormState> emit,
  ) async {
    final validationError = validateCurrentForm();
    if (validationError != null) {
      emit(state.copyWith(errorMessage: validationError));
      return;
    }

    emit(
      state.copyWith(
        submitting: true,
        clearError: true,
      ),
    );

    try {
      final form = state.form!;
      final template = state.template;

      final payloadResult = await _buildSubmitPayload(
        form: form,
        formValues: state.formValues,
        template: template,
        templateValues: state.templateValues,
      );

      if (!payloadResult.isSuccess) {
        emit(
          state.copyWith(
            submitting: false,
            errorMessage: payloadResult.errorMessage,
          ),
        );
        return;
      }

      final payload = payloadResult.payload!;
      final uploadedFilesCount = _countUploadedFiles(payload);
      debugPrint(
        '[InternalTransactionForm] اكتمل رفع $uploadedFilesCount '
        'مرفق/مرفقات قبل التوقيع وإرسال المعاملة.',
      );

      final challengeResult = await createSigningChallenge(
        processId: event.processId,
        pin: event.pin,
      );

      await challengeResult.fold(
        (failure) async {
          emit(
            state.copyWith(
              submitting: false,
              errorMessage: failure.message,
            ),
          );
        },
        (challenge) async {
          final message = challenge['message']?.toString() ?? '';

          final signature = await usbSigningService.signMessageFromUsb(
            keysDirectoryPath: event.keysDirectoryPath,
            pin: event.pin,
            message: message,
          );

          if (signature.isEmpty) {
            emit(
              state.copyWith(
                submitting: false,
                errorMessage: 'فشل إنشاء التوقيع الرقمي.',
              ),
            );
            return;
          }

          final completePayload = {
            ...payload,
            'decision': payload['decision']?.toString().isNotEmpty == true
                ? payload['decision']
                : 'approve',
            'signature': {
              'challenge_id': challenge['challenge_id']?.toString() ?? '',
              'signature': signature,
            },
          };

          final transactionId = challenge['transaction_id'] as int;

          final completeResult = await completeSignedTransaction(
            transactionId: transactionId,
            payload: completePayload,
          );

          completeResult.fold(
            (failure) {
              emit(
                state.copyWith(
                  submitting: false,
                  errorMessage: failure.message,
                ),
              );
            },
            (completeResponse) {
              final responseData = completeResponse['data'];
              final submittedData = responseData is Map<String, dynamic>
                  ? Map<String, dynamic>.from(responseData)
                  : <String, dynamic>{};
              submittedData['uploaded_files_count'] = uploadedFilesCount;

              debugPrint(
                '[InternalTransactionForm] تم توقيع وإنشاء المعاملة بنجاح، '
                'وتم ربط $uploadedFilesCount مرفق/مرفقات بها على السيرفر.',
              );

              emit(
                state.copyWith(
                  submitting: false,
                  submittedTransaction: submittedData,
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: _cleanError(e),
        ),
      );
    }
  }

  int _countUploadedFiles(Map<String, dynamic> payload) {
    var count = 0;

    void countWidgets(dynamic widgets) {
      if (widgets is! List) return;
      for (final widget in widgets) {
        if (widget is Map &&
            widget['widget_type'] == 'file_picker' &&
            widget['value'] is List) {
          count += (widget['value'] as List).length;
        }
      }
    }

    countWidgets(payload['widgets']);
    final templates = payload['templates'];
    if (templates is List) {
      for (final template in templates) {
        if (template is Map) countWidgets(template['widgets']);
      }
    }

    return count;
  }

  void _onReset(
    ResetInternalTransactionForm event,
    Emitter<InternalTransactionFormState> emit,
  ) {
    emit(
      InternalTransactionFormState.initial().copyWith(
        loading: false,
        form: state.form,
        template: state.template,
      ),
    );
  }

  Future<_SubmitPayloadResult> _buildSubmitPayload({
    required DynamicFormEntity form,
    required Map<String, dynamic> formValues,
    required dynamic template,
    required Map<String, dynamic> templateValues,
  }) async {
    final widgetsResult = await _buildWidgetsPayload(
      widgets: form.widgets,
      values: formValues,
    );

    if (!widgetsResult.isSuccess) {
      return _SubmitPayloadResult.failure(widgetsResult.errorMessage!);
    }

    final templatesPayload = <Map<String, dynamic>>[];

    for (final inlineTemplate in form.templates) {
      final templateWidgetsResult = await _buildWidgetsPayload(
        widgets: inlineTemplate.config.widgets,
        values: templateValues,
      );

      if (!templateWidgetsResult.isSuccess) {
        return _SubmitPayloadResult.failure(
          templateWidgetsResult.errorMessage!,
        );
      }

      templatesPayload.add({
        'id': inlineTemplate.id,
        'widgets': templateWidgetsResult.widgets,
      });
    }

    if (template != null) {
      final templateWidgetsResult = await _buildWidgetsPayload(
        widgets: template.config.widgets,
        values: templateValues,
      );

      if (!templateWidgetsResult.isSuccess) {
        return _SubmitPayloadResult.failure(
          templateWidgetsResult.errorMessage!,
        );
      }

      templatesPayload.add({
        'id': template.id,
        'widgets': templateWidgetsResult.widgets,
      });
    }

    final payload = {
      'form_id': form.formId,
      'form_name': form.formName,
      'widgets': widgetsResult.widgets,
      'templates': templatesPayload,
      'note': form.note,
      if (form.decision.isNotEmpty) 'decision': form.decision,
      if (form.expectedVersion != null)
        'expected_version': form.expectedVersion,
    };

    return _SubmitPayloadResult.success(payload);
  }

  Future<_WidgetsPayloadResult> _buildWidgetsPayload({
    required List<dynamic> widgets,
    required Map<String, dynamic> values,
  }) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    for (final widget in widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final value = values[id];

      dynamic finalValue = value;

      if (finalValue is String) {
        finalValue = _normalizeDigits(finalValue);
      }

      if (widget.widgetType == 'file_picker') {
        final uploadResult = await _uploadFilePickerValue(
          widgetId: id,
          widgetData: widget.data,
          value: value,
        );

        if (!uploadResult.isSuccess) {
          return _WidgetsPayloadResult.failure(uploadResult.errorMessage!);
        }

        finalValue = uploadResult.files;
      }

      widgetsPayload.add({
        'widget_type': widget.widgetType,
        'data': widget.data,
        'value': finalValue,
      });
    }

    return _WidgetsPayloadResult.success(widgetsPayload);
  }

  Future<_FilePickerUploadResult> _uploadFilePickerValue({
    required String widgetId,
    required Map<String, dynamic> widgetData,
    required dynamic value,
  }) async {
    if (value is! List || value.isEmpty) {
      return _FilePickerUploadResult.success(const []);
    }

    final uploadedFiles = <Map<String, dynamic>>[];
    final typeDocId = _parseTypeDocId(widgetData['type_doc_id']);

    for (final file in value) {
      if (file is Map && file['path']?.toString().isNotEmpty == true) {
        final uploadedFile = Map<String, dynamic>.from(file);
        uploadedFiles.add({
          'key': uploadedFile['key']?.toString() ?? widgetId,
          'path': uploadedFile['path'].toString(),
          'type_doc_id': uploadedFile['type_doc_id'] ?? typeDocId,
        });
        continue;
      }

      final filePath = file.path?.toString();

      if (filePath == null || filePath.isEmpty) continue;

      final result = await uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId,
        key: widgetId,
      );

      final uploadError = result.fold<String?>(
        (failure) => failure.message,
        (uploaded) {
          uploadedFiles.add(uploaded);
          return null;
        },
      );

      if (uploadError != null) {
        return _FilePickerUploadResult.failure(uploadError);
      }
    }

    return _FilePickerUploadResult.success(uploadedFiles);
  }

  String? _validateForm(
    DynamicFormEntity form,
    Map<String, dynamic> formValues,
  ) {
    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final label = widget.data['label']?.toString() ?? 'هذا الحقل';
      final isRequired = widget.data['is_required'] == true;
      final value = formValues[id];

      if (isRequired && _isEmptyValue(value)) {
        return _validationFailure(
          message: 'يرجى تعبئة حقل: $label',
          id: id,
          label: label,
          widgetType: widget.widgetType,
          value: value,
          data: widget.data,
        );
      }

      if (_isEmptyValue(value)) continue;

      if (widget.widgetType == 'text_field' && value is String) {
        final error = _validateTextField(
          label: label,
          value: value,
          data: widget.data,
        );

        if (error != null) {
          return _validationFailure(
            message: error,
            id: id,
            label: label,
            widgetType: widget.widgetType,
            value: value,
            data: widget.data,
          );
        }
      }

      if (widget.widgetType == 'check_list' && value is List) {
        final error = _validateCheckList(
          label: label,
          value: value,
          data: widget.data,
        );

        if (error != null) {
          return _validationFailure(
            message: error,
            id: id,
            label: label,
            widgetType: widget.widgetType,
            value: value,
            data: widget.data,
          );
        }
      }
    }

    return null;
  }

  String _validationFailure({
    required String message,
    required String id,
    required String label,
    required String widgetType,
    required dynamic value,
    required Map<String, dynamic> data,
  }) {
    debugPrint(
      '[InternalTransactionForm] Validation stopped submit: '
      'message="$message", id="$id", label="$label", '
      'widgetType="$widgetType", inputType="${data['input_type']}", '
      'regex="${data['regex']}", required="${data['is_required']}", '
      'value="$value"',
    );
    return message;
  }

  String? _validateTextField({
    required String label,
    required String value,
    required Map<String, dynamic> data,
  }) {
    final trimmedValue = _normalizeDigits(value).trim();

    final minLength = data['min_length'] as int?;
    final maxLength = data['max_length'] as int?;
    final inputType = data['input_type']?.toString();
    final regex = data['regex']?.toString();
    final isPhoneField = _isPhoneField(
      label: label,
      inputType: inputType,
      regex: regex,
    );

    if (minLength != null && trimmedValue.length < minLength) {
      return 'حقل $label يجب أن يحتوي على $minLength أحرف على الأقل';
    }

    if (maxLength != null && trimmedValue.length > maxLength) {
      return 'حقل $label يجب ألا يتجاوز $maxLength حرف';
    }

    if (isPhoneField) {
      if (!RegExp(r'^0[59]\d{8}$').hasMatch(trimmedValue)) {
        return 'قيمة حقل $label غير صحيحة';
      }

      return null;
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

  bool _isPhoneField({
    required String label,
    required String? inputType,
    required String? regex,
  }) {
    final normalizedLabel = label.trim();
    final normalizedRegex = regex?.trim() ?? '';

    return inputType == 'phone' ||
        inputType == 'phoneNumber' ||
        normalizedLabel.contains('هاتف') ||
        normalizedLabel.contains('موبايل') ||
        normalizedRegex == r'^09\d{8}$' ||
        normalizedRegex == r'^05\d{8}$';
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

  String _normalizeDigits(String value) {
    const digits = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
      '۰': '0',
      '۱': '1',
      '۲': '2',
      '۳': '3',
      '۴': '4',
      '۵': '5',
      '۶': '6',
      '۷': '7',
      '۸': '8',
      '۹': '9',
    };

    return value.split('').map((char) => digits[char] ?? char).join();
  }

  int _parseTypeDocId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 1;
  }

  Map<String, dynamic> _initialValuesFromWidgets(List<dynamic> widgets) {
    final values = <String, dynamic>{};

    for (final widget in widgets) {
      final id = widget.data['id']?.toString() ?? '';

      if (id.isEmpty || widget.initialValue == null) continue;

      values[id] = widget.initialValue;
    }

    return values;
  }

  Map<String, dynamic> _initialValuesFromInlineTemplates(
    DynamicFormEntity form,
  ) {
    final values = <String, dynamic>{};

    for (final template in form.templates) {
      values.addAll(_initialValuesFromWidgets(template.config.widgets));
    }

    return values;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

class _SubmitPayloadResult {
  final Map<String, dynamic>? payload;
  final String? errorMessage;

  const _SubmitPayloadResult._({
    this.payload,
    this.errorMessage,
  });

  factory _SubmitPayloadResult.success(Map<String, dynamic> payload) {
    return _SubmitPayloadResult._(payload: payload);
  }

  factory _SubmitPayloadResult.failure(String errorMessage) {
    return _SubmitPayloadResult._(errorMessage: errorMessage);
  }

  bool get isSuccess => payload != null;
}

class _WidgetsPayloadResult {
  final List<Map<String, dynamic>>? widgets;
  final String? errorMessage;

  const _WidgetsPayloadResult._({
    this.widgets,
    this.errorMessage,
  });

  factory _WidgetsPayloadResult.success(List<Map<String, dynamic>> widgets) {
    return _WidgetsPayloadResult._(widgets: widgets);
  }

  factory _WidgetsPayloadResult.failure(String errorMessage) {
    return _WidgetsPayloadResult._(errorMessage: errorMessage);
  }

  bool get isSuccess => widgets != null;
}

class _FilePickerUploadResult {
  final List<Map<String, dynamic>>? files;
  final String? errorMessage;

  const _FilePickerUploadResult._({
    this.files,
    this.errorMessage,
  });

  factory _FilePickerUploadResult.success(List<Map<String, dynamic>> files) {
    return _FilePickerUploadResult._(files: files);
  }

  factory _FilePickerUploadResult.failure(String errorMessage) {
    return _FilePickerUploadResult._(errorMessage: errorMessage);
  }

  bool get isSuccess => files != null;
}
