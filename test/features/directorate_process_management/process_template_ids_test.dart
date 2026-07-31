import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/directorate_process_management/data/models/process_details_model.dart';

void main() {
  test('extracts unique template ids from templates and GENERATE_PDF actions',
      () {
    final model = ProcessDetailsModel.fromJson(const {
      'data': {
        'process': {'id': 1, 'name': 'إجازة مع راتب'},
        'stages': [
          {
            'id': 10,
            'config': {
              'template': [
                {'template_id': 5},
              ],
              'actions': [
                {
                  'name': 'GENERATE_PDF',
                  'payload': {'template_id': 5},
                },
                {
                  'name': 'GENERATE_PDF',
                  'payload': {'template_id': 7},
                },
                {
                  'name': 'SEND_NOTIFICATION',
                  'payload': {'template_id': 9},
                },
              ],
            },
          },
        ],
        'validation': {'is_valid': true, 'errors': []},
      },
    });

    expect(model.stages.single.config.templateIds, {5, 7});
  });
}
