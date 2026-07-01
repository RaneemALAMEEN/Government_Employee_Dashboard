import 'internal_process_entity.dart';

class InternalProcessesPageEntity {
  final List<InternalProcessEntity> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const InternalProcessesPageEntity({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}