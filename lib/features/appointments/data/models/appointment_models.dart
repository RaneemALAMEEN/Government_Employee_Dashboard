import '../../domain/entities/appointment_entities.dart';

class AppointmentBookingModel extends AppointmentBooking {
  const AppointmentBookingModel({
    required super.id,
    required super.appointmentId,
    required super.firstName,
    required super.lastName,
    required super.fatherName,
    required super.motherName,
    required super.nationalId,
    required super.phoneNumber,
    required super.identityImagePath,
    required super.reason,
    required super.status,
    required super.statusLabel,
    required super.queueOrder,
    required super.attended,
    required super.decisionNote,
  });

  factory AppointmentBookingModel.fromJson(Map<String, dynamic> json) {
    int integer(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
    return AppointmentBookingModel(
      id: integer(json['id']),
      appointmentId: integer(json['appointment_id']),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      nationalId: json['national_id']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      identityImagePath: json['identity_image_path']?.toString(),
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusLabel: json['status_label']?.toString() ?? '',
      queueOrder:
          json['queue_order'] == null ? null : integer(json['queue_order']),
      attended: json['attended'] as bool?,
      decisionNote: json['decision_note']?.toString(),
    );
  }
}

class AppointmentSlotModel extends AppointmentSlot {
  const AppointmentSlotModel({
    required super.id,
    required super.appointmentDate,
    required super.startTime,
    required super.endTime,
    required super.capacity,
    required super.approvedTaken,
    required super.remainingSeats,
    required super.isActive,
    required super.bookings,
  });

  factory AppointmentSlotModel.fromJson(Map<String, dynamic> json) {
    int integer(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
    final bookings = json['bookings'] as List? ?? const [];
    return AppointmentSlotModel(
      id: integer(json['id']),
      appointmentDate: json['appointment_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      capacity: integer(json['capacity']),
      approvedTaken: integer(json['approved_taken']),
      remainingSeats: integer(json['remaining_seats']),
      isActive: json['is_active'] != false,
      bookings: bookings
          .whereType<Map>()
          .map((item) => AppointmentBookingModel.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false),
    );
  }
}
