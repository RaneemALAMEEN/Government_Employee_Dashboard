import 'package:equatable/equatable.dart';

import '../../../domain/entities/document_template_entity.dart';
import '../../../domain/entities/dynamic_form_entity.dart';

class InternalTransactionFormState extends Equatable {
  final bool loading;
  final bool submitting;
  final String? submitStatusMessage;
  final String? errorMessage;
  final DynamicFormEntity? form;
  final DocumentTemplateEntity? template;
  final Map<String, dynamic> formValues;
  final Map<String, dynamic> templateValues;
  final Map<String, dynamic>? submittedTransaction;
  final int? assignmentOrgId;
  final int? assignmentDepartmentId;
  final int? assignmentRoleId;
  final String? assignmentError;
  final Set<String> invalidFieldIds;

  const InternalTransactionFormState({
    required this.loading,
    required this.submitting,
    this.submitStatusMessage,
    required this.formValues,
    required this.templateValues,
    this.errorMessage,
    this.form,
    this.template,
    this.submittedTransaction,
    this.assignmentOrgId,
    this.assignmentDepartmentId,
    this.assignmentRoleId,
    this.assignmentError,
    this.invalidFieldIds = const {},
  });

  factory InternalTransactionFormState.initial() {
    return const InternalTransactionFormState(
      loading: true,
      submitting: false,
      formValues: {},
      templateValues: {},
      assignmentOrgId: null,
      assignmentDepartmentId: null,
      assignmentRoleId: null,
      assignmentError: null,
      invalidFieldIds: {},
    );
  }

  InternalTransactionFormState copyWith({
    bool? loading,
    bool? submitting,
    String? submitStatusMessage,
    String? errorMessage,
    bool clearError = false,
    DynamicFormEntity? form,
    DocumentTemplateEntity? template,
    Map<String, dynamic>? formValues,
    Map<String, dynamic>? templateValues,
    Map<String, dynamic>? submittedTransaction,
    bool clearSubmittedTransaction = false,
    int? assignmentOrgId,
    int? assignmentDepartmentId,
    int? assignmentRoleId,
    String? assignmentError,
    bool clearAssignmentError = false,
    Set<String>? invalidFieldIds,
    bool clearInvalidFields = false,
  }) {
    return InternalTransactionFormState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      submitStatusMessage:
          submitting == false ? null : submitStatusMessage ?? this.submitStatusMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      form: form ?? this.form,
      template: template ?? this.template,
      formValues: formValues ?? this.formValues,
      templateValues: templateValues ?? this.templateValues,
      submittedTransaction: clearSubmittedTransaction
          ? null
          : submittedTransaction ?? this.submittedTransaction,
      assignmentOrgId: assignmentOrgId ?? this.assignmentOrgId,
      assignmentDepartmentId:
          assignmentDepartmentId ?? this.assignmentDepartmentId,
      assignmentRoleId: assignmentRoleId ?? this.assignmentRoleId,
      assignmentError: clearAssignmentError
          ? null
          : assignmentError ?? this.assignmentError,
      invalidFieldIds: clearInvalidFields
          ? const {}
          : invalidFieldIds ?? this.invalidFieldIds,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        submitting,
        submitStatusMessage,
        errorMessage,
        form,
        template,
        formValues,
        templateValues,
        submittedTransaction,
        assignmentOrgId,
        assignmentDepartmentId,
        assignmentRoleId,
        assignmentError,
        invalidFieldIds,
      ];
}