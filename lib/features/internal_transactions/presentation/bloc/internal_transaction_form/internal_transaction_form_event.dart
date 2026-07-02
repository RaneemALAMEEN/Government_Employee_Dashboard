import 'package:equatable/equatable.dart';

abstract class InternalTransactionFormEvent extends Equatable {
  const InternalTransactionFormEvent();

  @override
  List<Object?> get props => [];
}

class LoadInternalTransactionForm extends InternalTransactionFormEvent {
  final int processId;

  const LoadInternalTransactionForm(this.processId);

  @override
  List<Object?> get props => [processId];
}

class UpdateInternalTransactionFormValue
    extends InternalTransactionFormEvent {
  final String id;
  final dynamic value;

  const UpdateInternalTransactionFormValue({
    required this.id,
    required this.value,
  });

  @override
  List<Object?> get props => [id, value];
}

class UpdateInternalTransactionTemplateValue
    extends InternalTransactionFormEvent {
  final String id;
  final dynamic value;

  const UpdateInternalTransactionTemplateValue({
    required this.id,
    required this.value,
  });

  @override
  List<Object?> get props => [id, value];
}

class SubmitInternalTransactionForm extends InternalTransactionFormEvent {
  final int processId;
  final String keysDirectoryPath;
  final String pin;

  const SubmitInternalTransactionForm({
    required this.processId,
    required this.keysDirectoryPath,
    required this.pin,
  });

  @override
  List<Object?> get props => [processId, keysDirectoryPath, pin];
}

class ResetInternalTransactionForm extends InternalTransactionFormEvent {
  const ResetInternalTransactionForm();
}