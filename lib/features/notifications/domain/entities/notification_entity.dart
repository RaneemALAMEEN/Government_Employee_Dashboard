import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead, DateTime? readAt}) =>
      NotificationEntity(
        id: id,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        isRead,
        readAt,
        createdAt,
      ];
}
