class StatisticsPaginationEntity {
  final int limit;
  final String? cursor;
  final String? nextCursor;
  final bool hasNext;
  final bool hasPrev;

  const StatisticsPaginationEntity({
    required this.limit,
    required this.cursor,
    required this.nextCursor,
    required this.hasNext,
    required this.hasPrev,
  });
}
