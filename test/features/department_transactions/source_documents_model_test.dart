import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/department_transactions/data/models/source_documents_model.dart';

void main() {
  group('SourceDocumentsModel Test', () {
    test('parses json with name, generated_pdf_path, and document_signatures correctly', () {
      final jsonResponse = {
        "success": true,
        "status_code": 200,
        "message": "تم جلب مستندات المعاملة بنجاح",
        "data": {
          "transaction_id": 12,
          "status": "completed",
          "document_instances": [
            {
              "id": 101,
              "name": "شهادة قيد مدرسي",
              "document_template_id": 5,
              "generated_pdf_path": "uploads/generated/tx-12/instance-101.pdf",
              "file_url": "http://localhost:4000/uploads/generated/tx-12/instance-101.pdf",
              "status": "signed",
              "content_hash": "a3f1c9e8b2d4...",
              "created_at": "2026-08-20T10:15:00.000Z"
            },
            {
              "id": 102,
              "name": "قرار إداري",
              "document_template_id": 8,
              "generated_pdf_path": "uploads/generated/tx-12/instance-102.pdf",
              "file_url": "http://localhost:4000/uploads/generated/tx-12/instance-102.pdf",
              "status": "generated",
              "content_hash": "b7e2d1a0c5f9...",
              "created_at": "2026-08-20T10:20:00.000Z"
            }
          ],
          "document_signatures": [
            {
              "id": 201,
              "name": "هوية شخصية",
              "type_doc_id": 3,
              "type_doc_name": "بطاقة شخصية",
              "file_path": "uploads/user-files/tx-12/id-card.pdf",
              "file_url": "http://localhost:4000/uploads/user-files/tx-12/id-card.pdf",
              "created_at": "2026-08-19T14:02:00.000Z"
            },
            {
              "id": 202,
              "name": "صورة شخصية",
              "type_doc_id": 7,
              "type_doc_name": "صورة",
              "file_path": "uploads/user-files/tx-12/photo.jpg",
              "file_url": "http://localhost:4000/uploads/user-files/tx-12/photo.jpg",
              "created_at": "2026-08-19T14:05:00.000Z"
            }
          ]
        }
      };

      final model = SourceDocumentsModel.fromJson(jsonResponse);

      expect(model.transactionId, 12);
      expect(model.status, 'completed');
      expect(model.documentInstances.length, 2);
      expect(model.documentSignatures.length, 2);

      // Verify instances
      expect(model.documentInstances[0].name, 'شهادة قيد مدرسي');
      expect(model.documentInstances[0].displayName, 'شهادة قيد مدرسي');
      expect(model.documentInstances[0].filePath, 'uploads/generated/tx-12/instance-101.pdf');
      expect(model.documentInstances[0].isInstance, true);

      expect(model.documentInstances[1].name, 'قرار إداري');
      expect(model.documentInstances[1].displayName, 'قرار إداري');
      expect(model.documentInstances[1].filePath, 'uploads/generated/tx-12/instance-102.pdf');

      // Verify signatures
      expect(model.documentSignatures[0].name, 'هوية شخصية');
      expect(model.documentSignatures[0].typeDocName, 'بطاقة شخصية');
      expect(model.documentSignatures[0].displayName, 'هوية شخصية');
      expect(model.documentSignatures[0].filePath, 'uploads/user-files/tx-12/id-card.pdf');
      expect(model.documentSignatures[0].isInstance, false);

      expect(model.documentSignatures[1].name, 'صورة شخصية');
      expect(model.documentSignatures[1].typeDocName, 'صورة');
      expect(model.documentSignatures[1].displayName, 'صورة شخصية');
      expect(model.documentSignatures[1].filePath, 'uploads/user-files/tx-12/photo.jpg');
    });
  });
}
