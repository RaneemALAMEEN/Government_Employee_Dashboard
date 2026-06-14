import '../../domain/entities/internal_category_entity.dart';

class InternalCategoryModel extends InternalCategoryEntity {
  const InternalCategoryModel({
    required super.id,
    required super.name,
    required super.isActive,
  });

  factory InternalCategoryModel.fromJson(dynamic json) {
    return InternalCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}