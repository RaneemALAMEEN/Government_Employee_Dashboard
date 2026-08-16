import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/organization_hierarchy/data/models/organization_search_models.dart';

void main() {
  test('parses the confirmed employee search response contract', () {
    final result = OrganizationSearchResponseModel.fromJson({
      'data': {
        'organization_id': 1,
        'scope': 'all',
        'q': 'سلمى',
        'departments': <dynamic>[],
        'roles': <dynamic>[],
        'employees': [
          {
            'kind': 'employee',
            'id': 9,
            'userName': 'salma.ad',
            'email': 'salma@gmail.com',
            'first_name': 'سلمى',
            'last_name': 'علي ديب',
            'father_name': 'محمد خير',
            'mother_name': 'غالية',
            'national_id': '98786757467',
            'is_active': true,
            'assignments': [
              {
                'assignment_id': 5,
                'odr_id': 3,
                'role': {
                  'id': 4,
                  'name': 'مدير مكتب المدير',
                  'code': 'DIRECTOR_OFFICE_MANAGER',
                },
                'department': {'id': 12, 'name': 'دائرة مكتب المدير'},
              }
            ],
          }
        ],
        'pagination': {
          'limit': 20,
          'departments_has_next': false,
          'roles_has_next': false,
          'employees_has_next': false,
        },
      }
    });

    expect(result.organizationId, 1);
    expect(result.employees, hasLength(1));
    expect(result.employees.single.id, 9);
    expect(result.employees.single.fullName, 'سلمى علي ديب');
    expect(result.employees.single.assignments.single.departmentId, 12);
    expect(result.employees.single.assignments.single.roleId, 4);
    expect(result.pagination.employeesHasNext, isFalse);
  });

  test('defensively skips department and role entries without id or name', () {
    final result = OrganizationSearchResponseModel.fromJson({
      'organization_id': 1,
      'scope': 'all',
      'q': 'x',
      'departments': [
        {'kind': 'department'},
        {'kind': 'department', 'id': 12, 'name': 'مكتب المدير'},
      ],
      'roles': [
        {'kind': 'role', 'id': 4},
      ],
      'employees': <dynamic>[],
      'pagination': <String, dynamic>{},
    });

    expect(result.departments, hasLength(1));
    expect(result.roles, isEmpty);
  });
}
