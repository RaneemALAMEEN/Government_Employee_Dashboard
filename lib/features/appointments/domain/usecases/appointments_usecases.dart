import '../entities/appointment_entities.dart';
import '../repositories/appointments_repository.dart';

class AppointmentsUseCases {
  final AppointmentsRepository repository;
  const AppointmentsUseCases(this.repository);

  getManaged(String filter) => repository.getManaged(filter);
  getAvailable() => repository.getAvailable();
  createSlot(AppointmentSlotInput input) => repository.createSlot(input);
  updateSlot(int id, AppointmentSlotInput input) =>
      repository.updateSlot(id, input);
  deleteSlot(int id) => repository.deleteSlot(id);
  decide(int id, String decision, String note) =>
      repository.decide(id, decision, note);
  attendance(int id, bool attended) => repository.attendance(id, attended);
  deletePastBooking(int id) => repository.deletePastBooking(id);
  book(AppointmentBookingInput input) => repository.book(input);
}
