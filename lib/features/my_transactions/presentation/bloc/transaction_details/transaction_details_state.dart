abstract class TransactionDetailsState {}

class TransactionDetailsInitial extends TransactionDetailsState {}

class TransactionDetailsLoading extends TransactionDetailsState {}

class TransactionDetailsLoaded extends TransactionDetailsState {
  final Map<String, dynamic> taskData;
  final Map<String, dynamic> formValues;

  TransactionDetailsLoaded({
    required this.taskData,
    required this.formValues,
  });

  TransactionDetailsLoaded copyWith({
    Map<String, dynamic>? taskData,
    Map<String, dynamic>? formValues,
  }) {
    return TransactionDetailsLoaded(
      taskData: taskData ?? this.taskData,
      formValues: formValues ?? this.formValues,
    );
  }
}

class TransactionDetailsSubmitting extends TransactionDetailsState {
  final String? message;
  TransactionDetailsSubmitting({this.message});
}

class TransactionDetailsActionSuccess extends TransactionDetailsState {
  final String message;
  final bool shouldReloadList;

  TransactionDetailsActionSuccess(this.message, {this.shouldReloadList = false});
}

class TransactionDetailsFailure extends TransactionDetailsState {
  final String message;

  TransactionDetailsFailure(this.message);
}
