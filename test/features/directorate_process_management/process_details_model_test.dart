import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/directorate_process_management/data/models/process_details_model.dart';

void main() {
  test('parses process details response and nested assignments', () {
    const response = <String, dynamic>{
      'data': {
        'process': {
          'id': 1,
          'name': 'طلب إجازة سنوية',
          'code': 'LEAVE_ANNUAL_V1',
          'status': 'DEPLOYED',
          'version': 1,
          'is_active': true,
          'approval_status': 'APPROVED',
          'is_approved': true,
          'start_date': '2026-01-01T00:00:00.000Z',
          'end_date': null,
        },
        'stages': [
          {
            'id': 10,
            'name': 'تقديم الطلب',
            'code': 'SUBMIT',
            'type': 'USER_TASK',
            'auth_type': 'CITIZEN',
            'has_config': true,
            'config': {
              'form_name': 'بيانات مقدم الطلب',
              'requires_digital_signature': true,
              'widgets': [
                {
                  'widget_type': 'text_field',
                  'data': {
                    'label': 'رقم الهاتف',
                    'is_required': true,
                    'min_length': 10,
                    'max_length': 10,
                    'regex': r'^09\d{8}$',
                  },
                },
                {
                  'widget_type': 'dropdown',
                  'data': {
                    'label': 'الجنس',
                    'options': [
                      {'label': 'ذكر', 'value': 'male'},
                      {'label': 'أنثى', 'value': 'female'},
                    ],
                  },
                },
              ],
            },
            'has_assignments': true,
            'assignments': [
              {
                'organization_department_roles_id': 12,
                'role': {
                  'id': 12,
                  'name': 'موظف معاملات',
                  'is_active': true,
                  'organization': {'name': 'مديرية التربية'},
                  'department': {'name': 'دائرة الشؤون الإدارية'},
                },
              },
            ],
          },
        ],
        'validation': {'is_valid': true, 'errors': <dynamic>[]},
      },
    };
    final model = ProcessDetailsModel.fromJson(response);

    expect(model.process.id, 1);
    expect(model.process.startDate, DateTime.utc(2026));
    expect(model.stages, hasLength(1));
    expect(model.stages.single.config.widgets, hasLength(2));
    expect(
      model.stages.single.config.widgets.first.data.maxLength,
      10,
    );
    expect(
      model.stages.single.config.widgets.last.data.options.last.displayLabel,
      'أنثى',
    );
    expect(model.stages.single.config.requiresDigitalSignature, isTrue);
    expect(model.stages.single.assignments.single.role.name, 'موظف معاملات');
    expect(
      model.stages.single.assignments.single.role.department.name,
      'دائرة الشؤون الإدارية',
    );
    expect(model.validation.isValid, isTrue);
  });

  test('uses defensive defaults for incomplete response', () {
    final model =
        ProcessDetailsModel.fromJson(const {'data': <String, dynamic>{}});

    expect(model.isEmpty, isTrue);
    expect(model.stages, isEmpty);
    expect(model.validation.errors, isEmpty);
  });

  test('parses service task actions and document templates', () {
    final model = ProcessDetailsModel.fromJson(const {
      'data': {
        'process': {'id': 2, 'name': 'عملية آلية'},
        'stages': [
          {
            'id': 20,
            'type': 'SERVICE_TASK',
            'requires_digital_signature': true,
            'config': {
              'action': 'GENERATE_PDF',
              'template': [
                {'template_id': 2},
              ],
            },
          },
        ],
      },
    });

    final config = model.stages.single.config;
    expect(config.actions.single.code, 'GENERATE_PDF');
    expect(config.templates.single.templateId, 2);
    expect(config.requiresDigitalSignature, isTrue);
  });
}
