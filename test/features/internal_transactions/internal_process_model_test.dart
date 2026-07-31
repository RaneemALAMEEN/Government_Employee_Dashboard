import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/internal_transactions/data/models/internal_process_model.dart';

void main() {
  group('InternalProcessModel stage count', () {
    test('parses a three-stage process', () {
      final model = InternalProcessModel.fromJson({
        'process_id': 1,
        'name': 'توكيل عام',
        'code': 'POA',
        'priority': 1,
        'stages_count': 3,
      });

      expect(model.stageCount, 3);
    });

    test('parses a five-stage process without using a fallback', () {
      final model = InternalProcessModel.fromJson({
        'process_id': 2,
        'name': 'إجازة سنوية',
        'code': 'LEAVE',
        'priority': 1,
        'total_stages': 5,
      });

      expect(model.stageCount, 5);
    });

    test('keeps stage count null when the list response omits it', () {
      final model = InternalProcessModel.fromJson({
        'process_id': 3,
        'name': 'معاملة بلا عداد',
        'code': 'UNKNOWN',
        'priority': 1,
      });

      expect(model.stageCount, isNull);
    });
  });
}
