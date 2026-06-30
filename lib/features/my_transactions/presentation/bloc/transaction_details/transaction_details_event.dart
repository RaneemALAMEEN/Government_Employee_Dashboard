
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';

abstract class TransactionDetailsEvent {}

class LoadTransactionDetails extends TransactionDetailsEvent {
  final String taskId;
  LoadTransactionDetails(this.taskId);
}

class PickupTransactionEvent extends TransactionDetailsEvent {
  final String taskId;
  PickupTransactionEvent(this.taskId);
}

class ReleaseTransactionEvent extends TransactionDetailsEvent {
  final String taskId;
  ReleaseTransactionEvent(this.taskId);
}

class SubmitTransactionDetailsEvent extends TransactionDetailsEvent {
  final String taskId;
  final List<DynamicWidgetEntity> widgets;
  final Map<String, dynamic> formValues;
  final String formId;
  final String formName;
  final bool isApprove;
  final String? pin;
  final String? keysDirectoryPath;

  SubmitTransactionDetailsEvent({
    required this.taskId,
    required this.widgets,
    required this.formValues,
    required this.formId,
    required this.formName,
    required this.isApprove,
    this.pin,
    this.keysDirectoryPath,
  });
}
