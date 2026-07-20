import 'package:equatable/equatable.dart';

class ProcessDefinitionsPaginationEntity extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const ProcessDefinitionsPaginationEntity({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  List<Object?> get props => [page, limit, total, totalPages, hasNext, hasPrev];
}
