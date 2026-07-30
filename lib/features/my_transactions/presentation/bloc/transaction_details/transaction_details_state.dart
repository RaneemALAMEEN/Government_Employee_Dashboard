abstract class TransactionDetailsState {}

class TransactionDetailsInitial extends TransactionDetailsState {}

class TransactionDetailsLoading extends TransactionDetailsState {}

class TransactionDetailsLoaded extends TransactionDetailsState {
  final Map<String, dynamic> taskData;
  final Map<String, dynamic> formValues;
  final List<Map<String, dynamic>> loadedTemplates;
  final Map<String, dynamic> templateFormValues;
  final String? transactionId;

  TransactionDetailsLoaded({
    required this.taskData,
    required this.formValues,
    this.loadedTemplates = const [],
    this.templateFormValues = const {},
    this.transactionId,
  });

  TransactionDetailsLoaded copyWith({
    Map<String, dynamic>? taskData,
    Map<String, dynamic>? formValues,
    List<Map<String, dynamic>>? loadedTemplates,
    Map<String, dynamic>? templateFormValues,
    String? transactionId,
  }) {
    return TransactionDetailsLoaded(
      taskData: taskData ?? this.taskData,
      formValues: formValues ?? this.formValues,
      loadedTemplates: loadedTemplates ?? this.loadedTemplates,
      templateFormValues: templateFormValues ?? this.templateFormValues,
      transactionId: transactionId ?? this.transactionId,
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

  TransactionDetailsActionSuccess(this.message,
      {this.shouldReloadList = false});
}

class TransactionSignedSuccess extends TransactionDetailsState {
  final String taskId;
  final String transactionId;
  final String message;
  final bool isApproved;

  TransactionSignedSuccess({
    required this.taskId,
    required this.transactionId,
    required this.message,
    this.isApproved = true,
  });
}

class TransactionDetailsFailure extends TransactionDetailsState {
  final String message;

  TransactionDetailsFailure(this.message);
}

/// Emitted when a submit/sign action fails — shows a full error page.
class TransactionSubmitError extends TransactionDetailsState {
  final String taskId;
  final String errorCode;
  final String title;
  final String message;
  final List<String> suggestions;

  TransactionSubmitError({
    required this.taskId,
    required this.errorCode,
    required this.title,
    required this.message,
    this.suggestions = const [],
  });
}

