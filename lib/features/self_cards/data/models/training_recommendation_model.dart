import '../../domain/entities/training_recommendation_entity.dart';

class TrainingRecommendationQueryModel
    extends TrainingRecommendationQueryEntity {
  const TrainingRecommendationQueryModel({
    required super.title,
    super.normalizedTitle,
    super.limit,
    super.publicEntity,
    super.matchThreshold,
  });

  factory TrainingRecommendationQueryModel.fromJson(Map<String, dynamic> json) {
    return TrainingRecommendationQueryModel(
      title: json['title']?.toString() ?? '',
      normalizedTitle: json['normalized_title']?.toString() ??
          json['normalizedTitle']?.toString(),
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? '') ?? 20,
      publicEntity: json['public_entity']?.toString() ??
          json['publicEntity']?.toString(),
      matchThreshold: json['match_threshold'] is num
          ? (json['match_threshold'] as num).toDouble()
          : double.tryParse(json['match_threshold']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'normalized_title': normalizedTitle,
      'limit': limit,
      'public_entity': publicEntity,
      'match_threshold': matchThreshold,
    };
  }
}

class TrainingRecommendationCandidateModel
    extends TrainingRecommendationCandidateEntity {
  const TrainingRecommendationCandidateModel({
    required super.id,
    super.userId,
    super.publicEntity,
    super.selfNumber,
    super.nationalId,
    required super.fullName,
    super.fatherName,
    super.motherName,
    super.educationDegree,
    super.isActive,
    super.recommendationPriority,
    super.maxSimilarity,
    super.trainingCoursesCount,
    super.reason,
    super.closestCourse,
    super.pathSelfCard,
  });

  factory TrainingRecommendationCandidateModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TrainingRecommendationCandidateModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ??
              int.tryParse(json['self_card_id']?.toString() ?? '') ??
              0,
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id']?.toString() ?? ''),
      publicEntity: json['public_entity']?.toString() ??
          json['publicEntity']?.toString(),
      selfNumber: json['self_number']?.toString() ??
          json['selfNumber']?.toString(),
      nationalId: json['national_id']?.toString() ??
          json['nationalId']?.toString(),
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          json['name']?.toString() ??
          '',
      fatherName: json['father_name']?.toString() ??
          json['fatherName']?.toString(),
      motherName: json['mother_name']?.toString() ??
          json['motherName']?.toString(),
      educationDegree: json['education_degree']?.toString() ??
          json['educationDegree']?.toString(),
      isActive: json['is_active'] == null
          ? true
          : (json['is_active'] == true ||
              json['isActive'] == true ||
              json['is_active'] == 1 ||
              json['is_active'] == 'true'),
      recommendationPriority: json['recommendation_priority'] is int
          ? json['recommendation_priority'] as int
          : int.tryParse(
                  json['recommendation_priority']?.toString() ?? '') ??
              0,
      maxSimilarity: json['max_similarity'] is num
          ? (json['max_similarity'] as num).toDouble()
          : double.tryParse(json['max_similarity']?.toString() ?? '') ??
              0.0,
      trainingCoursesCount: json['training_courses_count'] is int
          ? json['training_courses_count'] as int
          : int.tryParse(
                  json['training_courses_count']?.toString() ?? '') ??
              0,
      reason: json['reason']?.toString(),
      closestCourse: json['closest_course'] ?? json['closestCourse'],
      pathSelfCard: json['path_self_card']?.toString() ??
          json['pathSelfCard']?.toString() ??
          json['self_card_path']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'public_entity': publicEntity,
      'self_number': selfNumber,
      'national_id': nationalId,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'education_degree': educationDegree,
      'is_active': isActive,
      'recommendation_priority': recommendationPriority,
      'max_similarity': maxSimilarity,
      'training_courses_count': trainingCoursesCount,
      'reason': reason,
      'closest_course': closestCourse,
      'path_self_card': pathSelfCard,
    };
  }
}

class TrainingRecommendationResultModel
    extends TrainingRecommendationResultEntity {
  const TrainingRecommendationResultModel({
    required super.query,
    required super.totalCandidates,
    required super.returned,
    required super.items,
    super.message,
  });

  factory TrainingRecommendationResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    Map<String, dynamic> dataMap = {};
    if (json['data'] is Map) {
      dataMap = Map<String, dynamic>.from(json['data'] as Map);
    } else {
      dataMap = json;
    }

    final queryMap = dataMap['query'] is Map
        ? Map<String, dynamic>.from(dataMap['query'] as Map)
        : <String, dynamic>{};

    final rawItems = dataMap['items'] is List
        ? dataMap['items'] as List
        : const [];

    final candidateItems = rawItems
        .whereType<Map>()
        .map((e) => TrainingRecommendationCandidateModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();

    return TrainingRecommendationResultModel(
      query: TrainingRecommendationQueryModel.fromJson(queryMap),
      totalCandidates: dataMap['total_candidates'] is int
          ? dataMap['total_candidates'] as int
          : int.tryParse(dataMap['total_candidates']?.toString() ?? '') ??
              candidateItems.length,
      returned: dataMap['returned'] is int
          ? dataMap['returned'] as int
          : int.tryParse(dataMap['returned']?.toString() ?? '') ??
              candidateItems.length,
      items: candidateItems,
      message: json['message']?.toString(),
    );
  }
}
