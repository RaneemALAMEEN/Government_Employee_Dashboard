class AppointmentBooking {
  final int id;
  final int appointmentId;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;
  final String phoneNumber;
  final String? identityImagePath;
  final String reason;
  final String status;
  final String statusLabel;
  final int? queueOrder;
  final bool? attended;
  final String? decisionNote;

  const AppointmentBooking({
    required this.id,
    required this.appointmentId,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
    required this.phoneNumber,
    required this.identityImagePath,
    required this.reason,
    required this.status,
    required this.statusLabel,
    required this.queueOrder,
    required this.attended,
    required this.decisionNote,
  });

  String get fullName => '$firstName $fatherName $lastName'.trim();
}

class AppointmentSlot {
  final int id;
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final int capacity;
  final int approvedTaken;
  final int remainingSeats;
  final bool isActive;
  final List<AppointmentBooking> bookings;

  const AppointmentSlot({
    required this.id,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.approvedTaken,
    required this.remainingSeats,
    required this.isActive,
    required this.bookings,
  });
}

class AppointmentSlotInput {
  final String appointmentDate;
  final String startTime;
  final String endTime;
  final int capacity;
  final bool? isActive;

  const AppointmentSlotInput({
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'appointment_date': appointmentDate,
        'start_time': startTime,
        'end_time': endTime,
        'capacity': capacity,
        if (isActive != null) 'is_active': isActive,
      };
}

class AppointmentBookingInput {
  final int appointmentId;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String nationalId;
  final String phoneNumber;
  final String reason;
  final String identityImagePath;

  const AppointmentBookingInput({
    required this.appointmentId,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.nationalId,
    required this.phoneNumber,
    required this.reason,
    required this.identityImagePath,
  });
}
