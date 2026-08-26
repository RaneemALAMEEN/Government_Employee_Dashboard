import 'package:equatable/equatable.dart';

import '../../../domain/entities/self_card_entity.dart';

enum SelfCardSearchStatus {
  initial,
  initialLoading,
  success,
  empty,
  failure,
}

enum SelfCardDetailsStatus {
  initial,
  loading,
  success,
  failure,
}

class EmployeePickerState extends Equatable {
  final String query;
  final List<SelfCardEntity> items;
  final SelfCardSearchStatus searchStatus;
  final bool searchLoadingMore;
  final String? searchError;
  final String? loadMoreError;
  final bool hasNext;
  final String? nextCursor;
  final SelfCardEntity? selectedCard;
  final SelfCardDetailsEntity? selectedDetails;
  final SelfCardDetailsStatus detailsStatus;
  final String? detailsError;

  const EmployeePickerState({
    this.query = '',
    this.items = const [],
    this.searchStatus = SelfCardSearchStatus.initial,
    this.searchLoadingMore = false,
    this.searchError,
    this.loadMoreError,
    this.hasNext = false,
    this.nextCursor,
    this.selectedCard,
    this.selectedDetails,
    this.detailsStatus = SelfCardDetailsStatus.initial,
    this.detailsError,
  });

  EmployeePickerState copyWith({
    String? query,
    List<SelfCardEntity>? items,
    SelfCardSearchStatus? searchStatus,
    bool? searchLoadingMore,
    String? searchError,
    String? loadMoreError,
    bool? hasNext,
    String? nextCursor,
    SelfCardEntity? selectedCard,
    SelfCardDetailsEntity? selectedDetails,
    SelfCardDetailsStatus? detailsStatus,
    String? detailsError,
    bool clearSearchError = false,
    bool clearLoadMoreError = false,
    bool clearNextCursor = false,
    bool clearSelection = false,
    bool clearSelectedDetails = false,
    bool clearDetailsError = false,
  }) =>
      EmployeePickerState(
        query: query ?? this.query,
        items: items ?? this.items,
        searchStatus: searchStatus ?? this.searchStatus,
        searchLoadingMore: searchLoadingMore ?? this.searchLoadingMore,
        searchError: clearSearchError ? null : searchError ?? this.searchError,
        loadMoreError:
            clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
        hasNext: hasNext ?? this.hasNext,
        nextCursor: clearNextCursor ? null : nextCursor ?? this.nextCursor,
        selectedCard: clearSelection ? null : selectedCard ?? this.selectedCard,
        selectedDetails: clearSelection || clearSelectedDetails
            ? null
            : selectedDetails ?? this.selectedDetails,
        detailsStatus: detailsStatus ??
            (clearSelection
                ? SelfCardDetailsStatus.initial
                : this.detailsStatus),
        detailsError: clearSelection || clearDetailsError
            ? null
            : detailsError ?? this.detailsError,
      );

  bool get searchInitialLoading =>
      searchStatus == SelfCardSearchStatus.initialLoading;

  @override
  List<Object?> get props => [
        query,
        items,
        searchStatus,
        searchLoadingMore,
        searchError,
        loadMoreError,
        hasNext,
        nextCursor,
        selectedCard,
        selectedDetails,
        detailsStatus,
        detailsError,
      ];
}
