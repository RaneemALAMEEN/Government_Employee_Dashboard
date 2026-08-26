class SelfCardEntity {
  final int id;
  final int? userId;
  final int? organizationId;
  final String selfNumber;
  final String nationalId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final bool isActive;

  const SelfCardEntity({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.selfNumber,
    required this.nationalId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.isActive,
  });
}

class SelfCardDetailsEntity extends SelfCardEntity {
  final String insuranceNumber;
  final String birthPlace;
  final String birthDate;
  final String registryPlace;
  final String registryNumber;
  final String gender;
  final String nationality;
  final String foreignLanguage;
  final String educationDegree;
  final String currentResidence;
  final String createdAt;
  final String updatedAt;
  final List<Map<String, dynamic>> trainingCourses;
  final List<Map<String, dynamic>> employmentStatuses;
  final List<Map<String, dynamic>> irregularAbsences;
  final List<Map<String, dynamic>> leaves;
  final List<Map<String, dynamic>> rewards;
  final List<Map<String, dynamic>> sanctions;

  const SelfCardDetailsEntity({
    required super.id,
    required super.userId,
    required super.organizationId,
    required super.selfNumber,
    required super.nationalId,
    required super.fullName,
    required super.fatherName,
    required super.motherName,
    required super.isActive,
    required this.insuranceNumber,
    required this.birthPlace,
    required this.birthDate,
    required this.registryPlace,
    required this.registryNumber,
    required this.gender,
    required this.nationality,
    required this.foreignLanguage,
    required this.educationDegree,
    required this.currentResidence,
    required this.createdAt,
    required this.updatedAt,
    required this.trainingCourses,
    required this.employmentStatuses,
    required this.irregularAbsences,
    required this.leaves,
    required this.rewards,
    required this.sanctions,
  });
}
