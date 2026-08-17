import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/source_documents_entity.dart';
import '../../../domain/repositories/department_transactions_repository.dart';
import 'final_document_generator_state.dart';

class FinalDocumentGeneratorCubit extends Cubit<FinalDocumentGeneratorState> {
  final DepartmentTransactionsRepository repository;

  FinalDocumentGeneratorCubit({required this.repository})
      : super(const FinalDocumentGeneratorState());

  Future<void> loadSourceDocuments(int transactionId) async {
    emit(state.copyWith(
      status: GenerationStatus.loadingSources,
      errorMessage: null,
    ));

    final result = await repository.getSourceDocuments(transactionId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: GenerationStatus.error,
        errorMessage: failure.message,
      )),
      (sources) {
        // By default, select all documents in natural order (instances then signatures)
        final initialSelected = List<SourceDocumentItemEntity>.from(sources.allDocuments);
        emit(state.copyWith(
          status: GenerationStatus.sourcesLoaded,
          sourceDocuments: sources,
          selectedOrder: initialSelected,
          errorMessage: null,
        ));
      },
    );
  }

  void toggleDocumentSelection(SourceDocumentItemEntity doc) {
    final current = List<SourceDocumentItemEntity>.from(state.selectedOrder);
    final index = current.indexWhere((d) => d.id == doc.id && d.isInstance == doc.isInstance);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(doc);
    }
    emit(state.copyWith(
      selectedOrder: current,
      status: GenerationStatus.sourcesLoaded,
    ));
  }

  void reorderDocuments(int oldIndex, int newIndex) {
    final list = List<SourceDocumentItemEntity>.from(state.selectedOrder);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    emit(state.copyWith(
      selectedOrder: list,
      status: GenerationStatus.sourcesLoaded,
    ));
  }

  void moveDocumentUp(SourceDocumentItemEntity doc) {
    final list = List<SourceDocumentItemEntity>.from(state.selectedOrder);
    final index = list.indexWhere((d) => d.id == doc.id && d.isInstance == doc.isInstance);
    if (index > 0) {
      final item = list.removeAt(index);
      list.insert(index - 1, item);
      emit(state.copyWith(
        selectedOrder: list,
        status: GenerationStatus.sourcesLoaded,
      ));
    }
  }

  void moveDocumentDown(SourceDocumentItemEntity doc) {
    final list = List<SourceDocumentItemEntity>.from(state.selectedOrder);
    final index = list.indexWhere((d) => d.id == doc.id && d.isInstance == doc.isInstance);
    if (index >= 0 && index < list.length - 1) {
      final item = list.removeAt(index);
      list.insert(index + 1, item);
      emit(state.copyWith(
        selectedOrder: list,
        status: GenerationStatus.sourcesLoaded,
      ));
    }
  }

  void selectAll() {
    final sources = state.sourceDocuments;
    if (sources == null) return;
    emit(state.copyWith(
      selectedOrder: List.from(sources.allDocuments),
      status: GenerationStatus.sourcesLoaded,
    ));
  }

  void clearSelection() {
    emit(state.copyWith(
      selectedOrder: const [],
      status: GenerationStatus.sourcesLoaded,
    ));
  }

  Future<void> generateFinalDocument(int transactionId) async {
    emit(state.copyWith(
      status: GenerationStatus.generating,
      errorMessage: null,
    ));

    // Construct file_order string, e.g. "signature:3,instance:2,signature:1"
    final fileOrder = state.selectedOrder.isEmpty
        ? '' // Empty file_order gives cover + QR only according to API spec
        : state.selectedOrder.map((doc) => doc.orderKey).join(',');

    final result = await repository.getOrGenerateFinalDocument(
      transactionId,
      fileOrder: fileOrder,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: GenerationStatus.error,
        errorMessage: failure.message,
      )),
      (genResult) => emit(state.copyWith(
        status: GenerationStatus.success,
        result: genResult,
      )),
    );
  }
}
