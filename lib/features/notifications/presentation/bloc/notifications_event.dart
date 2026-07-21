import 'package:equatable/equatable.dart';

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

class MarkNotificationAsRead extends NotificationsEvent {
  final int notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}
