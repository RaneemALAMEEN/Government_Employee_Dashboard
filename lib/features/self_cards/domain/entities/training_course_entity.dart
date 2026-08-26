import 'package:equatable/equatable.dart';

class TrainingCourseEntity extends Equatable {
  final int id;
  final int? selfCardId;
  final String title;
  final String provider;
  final String topic;
  final String? startDate;
  final String? endDate;
  final String? duration;
  final String? certificateNumber;
  final String? notes;

  const TrainingCourseEntity({
    required this.id,
    this.selfCardId,
    required this.title,
    required this.provider,
    required this.topic,
    this.startDate,
    this.endDate,
    this.duration,
    this.certificateNumber,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        selfCardId,
        title,
        provider,
        topic,
        startDate,
        endDate,
        duration,
        certificateNumber,
        notes,
      ];
}
