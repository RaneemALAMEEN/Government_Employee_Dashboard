import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/my_transactions_repository.dart';
import '../../../domain/usecases/get_task_details.dart';
import '../../../domain/usecases/pickup_task.dart';
import '../../../domain/usecases/release_task.dart';
import '../../../domain/usecases/submit_transaction.dart';
import 'transaction_details_event.dart';
import 'transaction_details_state.dart';

class TransactionDetailsBloc extends Bloc<TransactionDetailsEvent, TransactionDetailsState> {
  final GetTaskDetails getTaskDetails;
  final PickupTask pickupTask;
  final ReleaseTask releaseTask;
  final SubmitTransaction submitTransaction;
  final MyTransactionsRepository repository;

  TransactionDetailsBloc({
    required this.getTaskDetails,
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
    final result = await getTaskDetails(taskId: event.taskId);
    
    await result.fold(
      (failure) async => emit(TransactionDetailsFailure(failure.message)),
      (response) async {
        final taskData = response['data'] as Map<String, dynamic>? ?? {};
        
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
          
          final templateJson = config['template'] as List? ?? config['templates'] as List? ?? [];
          for (final item in templateJson) {
            final idStr = item is Map ? (item['template_id'] ?? item['id']) : item;
            final id = int.tryParse(idStr?.toString() ?? '') ?? 0;
            if (id > 0) templateIds.add(id);
          }
        }
        
        // Fetch templates
        final loadedTemplates = <Map<String, dynamic>>[];
        for (final templateId in templateIds) {
          final templateResult = await repository.getDocumentTemplate(templateId: templateId);
          templateResult.fold(
            (_) {}, // Silently fail on individual template fetch
            (templateResponse) {
              final templateData = templateResponse['data'] as Map<String, dynamic>? ?? templateResponse;
              loadedTemplates.add(templateData);
            },
          );
        }
        
        emit(TransactionDetailsLoaded(
          taskData: taskData,
          formValues: formValues,
          loadedTemplates: loadedTemplates,
        ));
      },
    );
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
        emit(TransactionDetailsActionSuccess('تم استلام المعاملة بنجاح — أصبحت الآن قيد التنفيذ', shouldReloadList: true));
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
        emit(TransactionDetailsActionSuccess('تم إلغاء استلام المعاملة وإرجاعها لحالة الانتظار', shouldReloadList: true));
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
      pin: event.pin,
      keysDirectoryPath: event.keysDirectoryPath,
      templateIds: event.templateIds,
      templateFormValues: event.templateFormValues,
      loadedTemplates: event.loadedTemplates,
    );

    result.fold(
      (failure) {
        emit(TransactionDetailsFailure(failure.message));
        if (currentState is TransactionDetailsLoaded) {
          emit(currentState);
        }
      },
      (_) {
        final successMsg = event.isApprove ? 'تم توقيع وإكمال المعاملة بنجاح' : 'تم رفض المعاملة بنجاح';
        emit(TransactionDetailsActionSuccess(successMsg, shouldReloadList: true));
        add(LoadTransactionDetails(event.taskId));
      },
    );
  }

  void _onUpdateTemplateFormValue(
    UpdateTemplateFormValue event,
    Emitter<TransactionDetailsState> emit,
  ) {
    if (state is TransactionDetailsLoaded) {
      final currentState = state as TransactionDetailsLoaded;
      final newTemplateFormValues = Map<String, dynamic>.from(currentState.templateFormValues);
      newTemplateFormValues[event.fieldId] = event.value;
      emit(currentState.copyWith(templateFormValues: newTemplateFormValues));
    }
  }
}
