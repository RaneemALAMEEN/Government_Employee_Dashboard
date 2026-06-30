import 'package:equatable/equatable.dart';

import '../../../domain/entities/dynamic_form_entity.dart';

class InternalTransactionFormState extends Equatable {
  final bool loading;
  final bool submitting;
  final String? errorMessage;
  final DynamicFormEntity? form;
  final Map<String, dynamic> formValues;
  final Map<String, dynamic>? submittedTransaction;

  const InternalTransactionFormState({
    required this.loading,
    required this.submitting,
    required this.formValues,
    this.errorMessage,
    this.form,
    this.submittedTransaction,
  });

  factory InternalTransactionFormState.initial() {
    return const InternalTransactionFormState(
      loading: true,
      submitting: false,
      formValues: {},
    );
  }

  InternalTransactionFormState copyWith({
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
    DynamicFormEntity? form,
    Map<String, dynamic>? formValues,
    Map<String, dynamic>? submittedTransaction,
    bool clearSubmittedTransaction = false,
  }) {
    return InternalTransactionFormState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      form: form ?? this.form,
      formValues: formValues ?? this.formValues,
      submittedTransaction: clearSubmittedTransaction
          ? null
          : submittedTransaction ?? this.submittedTransaction,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        errorMessage,
        form,
        formValues,
        submittedTransaction,
      ];
}