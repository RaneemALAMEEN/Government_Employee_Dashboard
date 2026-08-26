import '../../domain/entities/self_card_search_item_entity.dart';

class SelfCardSearchItemModel extends SelfCardSearchItemEntity {
  const SelfCardSearchItemModel({
    required super.id,
    super.userId,
    super.organizationId,
    super.selfNumber,
    super.nationalId,
    required super.fullName,
    super.fatherName,
    super.motherName,
    super.educationDegree,
    super.isActive,
    super.pathSelfCard,
  });

  factory SelfCardSearchItemModel.fromJson(Map<String, dynamic> json) {
    return SelfCardSearchItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ??
              int.tryParse(json['self_card_id']?.toString() ?? '') ??
              0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      organizationId: json['organization_id'] is int
          ? json['organization_id'] as int
          : int.tryParse(json['organization_id']?.toString() ?? ''),
      selfNumber: json['self_number']?.toString() ?? json['selfNumber']?.toString(),
      nationalId: json['national_id']?.toString() ?? json['nationalId']?.toString(),
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          '',
      fatherName: json['father_name']?.toString() ?? json['fatherName']?.toString(),
      motherName: json['mother_name']?.toString() ?? json['motherName']?.toString(),
      educationDegree: json['education_degree']?.toString() ?? json['educationDegree']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true ||
              json['isActive'] == true ||
              json['is_active'] == 1 ||
              json['is_active'] == 'true'),
      pathSelfCard: json['path_self_card']?.toString() ??
          json['pathSelfCard']?.toString() ??
          json['self_card_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'self_number': selfNumber,
      'national_id': nationalId,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'education_degree': educationDegree,
      'is_active': isActive,
      'path_self_card': pathSelfCard,
    };
  }
}
