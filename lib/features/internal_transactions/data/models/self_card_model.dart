import '../../domain/entities/self_card_entity.dart';

class SelfCardModel extends SelfCardEntity {
  const SelfCardModel({
    required super.id,
    required super.userId,
    required super.organizationId,
    required super.selfNumber,
    required super.nationalId,
    required super.fullName,
    required super.fatherName,
    required super.motherName,
    required super.isActive,
  });

  factory SelfCardModel.fromJson(Map<String, dynamic> json) => SelfCardModel(
        id: _asInt(json['id']) ?? 0,
        userId: _asInt(json['user_id']),
        organizationId: _asInt(json['organization_id']),
        selfNumber: _asString(json['self_number']),
        nationalId: _asString(json['national_id']),
        fullName: _asString(json['full_name']),
        fatherName: _asString(json['father_name']),
        motherName: _asString(json['mother_name']),
        isActive: _asBool(json['is_active']),
      );
}

class SelfCardDetailsModel extends SelfCardDetailsEntity {
  const SelfCardDetailsModel({
    required super.id,
    required super.userId,
    required super.organizationId,
    required super.selfNumber,
    required super.nationalId,
    required super.fullName,
    required super.fatherName,
    required super.motherName,
    required super.isActive,
    required super.insuranceNumber,
    required super.birthPlace,
    required super.birthDate,
    required super.registryPlace,
    required super.registryNumber,
    required super.gender,
    required super.nationality,
    required super.foreignLanguage,
    required super.educationDegree,
    required super.currentResidence,
    required super.createdAt,
    required super.updatedAt,
    required super.trainingCourses,
    required super.employmentStatuses,
    required super.irregularAbsences,
    required super.leaves,
    required super.rewards,
    required super.sanctions,
  });

  factory SelfCardDetailsModel.fromJson(Map<String, dynamic> json) =>
      SelfCardDetailsModel(
        id: _asInt(json['id']) ?? 0,
        userId: _asInt(json['user_id']),
        organizationId: _asInt(json['organization_id']),
        selfNumber: _asString(json['self_number']),
        nationalId: _asString(json['national_id']),
        fullName: _asString(json['full_name']),
        fatherName: _asString(json['father_name']),
        motherName: _asString(json['mother_name']),
        isActive: _asBool(json['is_active']),
        insuranceNumber: _asString(json['insurance_number']),
        birthPlace: _asString(json['birth_place']),
        birthDate: _asString(json['birth_date']),
        registryPlace: _asString(json['registry_place']),
        registryNumber: _asString(json['registry_number']),
        gender: _asString(json['gender']),
        nationality: _asString(json['nationality']),
        foreignLanguage: _asString(json['foreign_language']),
        educationDegree: _asString(json['education_degree']),
        currentResidence: _asString(json['current_residence']),
        createdAt: _asString(json['created_at']),
        updatedAt: _asString(json['updated_at']),
        trainingCourses: _asMapList(json['training_courses']),
        employmentStatuses: _asMapList(json['employment_statuses']),
        irregularAbsences: _asMapList(json['irregular_absences']),
        leaves: _asMapList(json['leaves']),
        rewards: _asMapList(json['rewards']),
        sanctions: _asMapList(json['sanctions']),
      );
}

int? _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

String _asString(dynamic value) => value?.toString() ?? '';

bool _asBool(dynamic value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';

List<Map<String, dynamic>> _asMapList(dynamic value) => value is List
    ? value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false)
    : const [];
