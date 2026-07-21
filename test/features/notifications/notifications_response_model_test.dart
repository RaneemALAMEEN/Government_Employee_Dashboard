import 'package:flutter_test/flutter_test.dart';
import 'package:government_employee_dashboard/features/notifications/data/models/notifications_response_model.dart';

void main() {
  test('parses notifications and cursor pagination from the real response', () {
    final model = NotificationsResponseModel.fromJson(
      const {
        'success': true,
        'data': {
          'items': [
            {
              'id': 42,
              'title': 'رفض معاملة',
              'message': 'نقص الوثائق',
              'type': 'transaction_rejected',
              'is_read': false,
              'created_at': '2026-07-17T10:00:00.000Z',
            },
          ],
          'pagination': {
            'limit': 10,
            'cursor': null,
            'next_cursor': 'next-token',
            'has_next': true,
            'has_prev': false,
          },
          'unread_count': 3,
        },
      },
      requestedLimit: 10,
    );

    expect(model.items, hasLength(1));
    expect(model.items.single.id, 42);
    expect(model.items.single.isRead, isFalse);
    expect(model.pagination.nextCursor, 'next-token');
    expect(model.pagination.hasNext, isTrue);
    expect(model.pagination.limit, 10);
    expect(model.unreadCount, 3);
  });

  test('uses defensive defaults for malformed optional values', () {
    final model = NotificationsResponseModel.fromJson(
      const {
        'data': {
          'items': [
            {'id': '7', 'is_read': 'true'},
          ],
          'pagination': <String, dynamic>{},
        },
      },
      requestedLimit: 10,
    );

    expect(model.items.single.id, 7);
    expect(model.items.single.isRead, isTrue);
    expect(model.items.single.title, isEmpty);
    expect(model.pagination.limit, 10);
    expect(model.pagination.hasNext, isFalse);
    expect(model.unreadCount, 0);
  });
}
