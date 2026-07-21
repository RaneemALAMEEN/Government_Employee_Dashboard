import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/document_verification/data/models/document_verification_model.dart';
import 'package:government_employee_dashboard/features/document_verification/domain/entities/document_verification_entity.dart';
import 'package:government_employee_dashboard/features/document_verification/presentation/widgets/document_verification_widgets.dart';
import 'package:government_employee_dashboard/features/document_verification/presentation/widgets/transaction_history_renderer.dart';

void main() {
  test('parses the real response and sorts signers by signature order', () {
    final model = DocumentVerificationModel.fromJson(
      const {
        'data': {
          'applicant': {
            'first_name': 'أحمد',
            'last_name': 'علي',
            'father_name': 'محمد',
            'mother_name': 'فاطمة',
            'national_id': '01234567890',
          },
          'signers': [
            {'signature_order': 2, 'first_name': 'ثاني'},
            {'signature_order': 1, 'first_name': 'أول'},
          ],
          'transaction': {
            'id': 42,
            'status': 'completed',
            'request_date': '01/07/2026',
            'completed_at': '18/07/2026',
            'rejected_at': null,
          },
          'transaction_history': {'id_process': 'TX-2026-00042'},
          'final_document': {
            'available': true,
            'file_url': 'https://host/tx-42.pdf',
          },
        },
      },
    );

    expect(model.applicant.fullName, 'أحمد علي');
    expect(model.signers.map((item) => item.signatureOrder), [1, 2]);
    expect(model.transactionHistory.idProcess, 'TX-2026-00042');
    expect(model.finalDocument.available, isTrue);
  });

  test('uses safe defaults when signers and final document are absent', () {
    final model = DocumentVerificationModel.fromJson(const {'data': {}});

    expect(model.signers, isEmpty);
    expect(model.finalDocument.available, isFalse);
    expect(model.finalDocument.fileUrl, isEmpty);
    expect(model.transaction.id, 0);
  });

  test('masks national ids and translates supported statuses', () {
    expect(maskNationalId('01234567890'), '012******90');
    expect(maskNationalId('1234'), '****');
    expect(transactionStatusText('completed'), 'مكتملة');
    expect(transactionStatusText('in_progress'), 'قيد التنفيذ');
  });

  test('parses dynamic transaction history stages and actual widget values',
      () {
    final model = DocumentVerificationModel.fromJson(
      const {
        'data': {
          'transaction_history': {
            'id_process': 'TX-1',
            'process_name': 'معاملة اختبار',
            'priority': 2,
            'data': {
              'stages': [
                {
                  'stage_name': 'وثائق المواطن',
                  'decision': 'submit',
                  'completed_at': '2026-07-20T10:00:00.000Z',
                  'widgets': [
                    {
                      'widget_type': 'text_field',
                      'data': {'label': 'الاسم'},
                      'value': 'أحمد',
                    },
                    {
                      'widget_type': 'check_list',
                      'data': {'label': 'الخيارات'},
                      'value': ['أول', 'ثاني'],
                    },
                    {
                      'widget_type': 'file_picker',
                      'data': {'label': 'المرفقات'},
                      'value': [
                        {
                          'url': 'https://host/file.pdf',
                          'original_name': 'file.pdf',
                        },
                      ],
                    },
                  ],
                },
                {
                  'stage_name': 'GENERATE_PDF',
                  'generated_pdf_url': 'https://host/generated.pdf',
                },
                {'stage_name': 'مرحلة بدون حقول'},
              ],
            },
          },
        },
      },
    );

    final history = model.transactionHistory;
    expect(history.processName, 'معاملة اختبار');
    expect(history.priority, 2);
    expect(history.data.stages, hasLength(3));
    expect(history.data.stages.first.widgets, hasLength(3));
    expect(history.data.stages.first.widgets.first.value, 'أحمد');
    expect(history.data.stages[1].isDocumentGeneration, isTrue);
    expect(history.data.stages[1].displayName, 'توليد الوثيقة');
    expect(history.data.stages.last.widgets, isEmpty);
  });

  test('renders decisions, dates, booleans, nulls, and national ids safely',
      () {
    const boolWidget = TransactionHistoryWidgetEntity(
      widgetType: 'unknown',
      data: TransactionHistoryWidgetDataEntity(label: 'موافق'),
      value: true,
    );
    const emptyWidget = TransactionHistoryWidgetEntity(
      widgetType: 'text_field',
      data: TransactionHistoryWidgetDataEntity(label: 'ملاحظة'),
      value: null,
    );
    const nationalIdWidget = TransactionHistoryWidgetEntity(
      widgetType: 'text_field',
      data: TransactionHistoryWidgetDataEntity(label: 'الرقم الوطني'),
      value: '98765432132',
    );

    expect(decisionText('approve'), 'تمت الموافقة');
    expect(formatInputDate('1984-07-20'), '20/07/1984');
    expect(readableValue(boolWidget), 'نعم');
    expect(readableValue(emptyWidget), 'لم يتم إدخال قيمة');
    expect(readableValue(nationalIdWidget), '987******32');
  });
}
