import 'package:equatable/equatable.dart';

import '../../domain/entities/process_definition_entity.dart';

const _unsetComplaintError = Object();

class DirectorateComplaintsState extends Equatable {
  final List<ProcessDefinitionEntity> items;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasNext;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;
  final String query;

  const DirectorateComplaintsState({
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.total = 0,
    this.hasNext = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.loadMoreError,
    this.query = '',
  });

  List<ProcessDefinitionEntity> get filteredItems {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items
        .where((item) => item.name.toLowerCase().contains(normalized))
        .toList(growable: false);
  }

  DirectorateComplaintsState copyWith({
    List<ProcessDefinitionEntity>? items,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasNext,
    bool? isInitialLoading,
    bool? isLoadingMore,
    Object? errorMessage = _unsetComplaintError,
    Object? loadMoreError = _unsetComplaintError,
    String? query,
  }) =>
      DirectorateComplaintsState(
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        total: total ?? this.total,
        hasNext: hasNext ?? this.hasNext,
        isInitialLoading: isInitialLoading ?? this.isInitialLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        errorMessage: identical(errorMessage, _unsetComplaintError)
            ? this.errorMessage
            : errorMessage as String?,
        loadMoreError: identical(loadMoreError, _unsetComplaintError)
            ? this.loadMoreError
            : loadMoreError as String?,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [
        items,
        currentPage,
        totalPages,
        total,
        hasNext,
        isInitialLoading,
        isLoadingMore,
        errorMessage,
        loadMoreError,
        query,
      ];
}
