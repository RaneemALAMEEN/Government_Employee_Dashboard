import 'self_card_entity.dart';

class SelfCardsPaginationEntity {
  final int limit;
  final String? cursor;
  final String? nextCursor;
  final bool hasNext;
  final bool hasPrev;

  const SelfCardsPaginationEntity({
    required this.limit,
    required this.cursor,
    required this.nextCursor,
    required this.hasNext,
    required this.hasPrev,
  });
}

class SelfCardsSearchResultEntity {
  final List<SelfCardEntity> items;
  final SelfCardsPaginationEntity pagination;

  const SelfCardsSearchResultEntity({
    required this.items,
    required this.pagination,
  });
}
