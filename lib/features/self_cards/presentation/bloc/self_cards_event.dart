import 'package:equatable/equatable.dart';

import '../../domain/entities/self_card_entity.dart';

enum SelfCardViewMode {
  search,
  recommendByTraining,
}

abstract class SelfCardsEvent extends Equatable {
  const SelfCardsEvent();

  @override
  List<Object?> get props => [];
}

class ChangeSelfCardViewModeEvent extends SelfCardsEvent {
  final SelfCardViewMode mode;

  const ChangeSelfCardViewModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SearchSelfCardsEvent extends SelfCardsEvent {
  final String query;
  final bool activeOnly;
  final String? cursor;
  final int limit;

  const SearchSelfCardsEvent({
    this.query = '',
    this.activeOnly = true,
    this.cursor,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, activeOnly, cursor, limit];
}

class RecommendByTrainingEvent extends SelfCardsEvent {
  final String title;
  final int limit;
  final String? publicEntity;

  const RecommendByTrainingEvent({
    required this.title,
    this.limit = 20,
    this.publicEntity,
  });

  @override
  List<Object?> get props => [title, limit, publicEntity];
}

class ClearTrainingRecommendationEvent extends SelfCardsEvent {
  const ClearTrainingRecommendationEvent();
}

class SelectSelfCardEvent extends SelfCardsEvent {
  final int selfCardId;

  const SelectSelfCardEvent(this.selfCardId);

  @override
  List<Object?> get props => [selfCardId];
}

class ClearSelectedSelfCardEvent extends SelfCardsEvent {
  const ClearSelectedSelfCardEvent();
}

class ExportSelfCardPdfEvent extends SelfCardsEvent {
  final SelfCardEntity selfCard;

  const ExportSelfCardPdfEvent(this.selfCard);

  @override
  List<Object?> get props => [selfCard];
}

class ClearPdfExportStatusEvent extends SelfCardsEvent {
  const ClearPdfExportStatusEvent();
}

