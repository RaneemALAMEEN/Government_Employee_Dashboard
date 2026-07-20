import 'package:equatable/equatable.dart';

import '../../domain/entities/process_definition_entity.dart';
import '../../domain/entities/transaction_type_entity.dart';

enum DirectorateView { types, definitions }

class DirectorateProcessState extends Equatable {
  final DirectorateView view;
  final bool isTypesLoading;
  final List<TransactionTypeEntity> types;
  final List<TransactionTypeEntity> filteredTypes;
  final String typesQuery;
  final int? selectedTypeId;
  final String? selectedTypeName;
  final String? errorMessage;

  final List<ProcessDefinitionEntity> items;
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasNext;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final String? loadMoreError;
  final String definitionsQuery;

  const DirectorateProcessState({
    this.view = DirectorateView.types,
    this.isTypesLoading = false,
    this.types = const [],
    this.filteredTypes = const [],
    this.typesQuery = '',
    this.selectedTypeId,
    this.selectedTypeName,
    this.errorMessage,
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.total = 0,
    this.hasNext = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.definitionsQuery = '',
  });

  /// Local-only filtering over pages that have already been loaded.
  List<ProcessDefinitionEntity> get filteredDefinitions {
    final query = definitionsQuery.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.code.toLowerCase().contains(query) ||
          item.approvalStatus.toLowerCase().contains(query) ||
          item.deploymentStatus.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  DirectorateProcessState copyWith({
    DirectorateView? view,
    bool? isTypesLoading,
    List<TransactionTypeEntity>? types,
    List<TransactionTypeEntity>? filteredTypes,
    String? typesQuery,
    int? selectedTypeId,
    String? selectedTypeName,
    String? errorMessage,
    List<ProcessDefinitionEntity>? items,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasNext,
    bool? isInitialLoading,
    bool? isLoadingMore,
    String? loadMoreError,
    String? definitionsQuery,
    bool clearError = false,
    bool clearLoadMoreError = false,
  }) =>
      DirectorateProcessState(
        view: view ?? this.view,
        isTypesLoading: isTypesLoading ?? this.isTypesLoading,
        types: types ?? this.types,
        filteredTypes: filteredTypes ?? this.filteredTypes,
        typesQuery: typesQuery ?? this.typesQuery,
        selectedTypeId: selectedTypeId ?? this.selectedTypeId,
        selectedTypeName: selectedTypeName ?? this.selectedTypeName,
        errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
        items: items ?? this.items,
        currentPage: currentPage ?? this.currentPage,
        totalPages: totalPages ?? this.totalPages,
        total: total ?? this.total,
        hasNext: hasNext ?? this.hasNext,
        isInitialLoading: isInitialLoading ?? this.isInitialLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError:
            clearLoadMoreError ? null : loadMoreError ?? this.loadMoreError,
        definitionsQuery: definitionsQuery ?? this.definitionsQuery,
      );

  @override
  List<Object?> get props => [
        view,
        isTypesLoading,
        types,
        filteredTypes,
        typesQuery,
        selectedTypeId,
        selectedTypeName,
        errorMessage,
        items,
        currentPage,
        totalPages,
        total,
        hasNext,
        isInitialLoading,
        isLoadingMore,
        loadMoreError,
        definitionsQuery,
      ];
}
