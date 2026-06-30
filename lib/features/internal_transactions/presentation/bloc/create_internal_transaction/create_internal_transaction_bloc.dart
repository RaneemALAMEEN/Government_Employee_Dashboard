import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_internal_categories_usecase.dart';
import '../../../domain/usecases/get_processes_by_category_usecase.dart';
import 'create_internal_transaction_event.dart';
import 'create_internal_transaction_state.dart';

class CreateInternalTransactionBloc extends Bloc<
    CreateInternalTransactionEvent, CreateInternalTransactionState> {
  final GetInternalCategoriesUseCase getInternalCategories;
  final GetProcessesByCategoryUseCase getProcessesByCategory;

  static const int _page = 1;
  static const int _limit = 6;

  CreateInternalTransactionBloc({
    required this.getInternalCategories,
    required this.getProcessesByCategory,
  }) : super(CreateInternalTransactionState.initial()) {
    on<LoadCreateInternalTransactionData>(_onLoadData);
    on<SelectInternalTransactionCategory>(_onSelectCategory);
    on<SearchInternalTransactionProcesses>(_onSearch);
  }

  Future<void> _onLoadData(
    LoadCreateInternalTransactionData event,
    Emitter<CreateInternalTransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingCategories: true,
        clearError: true,
      ),
    );

    final result = await getInternalCategories();

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            loadingCategories: false,
            errorMessage: failure.message,
          ),
        );
      },
      (categories) async {
        final firstCategoryId =
            categories.isNotEmpty ? categories.first.id : -1;

        emit(
          state.copyWith(
            categories: categories,
            selectedCategoryId: firstCategoryId,
            loadingCategories: false,
          ),
        );

        if (firstCategoryId != -1) {
          add(SelectInternalTransactionCategory(firstCategoryId));
        }
      },
    );
  }

  Future<void> _onSelectCategory(
    SelectInternalTransactionCategory event,
    Emitter<CreateInternalTransactionState> emit,
  ) async {
    if (state.selectedCategoryId == event.categoryId &&
        state.processes.isNotEmpty) {
      return;
    }

    emit(
      state.copyWith(
        selectedCategoryId: event.categoryId,
        loadingProcesses: true,
        processes: const [],
        clearError: true,
      ),
    );

    final result = await getProcessesByCategory(
      categoryId: event.categoryId,
      page: _page,
      limit: _limit,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            loadingProcesses: false,
            processes: const [],
            errorMessage: failure.message,
          ),
        );
      },
      (pageData) {
        emit(
          state.copyWith(
            loadingProcesses: false,
            processes: pageData.items,
          ),
        );
      },
    );
  }

  void _onSearch(
    SearchInternalTransactionProcesses event,
    Emitter<CreateInternalTransactionState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: event.query,
      ),
    );
  }
}