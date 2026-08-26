import '../../domain/entities/training_course_entity.dart';

class TrainingCourseModel extends TrainingCourseEntity {
  const TrainingCourseModel({
    required super.id,
    super.selfCardId,
    required super.title,
    required super.provider,
    required super.topic,
    super.startDate,
    super.endDate,
    super.duration,
    super.certificateNumber,
    super.notes,
  });

  factory TrainingCourseModel.fromJson(Map<String, dynamic> json) {
    return TrainingCourseModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      selfCardId: json['self_card_id'] is int
          ? json['self_card_id'] as int
          : int.tryParse(json['self_card_id']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      provider: json['provider']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      duration: json['duration']?.toString(),
      certificateNumber: json['certificate_number']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'self_card_id': selfCardId,
      'title': title,
      'provider': provider,
      'topic': topic,
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
      'certificate_number': certificateNumber,
      'notes': notes,
    };
  }
}
