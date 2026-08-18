import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/appointment_entities.dart';

abstract class AppointmentsRepository {
  Future<Either<Failure, List<AppointmentSlot>>> getManaged(String filter);
  Future<Either<Failure, List<AppointmentSlot>>> getAvailable();
  Future<Either<Failure, AppointmentSlot>> createSlot(
      AppointmentSlotInput input);
  Future<Either<Failure, AppointmentSlot>> updateSlot(
      int id, AppointmentSlotInput input);
  Future<Either<Failure, void>> deleteSlot(int id);
  Future<Either<Failure, AppointmentBooking>> decide(
      int id, String decision, String note);
  Future<Either<Failure, AppointmentBooking>> attendance(int id, bool attended);
  Future<Either<Failure, void>> deletePastBooking(int id);
  Future<Either<Failure, AppointmentBooking>> book(
      AppointmentBookingInput input);
}
