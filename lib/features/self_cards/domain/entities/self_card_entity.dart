import 'package:equatable/equatable.dart';
import 'training_course_entity.dart';

class SelfCardEntity extends Equatable {
  final int id;
  final int? userId;
  final int? organizationId;
  final String? selfNumber;
  final String? nationalId;
  final String? insuranceNumber;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final String? birthPlace;
  final String? birthDate;
  final String? registryPlace;
  final String? registryNumber;
  final String? gender;
  final String? nationality;
  final String? foreignLanguage;
  final String? educationDegree;
  final String? currentResidence;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? pathSelfCard;
  final List<TrainingCourseEntity> trainingCourses;

  const SelfCardEntity({
    required this.id,
    this.userId,
    this.organizationId,
    this.selfNumber,
    this.nationalId,
    this.insuranceNumber,
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.birthPlace,
    this.birthDate,
    this.registryPlace,
    this.registryNumber,
    this.gender,
    this.nationality,
    this.foreignLanguage,
    this.educationDegree,
    this.currentResidence,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.pathSelfCard,
    this.trainingCourses = const [],
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        organizationId,
        selfNumber,
        nationalId,
        insuranceNumber,
        fullName,
        fatherName,
        motherName,
        birthPlace,
        birthDate,
        registryPlace,
        registryNumber,
        gender,
        nationality,
        foreignLanguage,
        educationDegree,
        currentResidence,
        isActive,
        createdAt,
        updatedAt,
        pathSelfCard,
        trainingCourses,
      ];
}
