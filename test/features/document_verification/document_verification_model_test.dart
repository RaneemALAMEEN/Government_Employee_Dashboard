import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/document_verification/data/models/document_verification_model.dart';
import 'package:government_employee_dashboard/features/document_verification/presentation/widgets/document_verification_widgets.dart';

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
}
