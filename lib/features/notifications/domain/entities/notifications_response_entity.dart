import 'package:equatable/equatable.dart';

import 'notification_entity.dart';
import 'notifications_pagination_entity.dart';

class NotificationsResponseEntity extends Equatable {
  final List<NotificationEntity> items;
  final NotificationsPaginationEntity pagination;
  final int unreadCount;

  const NotificationsResponseEntity({
    required this.items,
    required this.pagination,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [items, pagination, unreadCount];
}
