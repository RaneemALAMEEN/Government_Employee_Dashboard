import '../../../../shared/utils/app_file_url.dart';
import '../../domain/entities/source_documents_entity.dart';

class SourceDocumentsModel extends SourceDocumentsEntity {
  const SourceDocumentsModel({
    required super.transactionId,
    required super.status,
    required super.documentInstances,
    required super.documentSignatures,
  });

  factory SourceDocumentsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawInstances = data['document_instances'] as List? ?? [];
    final rawSignatures = data['document_signatures'] as List? ?? [];

    final instances = rawInstances
        .whereType<Map>()
        .map((item) => SourceDocumentItemModel.fromJson(
              Map<String, dynamic>.from(item),
              isInstance: true,
            ))
        .toList();

    final signatures = rawSignatures
        .whereType<Map>()
        .map((item) => SourceDocumentItemModel.fromJson(
              Map<String, dynamic>.from(item),
              isInstance: false,
            ))
        .toList();

    return SourceDocumentsModel(
      transactionId: (data['transaction_id'] as num?)?.toInt() ?? 0,
      status: data['status']?.toString() ?? '',
      documentInstances: instances,
      documentSignatures: signatures,
    );
  }
}

class SourceDocumentItemModel extends SourceDocumentItemEntity {
  const SourceDocumentItemModel({
    required super.id,
    super.name,
    super.typeDocId,
    super.typeDocName,
    required super.filePath,
    required super.fileUrl,
    required super.createdAt,
    required super.isInstance,
  });

  factory SourceDocumentItemModel.fromJson(
    Map<String, dynamic> json, {
    required bool isInstance,
  }) {
    final rawPath = json['generated_pdf_path']?.toString() ??
        json['file_path']?.toString() ??
        json['path']?.toString() ??
        json['url']?.toString() ??
        '';

    var rawUrl = json['file_url']?.toString() ?? json['url']?.toString() ?? '';
    if (rawUrl.isEmpty && rawPath.isNotEmpty) {
      rawUrl = buildAbsoluteFileUrl(rawPath);
    }

    final name = json['name']?.toString() ?? '';
    final typeDocName = json['type_doc_name']?.toString() ??
        json['title']?.toString() ??
        '';

    return SourceDocumentItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: name,
      typeDocId: (json['type_doc_id'] as num?)?.toInt(),
      typeDocName: typeDocName,
      filePath: rawPath,
      fileUrl: rawUrl,
      createdAt: json['created_at']?.toString() ?? '',
      isInstance: isInstance,
    );
  }
}

class GeneratedFinalDocumentResultModel
    extends GeneratedFinalDocumentResultEntity {
  const GeneratedFinalDocumentResultModel({
    required super.fileUrl,
    required super.filePath,
    required super.message,
  });

  factory GeneratedFinalDocumentResultModel.fromJson(dynamic json) {
    String fileUrl = '';
    String filePath = '';
    String message = 'تم توليد الوثيقة النهائية بنجاح';

    if (json is Map<String, dynamic>) {
      message = json['message']?.toString() ?? message;
      final data = json['data'];
      if (data is Map<String, dynamic>) {
        filePath = data['file_path']?.toString() ??
            data['path']?.toString() ??
            data['final_document_path']?.toString() ??
            '';
        fileUrl = data['file_url']?.toString() ??
            data['url']?.toString() ??
            data['final_document_url']?.toString() ??
            '';
      } else if (data is String) {
        fileUrl = data;
        filePath = data;
      }
    } else if (json is String) {
      fileUrl = json;
      filePath = json;
    }

    if (fileUrl.isEmpty && filePath.isNotEmpty) {
      fileUrl = buildAbsoluteFileUrl(filePath);
    }


    return GeneratedFinalDocumentResultModel(
      fileUrl: fileUrl,
      filePath: filePath,
      message: message,
    );
  }
}
