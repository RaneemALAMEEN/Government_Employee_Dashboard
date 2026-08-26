import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:government_employee_dashboard/core/services/usb_signing_service.dart';
import 'package:government_employee_dashboard/features/internal_transactions/data/models/self_card_model.dart';
import 'package:government_employee_dashboard/features/internal_transactions/data/models/self_cards_search_result_model.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/self_card_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_widget_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/dynamic_form_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/entities/self_cards_search_result_entity.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/repositories/internal_transactions_repository.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_self_card_details_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/complete_signed_transaction_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/create_signing_challenge_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_document_template_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/get_stage_config_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/search_self_cards_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/domain/usecases/upload_transaction_file_usecase.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/employee_picker/employee_picker_bloc.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/employee_picker/employee_picker_event.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/employee_picker/employee_picker_state.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_bloc.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_event.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/widgets/employee_picker_widget.dart';

void main() {
  test('parses the confirmed search and details schemas', () {
    final search = SelfCardsSearchResultModel.fromJson({
      'data': {
        'items': [
          {
            'id': 42,
            'user_id': 15,
            'organization_id': 3,
            'self_number': 'EMP-42',
            'national_id': '01234567890',
            'full_name': 'موظف تجريبي',
            'father_name': 'الأب',
            'mother_name': 'الأم',
            'is_active': true,
          }
        ],
        'pagination': {
          'limit': 20,
          'cursor': null,
          'next_cursor': 'next',
          'has_next': true,
          'has_prev': false,
        }
      }
    }, requestedLimit: 20);

    expect(search.items.single.id, 42);
    expect(search.pagination.nextCursor, 'next');
    expect(search.pagination.hasNext, isTrue);

    final details = SelfCardDetailsModel.fromJson({
      'id': 42,
      'full_name': 'موظف تجريبي',
      'is_active': true,
      'created_at': '2026-08-25T10:00:00Z',
      'updated_at': '2026-08-25T11:00:00Z',
      'training_courses': [
        {'name': 'دورة'}
      ],
      'employment_statuses': [],
      'irregular_absences': [],
      'leaves': [],
      'rewards': [],
      'sanctions': [],
    });

    expect(details.trainingCourses.single['name'], 'دورة');
    expect(details.createdAt, '2026-08-25T10:00:00Z');
  });

  test('searches, paginates without duplicates, and caches details', () async {
    final repository = _FakeInternalTransactionsRepository();
    final bloc = EmployeePickerBloc(
      searchSelfCards: SearchSelfCardsUseCase(repository),
      getSelfCardDetails: GetSelfCardDetailsUseCase(repository),
    );

    bloc.add(const EmployeePickerOpened());
    await _waitForRequests();
    expect(bloc.state.items.map((item) => item.id), [1]);
    expect(bloc.state.hasNext, isTrue);

    bloc
      ..add(const EmployeePickerLoadMore())
      ..add(const EmployeePickerLoadMore());
    await _waitForRequests();
    expect(bloc.state.items.map((item) => item.id), [1, 2]);
    expect(repository.loadMoreCalls, 1);

    bloc.add(EmployeePickerSelected(bloc.state.items.first));
    await _waitForRequests();
    expect(bloc.state.detailsStatus, SelfCardDetailsStatus.success);
    expect(repository.detailsCalls, 1);

    bloc.add(const EmployeePickerSelectionCleared());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(EmployeePickerSelected(bloc.state.items.first));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(repository.detailsCalls, 1);

    bloc.add(const EmployeePickerQueryChanged('xx'));
    await Future<void>.delayed(const Duration(milliseconds: 520));
    await _waitForRequests();
    expect(bloc.state.searchStatus, SelfCardSearchStatus.empty);

    bloc.add(const EmployeePickerQueryChanged('fail'));
    await Future<void>.delayed(const Duration(milliseconds: 520));
    await _waitForRequests();
    expect(bloc.state.searchStatus, SelfCardSearchStatus.failure);
    bloc.add(const EmployeePickerRetrySearch());
    await _waitForRequests();
    expect(bloc.state.searchStatus, SelfCardSearchStatus.success);

    await bloc.close();
  });

  testWidgets('opens, searches, selects, previews, and changes selection',
      (tester) async {
    await getIt.reset();
    final repository = _FakeInternalTransactionsRepository();
    getIt.registerFactory<EmployeePickerBloc>(
      () => EmployeePickerBloc(
        searchSelfCards: SearchSelfCardsUseCase(repository),
        getSelfCardDetails: GetSelfCardDetailsUseCase(repository),
      ),
    );
    dynamic selectedValue;
    const config = DynamicWidgetEntity(
      widgetType: 'employee_picker',
      data: {
        'id': 'chosen_card',
        'label': 'البطاقة الذاتية',
        'is_required': true,
        'options_source': 'self_cards_search',
      },
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: EmployeePickerWidget(
          widgetEntity: config,
          value: selectedValue,
          onChanged: (value) => selectedValue = value,
        ),
      ),
    ));

    await tester.tap(find.text('اختيار بطاقة ذاتية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('الموظف الأول'), findsOneWidget);

    await tester.tap(find.text('الموظف الأول'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(selectedValue, 1);
    expect(find.text('معاينة البطاقة'), findsOneWidget);

    await tester.tap(find.text('تغيير الاختيار'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(find.byType(TextField), 'xx');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('لا توجد نتائج مطابقة'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await getIt.reset();
  });

  test('required employee picker uses the dynamic data id for validation',
      () async {
    final repository = _FakeInternalTransactionsRepository();
    final bloc = InternalTransactionFormBloc(
      getStageConfig: GetStageConfigUseCase(repository),
      getDocumentTemplate: GetDocumentTemplateUseCase(repository),
      uploadTransactionFile: UploadTransactionFileUseCase(repository),
      createSigningChallenge: CreateSigningChallengeUseCase(repository),
      completeSignedTransaction: CompleteSignedTransactionUseCase(repository),
      usbSigningService: UsbSigningService(),
    );

    bloc.add(const LoadInternalTransactionForm(1));
    await _waitForRequests();
    expect(bloc.validateCurrentForm(), 'يرجى تعبئة حقل: البطاقة الذاتية');

    bloc.add(const UpdateInternalTransactionFormValue(
      id: 'chosen_card',
      value: 42,
    ));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.formValues['chosen_card'], 42);
    expect(bloc.validateCurrentForm(), isNull);
    await bloc.close();
  });
}

Future<void> _waitForRequests() =>
    Future<void>.delayed(const Duration(milliseconds: 80));

class _FakeInternalTransactionsRepository extends Fake
    implements InternalTransactionsRepository {
  int loadMoreCalls = 0;
  int detailsCalls = 0;
  int failedQueryCalls = 0;

  final first = const SelfCardModel(
    id: 1,
    userId: 10,
    organizationId: 1,
    selfNumber: 'EMP-1',
    nationalId: '00000000001',
    fullName: 'الموظف الأول',
    fatherName: '',
    motherName: '',
    isActive: true,
  );
  final second = const SelfCardModel(
    id: 2,
    userId: 11,
    organizationId: 1,
    selfNumber: 'EMP-2',
    nationalId: '00000000002',
    fullName: 'الموظف الثاني',
    fatherName: '',
    motherName: '',
    isActive: true,
  );

  @override
  Future<Either<Failure, DynamicFormEntity>> getStageConfig({
    required int processId,
  }) async =>
      const Right(DynamicFormEntity(
        transactionId: 1,
        formId: 'form-1',
        formName: 'اختبار',
        note: '',
        decision: 'approve',
        requiresDigitalSignature: true,
        widgets: [
          DynamicWidgetEntity(
            widgetType: 'employee_picker',
            data: {
              'id': 'chosen_card',
              'label': 'البطاقة الذاتية',
              'is_required': true,
              'options_source': 'self_cards_search',
            },
          ),
        ],
      ));

  @override
  Future<Either<Failure, SelfCardsSearchResultEntity>> searchSelfCards({
    String? query,
    String? cursor,
    required int limit,
    required bool activeOnly,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 25));
    if (query == 'fail' && failedQueryCalls++ == 0) {
      return const Left(ServerFailure('فشل بحث تجريبي'));
    }
    if (query == 'xx') {
      return const Right(SelfCardsSearchResultEntity(
        items: [],
        pagination: SelfCardsPaginationEntity(
          limit: 20,
          cursor: null,
          nextCursor: null,
          hasNext: false,
          hasPrev: false,
        ),
      ));
    }
    if (cursor != null) {
      loadMoreCalls++;
      return Right(SelfCardsSearchResultEntity(
        items: [first, second],
        pagination: const SelfCardsPaginationEntity(
          limit: 20,
          cursor: 'cursor-1',
          nextCursor: null,
          hasNext: false,
          hasPrev: true,
        ),
      ));
    }
    return Right(SelfCardsSearchResultEntity(
      items: [first],
      pagination: const SelfCardsPaginationEntity(
        limit: 20,
        cursor: null,
        nextCursor: 'cursor-1',
        hasNext: true,
        hasPrev: false,
      ),
    ));
  }

  @override
  Future<Either<Failure, SelfCardDetailsEntity>> getSelfCardDetails({
    required int id,
  }) async {
    detailsCalls++;
    return Right(SelfCardDetailsModel.fromJson({
      'id': id,
      'full_name': 'الموظف الأول',
      'is_active': true,
      'training_courses': [],
      'employment_statuses': [],
      'irregular_absences': [],
      'leaves': [],
      'rewards': [],
      'sanctions': [],
    }));
  }
}
