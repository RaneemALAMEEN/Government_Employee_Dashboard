import '../../domain/entities/self_card_entity.dart';
import 'training_course_model.dart';

class SelfCardModel extends SelfCardEntity {
  const SelfCardModel({
    required super.id,
    super.userId,
    super.organizationId,
    super.selfNumber,
    super.nationalId,
    super.insuranceNumber,
    required super.fullName,
    super.fatherName,
    super.motherName,
    super.birthPlace,
    super.birthDate,
    super.registryPlace,
    super.registryNumber,
    super.gender,
    super.nationality,
    super.foreignLanguage,
    super.educationDegree,
    super.currentResidence,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    super.pathSelfCard,
    super.trainingCourses,
  });

  factory SelfCardModel.fromJson(Map<String, dynamic> json) {
    final coursesJson = json['training_courses'] as List? ??
        json['trainingCourses'] as List? ??
        [];

    final parsedCourses = coursesJson
        .whereType<Map>()
        .map((e) => TrainingCourseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return SelfCardModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      organizationId: json['organization_id'] is int
          ? json['organization_id'] as int
          : int.tryParse(json['organization_id']?.toString() ?? ''),
      selfNumber: json['self_number']?.toString() ?? json['selfNumber']?.toString(),
      nationalId: json['national_id']?.toString() ?? json['nationalId']?.toString(),
      insuranceNumber: json['insurance_number']?.toString() ?? json['insuranceNumber']?.toString(),
      fullName: json['full_name']?.toString() ?? json['fullName']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? json['fatherName']?.toString(),
      motherName: json['mother_name']?.toString() ?? json['motherName']?.toString(),
      birthPlace: json['birth_place']?.toString() ?? json['birthPlace']?.toString(),
      birthDate: json['birth_date']?.toString() ?? json['birthDate']?.toString(),
      registryPlace: json['registry_place']?.toString() ?? json['registryPlace']?.toString(),
      registryNumber: json['registry_number']?.toString() ?? json['registryNumber']?.toString(),
      gender: json['gender']?.toString(),
      nationality: json['nationality']?.toString(),
      foreignLanguage: json['foreign_language']?.toString() ?? json['foreignLanguage']?.toString(),
      educationDegree: json['education_degree']?.toString() ?? json['educationDegree']?.toString(),
      currentResidence: json['current_residence']?.toString() ?? json['currentResidence']?.toString(),
      isActive: json['is_active'] == true ||
          json['isActive'] == true ||
          json['is_active'] == 1 ||
          json['is_active'] == 'true',
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
      pathSelfCard: json['path_self_card']?.toString() ??
          json['pathSelfCard']?.toString() ??
          json['self_card_path']?.toString(),
      trainingCourses: parsedCourses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organization_id': organizationId,
      'self_number': selfNumber,
      'national_id': nationalId,
      'insurance_number': insuranceNumber,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'birth_place': birthPlace,
      'birth_date': birthDate,
      'registry_place': registryPlace,
      'registry_number': registryNumber,
      'gender': gender,
      'nationality': nationality,
      'foreign_language': foreignLanguage,
      'education_degree': educationDegree,
      'current_residence': currentResidence,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'path_self_card': pathSelfCard,
      'training_courses': (trainingCourses as List<TrainingCourseModel>)
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
