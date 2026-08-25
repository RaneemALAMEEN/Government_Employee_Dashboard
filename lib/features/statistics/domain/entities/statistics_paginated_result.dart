import 'statistics_pagination_entity.dart';

class StatisticsPaginatedResult<T> {
  final List<T> items;
  final StatisticsPaginationEntity pagination;

  const StatisticsPaginatedResult({
    required this.items,
    required this.pagination,
  });
}
