import '../../domain/entities/department_leaf_entity.dart';

class DepartmentLeafModel extends DepartmentLeafEntity {
  const DepartmentLeafModel({required super.id, required super.fullPath});

  factory DepartmentLeafModel.fromJson(Map<String, dynamic> json) {
    return DepartmentLeafModel(
      id: _asInt(json['id']),
      fullPath: json['name']?.toString().trim() ?? '',
    );
  }

  static int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}
