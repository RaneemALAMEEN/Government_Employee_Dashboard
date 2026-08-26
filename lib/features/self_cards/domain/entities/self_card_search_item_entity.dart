import 'package:equatable/equatable.dart';

class SelfCardSearchItemEntity extends Equatable {
  final int id;
  final int? userId;
  final int? organizationId;
  final String? selfNumber;
  final String? nationalId;
  final String fullName;
  final String? fatherName;
  final String? motherName;
  final String? educationDegree;
  final bool isActive;
  final String? pathSelfCard;

  const SelfCardSearchItemEntity({
    required this.id,
    this.userId,
    this.organizationId,
    this.selfNumber,
    this.nationalId,
    required this.fullName,
    this.fatherName,
    this.motherName,
    this.educationDegree,
    this.isActive = true,
    this.pathSelfCard,
  });

  String get displayName {
    final buffer = StringBuffer(fullName);
    if (fatherName != null && fatherName!.trim().isNotEmpty) {
      buffer.write(' بن $fatherName');
    }
    return buffer.toString();
  }

  String get subtitle {
    final parts = <String>[];
    if (selfNumber != null && selfNumber!.trim().isNotEmpty) {
      parts.add('الرقم الذاتي: $selfNumber');
    }
    if (nationalId != null && nationalId!.trim().isNotEmpty) {
      parts.add('الرقم الوطني: $nationalId');
    }
    return parts.join(' | ');
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        organizationId,
        selfNumber,
        nationalId,
        fullName,
        fatherName,
        motherName,
        educationDegree,
        isActive,
        pathSelfCard,
      ];
}
