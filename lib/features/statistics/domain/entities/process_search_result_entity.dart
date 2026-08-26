import 'package:equatable/equatable.dart';

class ProcessSearchResultEntity extends Equatable {
  final List<ProcessSearchItemEntity> items;
  final ProcessSearchPaginationEntity pagination;

  const ProcessSearchResultEntity({
    required this.items,
    required this.pagination,
  });

  @override
  List<Object?> get props => [items, pagination];
}

class ProcessSearchItemEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String? camundaProcessKey;
  final int priority;
  final bool isActive;
  final String approvalStatus;
  final bool isComplaint;
  final int? typeTransId;
  final String typeTransName;
  final int organizationId;
  final String organizationName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProcessSearchItemEntity({
    required this.id,
    required this.name,
    required this.code,
    this.camundaProcessKey,
    required this.priority,
    required this.isActive,
    required this.approvalStatus,
    required this.isComplaint,
    this.typeTransId,
    required this.typeTransName,
    required this.organizationId,
    required this.organizationName,
    this.createdAt,
    this.updatedAt,
  });

  String get priorityLabel {
    return switch (priority) {
      1 => 'منخفضة',
      2 => 'متوسطة',
      3 => 'عالية',
      4 => 'حرجة / طارئة',
      _ => 'أولوية $priority',
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        camundaProcessKey,
        priority,
        isActive,
        approvalStatus,
        isComplaint,
        typeTransId,
        typeTransName,
        organizationId,
        organizationName,
        createdAt,
        updatedAt,
      ];
}

class ProcessSearchPaginationEntity extends Equatable {
  final int limit;
  final String? cursor;
  final String? nextCursor;
  final bool hasNext;
  final bool hasPrev;

  const ProcessSearchPaginationEntity({
    required this.limit,
    this.cursor,
    this.nextCursor,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  List<Object?> get props => [limit, cursor, nextCursor, hasNext, hasPrev];
}
