import 'dynamic_form_entity.dart';

class DocumentTemplateEntity {
  final int id;
  final String name;
  final String filePath;
  final int typeDocId;
  final String engineType;
  final DynamicFormEntity config;

  const DocumentTemplateEntity({
    required this.id,
    required this.name,
    required this.filePath,
    required this.typeDocId,
    required this.engineType,
    required this.config,
  });
}