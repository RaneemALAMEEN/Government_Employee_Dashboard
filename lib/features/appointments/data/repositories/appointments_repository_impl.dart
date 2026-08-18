import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/appointment_entities.dart';
import '../../domain/repositories/appointments_repository.dart';
import '../datasources/appointments_remote_data_source.dart';

class AppointmentsRepositoryImpl implements AppointmentsRepository {
  final AppointmentsRemoteDataSource remote;
  const AppointmentsRepositoryImpl(this.remote);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(
          ServerFailure('حدث خطأ غير متوقع، يرجى المحاولة مجدداً.'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentSlot>>> getManaged(String filter) =>
      _guard(() => remote.getManaged(filter));
  @override
  Future<Either<Failure, List<AppointmentSlot>>> getAvailable() =>
      _guard(remote.getAvailable);
  @override
  Future<Either<Failure, AppointmentSlot>> createSlot(
          AppointmentSlotInput input) =>
      _guard(() => remote.createSlot(input));
  @override
  Future<Either<Failure, AppointmentSlot>> updateSlot(
          int id, AppointmentSlotInput input) =>
      _guard(() => remote.updateSlot(id, input));
  @override
  Future<Either<Failure, void>> deleteSlot(int id) =>
      _guard(() => remote.deleteSlot(id));
  @override
  Future<Either<Failure, AppointmentBooking>> decide(
          int id, String decision, String note) =>
      _guard(() => remote.decide(id, decision, note));
  @override
  Future<Either<Failure, AppointmentBooking>> attendance(
          int id, bool attended) =>
      _guard(() => remote.attendance(id, attended));
  @override
  Future<Either<Failure, void>> deletePastBooking(int id) =>
      _guard(() => remote.deletePastBooking(id));
  @override
  Future<Either<Failure, AppointmentBooking>> book(
          AppointmentBookingInput input) =>
      _guard(() => remote.book(input));
}
