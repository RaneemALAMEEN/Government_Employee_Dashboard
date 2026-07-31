import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {
  final bool unreadOnly;

  const LoadNotifications({this.unreadOnly = false});

  @override
  List<Object?> get props => [unreadOnly];
}

class LoadMoreNotifications extends NotificationsEvent {
  const LoadMoreNotifications();
}

class ChangeNotificationFilter extends NotificationsEvent {
  final bool unreadOnly;

  const ChangeNotificationFilter({required this.unreadOnly});

  @override
  List<Object?> get props => [unreadOnly];
}

class RetryLoadMoreNotifications extends NotificationsEvent {
  const RetryLoadMoreNotifications();
}

class RetryNotifications extends NotificationsEvent {
  const RetryNotifications();
}

class NotificationsPopupOpened extends NotificationsEvent {
  const NotificationsPopupOpened();
}

class NotificationsPopupClosed extends NotificationsEvent {
  final bool preserveSession;

  const NotificationsPopupClosed({this.preserveSession = false});

  @override
  List<Object?> get props => [preserveSession];
}

class NotificationsPageOpened extends NotificationsEvent {
  const NotificationsPageOpened();
}

class NotificationsPageClosed extends NotificationsEvent {
  const NotificationsPageClosed();
}

class LoadMorePopupNotifications extends NotificationsEvent {
  const LoadMorePopupNotifications();
}

class NotificationBecameVisible extends NotificationsEvent {
  final int notificationId;

  const NotificationBecameVisible(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class FlushVisibleNotificationsRead extends NotificationsEvent {
  const FlushVisibleNotificationsRead();
}

class StartNotificationsMonitoring extends NotificationsEvent {
  const StartNotificationsMonitoring();
}

class StopNotificationsMonitoring extends NotificationsEvent {
  const StopNotificationsMonitoring();
}

class RefreshUnreadCount extends NotificationsEvent {
  final bool syncLatestNotification;

  const RefreshUnreadCount({this.syncLatestNotification = false});

  @override
  List<Object?> get props => [syncLatestNotification];
}

class NotificationReceived extends NotificationsEvent {
  final NotificationEntity notification;

  const NotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}

class MarkNotificationAsRead extends NotificationsEvent {
  final int notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class NotificationOpened extends NotificationsEvent {
  final int notificationId;

  const NotificationOpened({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
