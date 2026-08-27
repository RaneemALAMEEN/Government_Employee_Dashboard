import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:government_employee_dashboard/core/services/usb_signing_service.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_form_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/repositories/internal_transactions_repository.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/complete_signed_transaction_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/create_signing_challenge_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_document_template_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_stage_config_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/upload_transaction_file_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_bloc.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_event.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/widgets/dynamic_form_widget_renderer.dart';

void main() {
  test('validates int input type and captures invalid field IDs', () async {
    final repository = _FakeValidationRepository();
    final bloc = InternalTransactionFormBloc(
      getStageConfig: GetStageConfigUseCase(repository),
      getDocumentTemplate: GetDocumentTemplateUseCase(repository),
      uploadTransactionFile: UploadTransactionFileUseCase(repository),
      createSigningChallenge: CreateSigningChallengeUseCase(repository),
      completeSignedTransaction: CompleteSignedTransactionUseCase(repository),
      usbSigningService: UsbSigningService(),
    );

    bloc.add(const LoadInternalTransactionForm(1));
    await Future<void>.delayed(const Duration(milliseconds: 60));

    // Field is not required, but value is invalid (contains hyphen)
    bloc.add(const UpdateInternalTransactionFormValue(
      id: 'text_field28',
      value: '1234567890-',
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final validation = bloc.validateForm();
    expect(validation.isValid, isFalse);
    expect(validation.invalidFieldIds, contains('text_field28'));
    expect(validation.errorMessage, 'حقل الرقم التاميني يجب أن يحتوي على أرقام فقط');

    // Setting validation errors updates state
    bloc.add(SetInternalTransactionFormValidationErrors(
      invalidFieldIds: validation.invalidFieldIds,
      errorMessage: validation.errorMessage,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.invalidFieldIds, contains('text_field28'));
    expect(bloc.state.errorMessage, 'حقل الرقم التاميني يجب أن يحتوي على أرقام فقط');

    // Editing the field removes it from invalidFieldIds
    bloc.add(const UpdateInternalTransactionFormValue(
      id: 'text_field28',
      value: '1234567890',
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.invalidFieldIds, isNot(contains('text_field28')));
    expect(bloc.state.errorMessage, isNull);

    final validCheck = bloc.validateForm();
    expect(validCheck.isValid, isTrue);
    expect(validCheck.invalidFieldIds, isEmpty);

    await bloc.close();
  });

  testWidgets('text_field widget restricts typing according to input_type',
      (tester) async {
    dynamic enteredValue;

    const intWidget = DynamicWidgetEntity(
      widgetType: 'text_field',
      data: {
        'id': 'text_field17',
        'label': 'الرقم الذاتي',
        'widget_type': 'text_field',
        'input_type': 'int',
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicFormWidgetRenderer(
            widgetEntity: intWidget,
            value: null,
            onChanged: (val) => enteredValue = val,
          ),
        ),
      ),
    );

    // Try typing letters "ننننننننننن" into the int field
    await tester.enterText(find.byType(TextFormField), 'ننننننننننن');
    await tester.pump();
    expect(enteredValue, isNull);

    // Try typing valid digits
    await tester.enterText(find.byType(TextFormField), '123456');
    await tester.pump();
    expect(enteredValue, '123456');

    // Try typing mixed text and numbers
    await tester.enterText(find.byType(TextFormField), '123لبيلي456');
    await tester.pump();
    expect(enteredValue, '123456');
  });
}

class _FakeValidationRepository extends Fake
    implements InternalTransactionsRepository {
  @override
  Future<Either<Failure, DynamicFormEntity>> getStageConfig({
    required int processId,
  }) async =>
      const Right(DynamicFormEntity(
        transactionId: 1,
        formId: 'form-1',
        formName: 'معاملة تجريبية',
        note: '',
        decision: 'approve',
        requiresDigitalSignature: true,
        widgets: [
          DynamicWidgetEntity(
            widgetType: 'text_field',
            data: {
              'id': 'text_field28',
              'label': 'الرقم التاميني',
              'widget_type': 'text_field',
              'input_type': 'int',
              'is_required': false,
            },
          ),
        ],
      ));
}
