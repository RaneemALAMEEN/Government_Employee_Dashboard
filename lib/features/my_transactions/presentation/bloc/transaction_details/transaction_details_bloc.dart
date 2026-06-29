import 'package:flutter_bloc/flutter_bloc.dart';

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

  TransactionDetailsBloc({
    required this.getTaskDetails,
    required this.pickupTask,
    required this.releaseTask,
    required this.submitTransaction,
  }) : super(TransactionDetailsInitial()) {
    on<LoadTransactionDetails>(_onLoadTransactionDetails);
    on<PickupTransactionEvent>(_onPickupTransaction);
    on<ReleaseTransactionEvent>(_onReleaseTransaction);
    on<SubmitTransactionDetailsEvent>(_onSubmitTransactionDetails);
  }

  Future<void> _onLoadTransactionDetails(
    LoadTransactionDetails event,
    Emitter<TransactionDetailsState> emit,
  ) async {
    emit(TransactionDetailsLoading());
    final result = await getTaskDetails(taskId: event.taskId);
    
    result.fold(
      (failure) => emit(TransactionDetailsFailure(failure.message)),
      (response) {
        final taskData = response['data'] as Map<String, dynamic>? ?? {};
        
        final formValues = <String, dynamic>{};
        final currentStage = taskData['currentStage'] as Map<String, dynamic>?;
        final config = currentStage?['config'] as Map<String, dynamic>?;
        if (config != null) {
          final widgets = config['widgets'] as List? ?? [];
          for (final widgetJson in widgets) {
            final w = widgetJson as Map<String, dynamic>;
            final wData = w['data'] as Map<String, dynamic>? ?? {};
            final id = wData['id']?.toString() ?? '';
            formValues[id] = w['value'];
          }
        }
        
        emit(TransactionDetailsLoaded(
          taskData: taskData,
          formValues: formValues,
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
}
