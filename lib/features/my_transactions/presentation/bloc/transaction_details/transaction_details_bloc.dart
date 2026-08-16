import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/my_transactions_repository.dart';
import '../../../domain/usecases/get_task_details.dart';
import '../../../domain/usecases/get_transaction_certificate.dart';
import '../../../domain/usecases/pickup_task.dart';
import '../../../domain/usecases/release_task.dart';
import '../../../domain/usecases/submit_transaction.dart';
import 'transaction_details_event.dart';
import 'transaction_details_state.dart';

class TransactionDetailsBloc
    extends Bloc<TransactionDetailsEvent, TransactionDetailsState> {
  final GetTaskDetails getTaskDetails;
  final GetTransactionCertificate getTransactionCertificate;
  final PickupTask pickupTask;
  final ReleaseTask releaseTask;
  final SubmitTransaction submitTransaction;
  final MyTransactionsRepository repository;

  String? _currentNumericTransactionId;

  TransactionDetailsBloc({
    required this.getTaskDetails,
    required this.getTransactionCertificate,
    required this.pickupTask,
    required this.releaseTask,
    required this.submitTransaction,
    required this.repository,
  }) : super(TransactionDetailsInitial()) {
    on<LoadTransactionDetails>(_onLoadTransactionDetails);
    on<PickupTransactionEvent>(_onPickupTransaction);
    on<ReleaseTransactionEvent>(_onReleaseTransaction);
    on<SubmitTransactionDetailsEvent>(_onSubmitTransactionDetails);
    on<UpdateTemplateFormValue>(_onUpdateTemplateFormValue);
  }

  Future<void> _onLoadTransactionDetails(
    LoadTransactionDetails event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    emit(TransactionDetailsLoading());

    if (event.numericTransactionId != null &&
        event.numericTransactionId!.isNotEmpty &&
        int.tryParse(event.numericTransactionId!) != null &&
        !event.numericTransactionId!.contains('-')) {
      _currentNumericTransactionId = event.numericTransactionId;
    } else if (int.tryParse(event.taskId.trim()) != null &&
        !event.taskId.trim().contains('-')) {
      _currentNumericTransactionId = event.taskId.trim();
    }

    final isCompletedOrRejected = event.status == 'منجزة' ||
        event.status == 'تم الرفض' ||
        event.status == 'completed' ||
        event.status == 'rejected';

    final targetId = _currentNumericTransactionId ?? event.taskId;

    final result = isCompletedOrRejected
        ? await getTransactionCertificate(taskId: targetId)
        : await getTaskDetails(taskId: event.taskId);

    await result.fold(
      (failure) async => emit(TransactionDetailsFailure(failure.message)),
      (response) async {
        final rawData = response['data'] as Map<String, dynamic>? ?? {};
        final taskData = Map<String, dynamic>.from(rawData);

        if (isCompletedOrRejected) {
          taskData['process_definition_name'] = taskData['process_name'];

          final history =
              taskData['transaction_history'] as Map<String, dynamic>? ?? {};
          final historyData = history['data'] as Map<String, dynamic>? ?? {};
          final applicant =
              historyData['applicant'] as Map<String, dynamic>? ?? {};

          taskData['applicant'] = {
            'first_name':
                applicant['first_name_employee'] ?? applicant['first_name'],
            'father_name':
                applicant['father_name_employee'] ?? applicant['father_name'],
            'last_name':
                applicant['last_name_employee'] ?? applicant['last_name'],
            'national_id':
                applicant['national_id_employee'] ?? applicant['national_id'],
            'phone_number':
                applicant['phone_number_employee'] ?? applicant['phone_number'],
          };

          taskData['status'] =
              (event.status == 'منجزة' || event.status == 'completed')
                  ? 'completed'
                  : 'rejected';
        }

        final formValues = <String, dynamic>{};
        final currentStage = taskData['currentStage'] as Map<String, dynamic>?;
        final config = currentStage?['config'] as Map<String, dynamic>?;

        // Extract template IDs
        final templateIds = <int>[];
        if (config != null) {
          final widgets = config['widgets'] as List? ?? [];
          for (final widgetJson in widgets) {
            final w = widgetJson as Map<String, dynamic>;
            final wData = w['data'] as Map<String, dynamic>? ?? {};
            final id = wData['id']?.toString() ?? '';
            formValues[id] = w['value'];
          }

          final templateJson =
              config['template'] as List? ?? config['templates'] as List? ?? [];
          for (final item in templateJson) {
            final idStr =
                item is Map ? (item['template_id'] ?? item['id']) : item;
            final id = int.tryParse(idStr?.toString() ?? '') ?? 0;
            if (id > 0) templateIds.add(id);
          }
        }

        // Fetch templates
        final loadedTemplates = <Map<String, dynamic>>[];
        for (final templateId in templateIds) {
          final templateResult =
              await repository.getDocumentTemplate(templateId: templateId);
          templateResult.fold(
            (_) {}, // Silently fail on individual template fetch
            (templateResponse) {
              final templateData =
                  templateResponse['data'] as Map<String, dynamic>? ??
                      templateResponse;
              loadedTemplates.add(templateData);
            },
          );
        }

        final extracted = _extractNumericTransactionId(taskData, '');
        if (extracted.isNotEmpty &&
            int.tryParse(extracted) != null &&
            !extracted.contains('-')) {
          _currentNumericTransactionId = extracted;
        }

        final extractedTxId = _currentNumericTransactionId ?? event.taskId;

        emit(TransactionDetailsLoaded(
          taskData: taskData,
          formValues: formValues,
          loadedTemplates: loadedTemplates,
          transactionId: extractedTxId,
        ));
      },
    );
  }

  String _extractNumericTransactionId(
      Map<String, dynamic> taskData, String defaultTaskId) {
    final history =
        taskData['transaction_history'] as Map<String, dynamic>? ?? {};
    final historyData = history['data'] as Map<String, dynamic>? ?? {};

    final candidates = [
      taskData['transaction_id'],
      taskData['id_transaction'],
      taskData['id_process'],
      taskData['process_id'],
      history['id_process'],
      history['id_transaction'],
      history['transaction_id'],
      history['id'],
      historyData['id_process'],
      historyData['transaction_id'],
      historyData['id_transaction'],
      historyData['id'],
      taskData['id'],
    ];

    for (final val in candidates) {
      if (val == null) continue;
      if (val is int && val > 0) {
        return val.toString();
      }
      final str = val.toString().trim();
      if (str.isNotEmpty && int.tryParse(str) != null && !str.contains('-')) {
        return str;
      }
    }

    if (int.tryParse(defaultTaskId.trim()) != null &&
        !defaultTaskId.trim().contains('-')) {
      return defaultTaskId.trim();
    }

    return defaultTaskId;
  }

  Future<void> _onPickupTransaction(
    PickupTransactionEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final currentState = state;
    emit(TransactionDetailsSubmitting(message: 'جاري استلام المعاملة...'));
    final result = await pickupTask(taskId: event.taskId);

    result.fold(
      (failure) {
        emit(TransactionDetailsFailure(failure.message));
        if (currentState is TransactionDetailsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(TransactionDetailsActionSuccess(
            'تم استلام المعاملة بنجاح — أصبحت الآن قيد التنفيذ',
            shouldReloadList: true));
        add(LoadTransactionDetails(event.taskId));
      },
    );
  }

  Future<void> _onReleaseTransaction(
    ReleaseTransactionEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final currentState = state;
    emit(TransactionDetailsSubmitting(message: 'جاري إرجاع المعاملة...'));
    final result = await releaseTask(taskId: event.taskId);

    result.fold(
      (failure) {
        emit(TransactionDetailsFailure(failure.message));
        if (currentState is TransactionDetailsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(TransactionDetailsActionSuccess(
            'تم إلغاء استلام المعاملة وإرجاعها لحالة الانتظار',
            shouldReloadList: true));
        add(LoadTransactionDetails(event.taskId));
      },
    );
  }

  Future<void> _onSubmitTransactionDetails(
    SubmitTransactionDetailsEvent event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    final currentState = state;
    emit(TransactionDetailsSubmitting(message: 'جاري معالجة المعاملة...'));

    final result = await submitTransaction(
      taskId: event.taskId,
      widgets: event.widgets,
      formValues: event.formValues,
      formId: event.formId,
      formName: event.formName,
      isApprove: event.isApprove,
      note: event.note,
      pin: event.pin,
      keysDirectoryPath: event.keysDirectoryPath,
      templateIds: event.templateIds,
      templateFormValues: event.templateFormValues,
      loadedTemplates: event.loadedTemplates,
      expectedVersion: event.expectedVersion,
      assignments: event.assignments,
    );

    result.fold(
      (failure) {
        final msg = failure.message;

        // Parse error code from message
        String errorCode = 'UNKNOWN_ERROR';
        String title = 'حدث خطأ أثناء معالجة المعاملة';
        List<String> suggestions = [];

        if (msg.contains('VERSION_CONFLICT') ||
            msg.contains('تعارض في إصدار المعاملة') ||
            msg.contains('409')) {
          errorCode = 'VERSION_CONFLICT';
          title = 'تعارض في إصدار المعاملة';
          suggestions = [
            'قام شخص آخر بالتعديل على هذه المعاملة قبلك',
            'سيتم إعادة تحميل البيانات المحدّثة تلقائياً',
            'يرجى مراجعة البيانات وإعادة التوقيع مرة أخرى',
          ];
        } else if (msg.contains('CAMUNDA_TASK_NOT_FOUND') ||
            msg.contains('غير موجود في قائمة المهام') ||
            msg.contains('404')) {
          errorCode = 'TASK_NOT_FOUND';
          title = 'المهمة لم تعد متاحة';
          suggestions = [
            'ربما تم إكمال هذه المعاملة مسبقاً من قبل موظف آخر',
            'أو أن سير العمل قد انتقل لمرحلة أخرى',
            'يرجى العودة إلى قائمة المعاملات والتحقق من الحالة',
          ];
        } else if (msg.contains('SIGNING') ||
            msg.contains('signing') ||
            msg.contains('التوقيع')) {
          errorCode = 'SIGNING_ERROR';
          title = 'خطأ في عملية التوقيع الإلكتروني';
          suggestions = [
            'تأكد من أن وحدة USB للتوقيع موصولة بشكل صحيح',
            'تحقق من صلاحية مفاتيح التوقيع',
            'حاول إعادة إدخال الفلاشة وإعادة المحاولة',
          ];
        } else if (msg.contains('LOCK') ||
            msg.contains('locked') ||
            msg.contains('مقفلة')) {
          errorCode = 'LOCK_ERROR';
          title = 'المعاملة مقفلة';
          suggestions = [
            'هذه المعاملة مقفلة حالياً من قبل موظف آخر',
            'لا يمكنك اتخاذ إجراء عليها حتى يتم تحريرها',
            'يرجى المحاولة لاحقاً أو التواصل مع الموظف المعني',
          ];
        } else {
          suggestions = [
            'حاول إعادة تحميل الصفحة والمحاولة مرة أخرى',
            'تأكد من اتصالك بالشبكة',
            'في حال استمرار المشكلة تواصل مع الدعم الفني',
          ];
        }

        emit(TransactionSubmitError(
          taskId: event.taskId,
          errorCode: errorCode,
          title: title,
          message: msg,
          suggestions: suggestions,
        ));

        // Auto-reload for version conflict
        if (errorCode == 'VERSION_CONFLICT') {
          add(LoadTransactionDetails(event.taskId));
        }
      },
      (submitResponse) {
        if (submitResponse is Map<String, dynamic>) {
          final resData =
              submitResponse['data'] as Map<String, dynamic>? ?? submitResponse;
          final extracted = _extractNumericTransactionId(resData, '');
          if (extracted.isNotEmpty &&
              int.tryParse(extracted) != null &&
              !extracted.contains('-')) {
            _currentNumericTransactionId = extracted;
          }
        }

        final String txId = _currentNumericTransactionId ??
            (currentState is TransactionDetailsLoaded &&
                    currentState.transactionId != null &&
                    currentState.transactionId!.isNotEmpty
                ? currentState.transactionId!
                : event.taskId);

        if (event.isApprove) {
          emit(TransactionSignedSuccess(
            taskId: event.taskId,
            transactionId: txId,
            message: 'تم توقيع المعاملة بنجاح',
            isApproved: true,
          ));
        } else {
          emit(TransactionSignedSuccess(
            taskId: event.taskId,
            transactionId: txId,
            message: 'تم رفض المعاملة',
            isApproved: false,
          ));
        }
      },
    );
  }

  void _onUpdateTemplateFormValue(
    UpdateTemplateFormValue event,
    Emitter<TransactionDetailsState> emit,
  ) {
    if (state is TransactionDetailsLoaded) {
      final currentState = state as TransactionDetailsLoaded;
      final newTemplateFormValues =
          Map<String, dynamic>.from(currentState.templateFormValues);
      newTemplateFormValues[event.fieldId] = event.value;
      emit(currentState.copyWith(templateFormValues: newTemplateFormValues));
    }
  }
}
