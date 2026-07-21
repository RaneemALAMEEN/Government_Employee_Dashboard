import 'package:equatable/equatable.dart';

class NotificationsPaginationEntity extends Equatable {
  final int limit;
  final String? cursor;
  final String? nextCursor;
  final bool hasNext;
  final bool hasPrev;

  const NotificationsPaginationEntity({
    required this.limit,
    required this.cursor,
    required this.nextCursor,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  List<Object?> get props => [limit, cursor, nextCursor, hasNext, hasPrev];
}
