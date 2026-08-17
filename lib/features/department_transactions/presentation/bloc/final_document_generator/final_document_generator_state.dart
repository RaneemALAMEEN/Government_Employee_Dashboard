import 'package:equatable/equatable.dart';

import '../../../domain/entities/source_documents_entity.dart';

enum GenerationStatus { initial, loadingSources, sourcesLoaded, generating, success, error }

class FinalDocumentGeneratorState extends Equatable {
  final GenerationStatus status;
  final SourceDocumentsEntity? sourceDocuments;
  final List<SourceDocumentItemEntity> selectedOrder;
  final GeneratedFinalDocumentResultEntity? result;
  final String? errorMessage;

  const FinalDocumentGeneratorState({
    this.status = GenerationStatus.initial,
    this.sourceDocuments,
    this.selectedOrder = const [],
    this.result,
    this.errorMessage,
  });

  bool get isLoading =>
      status == GenerationStatus.loadingSources ||
      status == GenerationStatus.generating;

  bool isSelected(SourceDocumentItemEntity doc) =>
      selectedOrder.any((d) => d.id == doc.id && d.isInstance == doc.isInstance);

  int getSelectionIndex(SourceDocumentItemEntity doc) {
    final index = selectedOrder.indexWhere(
        (d) => d.id == doc.id && d.isInstance == doc.isInstance);
    return index >= 0 ? index + 1 : 0;
  }

  FinalDocumentGeneratorState copyWith({
    GenerationStatus? status,
    SourceDocumentsEntity? sourceDocuments,
    List<SourceDocumentItemEntity>? selectedOrder,
    GeneratedFinalDocumentResultEntity? result,
    String? errorMessage,
  }) {
    return FinalDocumentGeneratorState(
      status: status ?? this.status,
      sourceDocuments: sourceDocuments ?? this.sourceDocuments,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceDocuments,
        selectedOrder,
        result,
        errorMessage,
      ];
}
