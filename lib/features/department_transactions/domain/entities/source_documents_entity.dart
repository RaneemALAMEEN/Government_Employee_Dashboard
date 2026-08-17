import 'package:equatable/equatable.dart';

class SourceDocumentsEntity extends Equatable {
  final int transactionId;
  final String status;
  final List<SourceDocumentItemEntity> documentInstances;
  final List<SourceDocumentItemEntity> documentSignatures;

  const SourceDocumentsEntity({
    required this.transactionId,
    required this.status,
    required this.documentInstances,
    required this.documentSignatures,
  });

  List<SourceDocumentItemEntity> get allDocuments => [
        ...documentInstances,
        ...documentSignatures,
      ];

  bool get isEmpty =>
      documentInstances.isEmpty && documentSignatures.isEmpty;

  @override
  List<Object?> get props => [
        transactionId,
        status,
        documentInstances,
        documentSignatures,
      ];
}

class SourceDocumentItemEntity extends Equatable {
  final int id;
  final int? typeDocId;
  final String typeDocName;
  final String filePath;
  final String fileUrl;
  final String createdAt;
  final bool isInstance; // true: document_instance, false: document_signature

  const SourceDocumentItemEntity({
    required this.id,
    this.typeDocId,
    required this.typeDocName,
    required this.filePath,
    required this.fileUrl,
    required this.createdAt,
    required this.isInstance,
  });

  /// The order key format expected by the API: `instance:ID` or `signature:ID`
  String get orderKey => isInstance ? 'instance:$id' : 'signature:$id';

  /// Short order key format: `i:ID` or `s:ID`
  String get shortOrderKey => isInstance ? 'i:$id' : 's:$id';

  bool get isPdf {
    final lower = (fileUrl.isNotEmpty ? fileUrl : filePath).toLowerCase();
    return lower.contains('.pdf');
  }

  String get displayName {
    if (typeDocName.trim().isNotEmpty) return typeDocName.trim();
    if (isInstance) return 'نموذج نظام مستند #$id';
    return 'ملف مرفق #$id';
  }

  @override
  List<Object?> get props => [
        id,
        typeDocId,
        typeDocName,
        filePath,
        fileUrl,
        createdAt,
        isInstance,
      ];
}

class GeneratedFinalDocumentResultEntity extends Equatable {
  final String fileUrl;
  final String filePath;
  final String message;

  const GeneratedFinalDocumentResultEntity({
    required this.fileUrl,
    required this.filePath,
    required this.message,
  });

  @override
  List<Object?> get props => [fileUrl, filePath, message];
}
