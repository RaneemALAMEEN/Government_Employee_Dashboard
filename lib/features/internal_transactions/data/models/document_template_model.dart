import '../../domain/entities/document_template_entity.dart';
import 'dynamic_form_model.dart';

class DocumentTemplateModel extends DocumentTemplateEntity {
  const DocumentTemplateModel({
    required super.id,
    required super.name,
    required super.filePath,
    required super.typeDocId,
    required super.engineType,
    required super.config,
  });

  factory DocumentTemplateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return DocumentTemplateModel(
      id: data['id'] ?? 0,
      name: data['name']?.toString() ?? '',
      filePath: data['file_path']?.toString() ?? '',
      typeDocId: data['type_doc_id'] ?? 0,
      engineType: data['engine_type']?.toString() ?? '',
      config: DynamicFormModel.fromJson(
        data['config_json'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}