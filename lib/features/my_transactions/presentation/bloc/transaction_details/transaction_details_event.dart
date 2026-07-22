import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';

abstract class TransactionDetailsEvent {}

class LoadTransactionDetails extends TransactionDetailsEvent {
  final String taskId;
  final String? status;

  LoadTransactionDetails(this.taskId, {this.status});

  List<Object?> get props => [taskId, status];
}

class PickupTransactionEvent extends TransactionDetailsEvent {
  final String taskId;
  PickupTransactionEvent(this.taskId);
}

class ReleaseTransactionEvent extends TransactionDetailsEvent {
  final String taskId;
  ReleaseTransactionEvent(this.taskId);
}

class UpdateTemplateFormValue extends TransactionDetailsEvent {
  final String fieldId;
  final dynamic value;

  UpdateTemplateFormValue(this.fieldId, this.value);
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
  final List<int> templateIds;
  final List<Map<String, dynamic>> loadedTemplates;
  final Map<String, dynamic> templateFormValues;
  final int? expectedVersion;

  SubmitTransactionDetailsEvent({
    required this.taskId,
    required this.widgets,
    required this.formValues,
    required this.formId,
    required this.formName,
    required this.isApprove,
    this.pin,
    this.keysDirectoryPath,
    this.templateIds = const [],
    this.loadedTemplates = const [],
    this.templateFormValues = const {},
    this.expectedVersion,
  });
}
