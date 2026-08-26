import 'package:equatable/equatable.dart';

class TrainingRecommendationQueryEntity extends Equatable {
  final String title;
  final String? normalizedTitle;
  final int limit;
  final String? publicEntity;
  final double? matchThreshold;

  const TrainingRecommendationQueryEntity({
    required this.title,
    this.normalizedTitle,
    this.limit = 20,
    this.publicEntity,
    this.matchThreshold,
  });

  @override
  List<Object?> get props => [
        title,
        normalizedTitle,
        limit,
        publicEntity,
        matchThreshold,
      ];
}

class TrainingRecommendationCandidateEntity extends Equatable {
  final int id;
  final int? userId;
  final String? publicEntity;
  final String? selfNumber;
  final String? nationalId;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final String? educationDegree;
  final bool isActive;
  final int recommendationPriority;
  final double maxSimilarity;
  final int trainingCoursesCount;
  final String? reason;
  final dynamic closestCourse;
  final String? pathSelfCard;

  const TrainingRecommendationCandidateEntity({
    required this.id,
    this.userId,
    this.publicEntity,
    this.selfNumber,
    this.nationalId,
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.educationDegree,
    this.isActive = true,
    this.recommendationPriority = 0,
    this.maxSimilarity = 0.0,
    this.trainingCoursesCount = 0,
    this.reason,
    this.closestCourse,
    this.pathSelfCard,
  });

  String get displayName {
    final buffer = StringBuffer(fullName);
    if (fatherName != null && fatherName!.trim().isNotEmpty) {
      buffer.write(' بن $fatherName');
    }
    return buffer.toString();
  }

  String get reasonDescription {
    if (reason == null || reason!.isEmpty) {
      return 'مرشح لحضور الدورة';
    }
    switch (reason) {
      case 'never_attended_any_course':
        return 'لم يحضر أي دورة تدريبية مسبقاً';
      case 'no_matching_course':
      case 'not_attended':
        return 'لم يحضر هذه الدورة أو دورات مماثلة';
      case 'low_similarity':
        return 'الدورات السابقة لا تغطي متطلبات الدورة الحالية';
      default:
        return reason!;
    }
  }

  String get similarityPercentage =>
      '${(maxSimilarity * 100).toStringAsFixed(0)}%';

  @override
  List<Object?> get props => [
        id,
        userId,
        publicEntity,
        selfNumber,
        nationalId,
        fullName,
        fatherName,
        motherName,
        educationDegree,
        isActive,
        recommendationPriority,
        maxSimilarity,
        trainingCoursesCount,
        reason,
        closestCourse,
        pathSelfCard,
      ];
}

class TrainingRecommendationResultEntity extends Equatable {
  final TrainingRecommendationQueryEntity query;
  final int totalCandidates;
  final int returned;
  final List<TrainingRecommendationCandidateEntity> items;
  final String? message;

  const TrainingRecommendationResultEntity({
    required this.query,
    required this.totalCandidates,
    required this.returned,
    required this.items,
    this.message,
  });

  @override
  List<Object?> get props => [
        query,
        totalCandidates,
        returned,
        items,
        message,
      ];
}
