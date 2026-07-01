import 'package:equatable/equatable.dart';

import '../../../domain/entities/internal_category_entity.dart';
import '../../../domain/entities/internal_process_entity.dart';

class CreateInternalTransactionState extends Equatable {
  final List<InternalCategoryEntity> categories;
  final List<InternalProcessEntity> processes;
  final int selectedCategoryId;
  final String searchQuery;
  final bool loadingCategories;
  final bool loadingProcesses;
  final String? errorMessage;

  const CreateInternalTransactionState({
    required this.categories,
    required this.processes,
    required this.selectedCategoryId,
    required this.searchQuery,
    required this.loadingCategories,
    required this.loadingProcesses,
    this.errorMessage,
  });

  factory CreateInternalTransactionState.initial() {
    return const CreateInternalTransactionState(
      categories: [],
      processes: [],
      selectedCategoryId: -1,
      searchQuery: '',
      loadingCategories: true,
      loadingProcesses: false,
    );
  }

  List<InternalProcessEntity> get filteredProcesses {
    final query = searchQuery.trim();

    if (query.isEmpty) return processes;

    return processes.where((item) {
      return item.name.contains(query) || item.code.contains(query);
    }).toList();
  }

  CreateInternalTransactionState copyWith({
    List<InternalCategoryEntity>? categories,
    List<InternalProcessEntity>? processes,
    int? selectedCategoryId,
    String? searchQuery,
    bool? loadingCategories,
    bool? loadingProcesses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateInternalTransactionState(
      categories: categories ?? this.categories,
      processes: processes ?? this.processes,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      loadingProcesses: loadingProcesses ?? this.loadingProcesses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        processes,
        selectedCategoryId,
        searchQuery,
        loadingCategories,
        loadingProcesses,
        errorMessage,
      ];
}