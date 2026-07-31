import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/shared/layouts/side_menu.dart';

void main() {
  const routes = [
    '/dashboard',
    '/transactions',
    '/transactions/admin',
    '/statistics',
  ];

  test('keeps a parent sidebar route active on child pages', () {
    expect(
      findActiveSidebarRoute('/statistics/employees/9', routes),
      '/statistics',
    );
  });

  test('selects the longest route when sidebar routes overlap', () {
    expect(
      findActiveSidebarRoute('/transactions/admin/42', routes),
      '/transactions/admin',
    );
  });

  test('does not match routes that only share a text prefix', () {
    expect(findActiveSidebarRoute('/transactions-old', routes), isNull);
  });
}
