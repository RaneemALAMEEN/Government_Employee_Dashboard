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
        final templateId =
            form.templateIds.isNotEmpty ? form.templateIds.first : 1;

        final templateResult = await getDocumentTemplate(
          templateId: templateId,
        );

        templateResult.fold(
          (failure) {
            emit(
              state.copyWith(
                loading: false,
                form: form,
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

  Future<void> _onSubmit(
    SubmitInternalTransactionForm event,
    Emitter<InternalTransactionFormState> emit,
  ) async {
    final form = state.form;

    if (form == null) {
      emit(state.copyWith(errorMessage: 'تعذر قراءة بيانات النموذج'));
      return;
    }

    final formValidationError = _validateForm(form, state.formValues);
    if (formValidationError != null) {
      emit(state.copyWith(errorMessage: formValidationError));
      return;
    }

    final template = state.template;
    if (template != null) {
      final templateValidationError = _validateForm(
        template.config,
        state.templateValues,
      );

      if (templateValidationError != null) {
        emit(state.copyWith(errorMessage: templateValidationError));
        return;
      }
    }

    emit(
      state.copyWith(
        submitting: true,
        clearError: true,
      ),
    );

    try {
      final payload = await _buildSubmitPayload(
        form: form,
        formValues: state.formValues,
        template: template,
        templateValues: state.templateValues,
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
            'decision': 'approve',
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
                  ? responseData
                  : <String, dynamic>{};

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

  Future<Map<String, dynamic>> _buildSubmitPayload({
    required DynamicFormEntity form,
    required Map<String, dynamic> formValues,
    required dynamic template,
    required Map<String, dynamic> templateValues,
  }) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    for (final widget in form.widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final value = formValues[id];

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

    final templatesPayload = <Map<String, dynamic>>[];

    if (template != null) {
      templatesPayload.add({
        'id': template.id,
        'value': Map<String, dynamic>.from(templateValues),
      });
    }

    return {
      'form_id': form.formId,
      'form_name': form.formName,
      'widgets': widgetsPayload,
      'templates': templatesPayload,
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

      final result = await uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId,
        key: widgetId,
      );

      result.fold(
        (failure) => throw Exception(failure.message),
        (uploaded) => uploadedFiles.add(uploaded),
      );
    }

    return uploadedFiles;
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

  int _parseTypeDocId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 1;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
