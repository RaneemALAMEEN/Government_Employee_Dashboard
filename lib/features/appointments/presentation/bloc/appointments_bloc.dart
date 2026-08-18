import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/appointment_entities.dart';
import '../../domain/usecases/appointments_usecases.dart';

sealed class AppointmentsEvent extends Equatable {
  const AppointmentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppointments extends AppointmentsEvent {
  final String filter;
  final bool refresh;
  const LoadAppointments(this.filter, {this.refresh = false});
  @override
  List<Object?> get props => [filter, refresh];
}

class LoadAvailableAppointmentSlots extends AppointmentsEvent {
  const LoadAvailableAppointmentSlots();
}

class CreateAppointmentSlot extends AppointmentsEvent {
  final AppointmentSlotInput input;
  const CreateAppointmentSlot(this.input);
}

class UpdateAppointmentSlot extends AppointmentsEvent {
  final int id;
  final AppointmentSlotInput input;
  const UpdateAppointmentSlot(this.id, this.input);
}

class DeleteAppointmentSlot extends AppointmentsEvent {
  final int id;
  const DeleteAppointmentSlot(this.id);
}

class DecideAppointmentBooking extends AppointmentsEvent {
  final int id;
  final String decision;
  final String note;
  const DecideAppointmentBooking(this.id, this.decision, this.note);
}

class UpdateAppointmentAttendance extends AppointmentsEvent {
  final int id;
  final bool attended;
  const UpdateAppointmentAttendance(this.id, this.attended);
}

class DeletePastAppointmentBooking extends AppointmentsEvent {
  final int id;
  const DeletePastAppointmentBooking(this.id);
}

class BookEmployeeAppointment extends AppointmentsEvent {
  final AppointmentBookingInput input;
  const BookEmployeeAppointment(this.input);
}

class ClearAppointmentAction extends AppointmentsEvent {
  const ClearAppointmentAction();
}

class AppointmentsState extends Equatable {
  final String filter;
  final List<AppointmentSlot> slots;
  final List<AppointmentSlot> availableSlots;
  final bool loading;
  final bool refreshing;
  final bool actionLoading;
  final String? error;
  final String? actionError;
  final String? successMessage;

  const AppointmentsState({
    this.filter = 'pending',
    this.slots = const [],
    this.availableSlots = const [],
    this.loading = false,
    this.refreshing = false,
    this.actionLoading = false,
    this.error,
    this.actionError,
    this.successMessage,
  });

  AppointmentsState copyWith({
    String? filter,
    List<AppointmentSlot>? slots,
    List<AppointmentSlot>? availableSlots,
    bool? loading,
    bool? refreshing,
    bool? actionLoading,
    String? error,
    String? actionError,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      AppointmentsState(
        filter: filter ?? this.filter,
        slots: slots ?? this.slots,
        availableSlots: availableSlots ?? this.availableSlots,
        loading: loading ?? this.loading,
        refreshing: refreshing ?? this.refreshing,
        actionLoading: actionLoading ?? this.actionLoading,
        error: clearMessages ? null : error ?? this.error,
        actionError: clearMessages ? null : actionError ?? this.actionError,
        successMessage:
            clearMessages ? null : successMessage ?? this.successMessage,
      );

  @override
  List<Object?> get props => [
        filter,
        slots,
        availableSlots,
        loading,
        refreshing,
        actionLoading,
        error,
        actionError,
        successMessage
      ];
}

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentsUseCases useCases;
  AppointmentsBloc(this.useCases) : super(const AppointmentsState()) {
    on<LoadAppointments>(_load);
    on<LoadAvailableAppointmentSlots>(_loadAvailable);
    on<CreateAppointmentSlot>((event, emit) => _act(emit,
        () => useCases.createSlot(event.input), 'تمت إضافة الموعد بنجاح'));
    on<UpdateAppointmentSlot>((event, emit) => _act(
        emit,
        () => useCases.updateSlot(event.id, event.input),
        'تم تعديل الموعد بنجاح'));
    on<DeleteAppointmentSlot>((event, emit) =>
        _act(emit, () => useCases.deleteSlot(event.id), 'تم حذف الموعد بنجاح'));
    on<DecideAppointmentBooking>((event, emit) => _act(
        emit,
        () => useCases.decide(event.id, event.decision, event.note),
        'تم تحديث طلب الحجز'));
    on<UpdateAppointmentAttendance>((event, emit) => _act(
        emit,
        () => useCases.attendance(event.id, event.attended),
        'تم تحديث حالة الحضور'));
    on<DeletePastAppointmentBooking>((event, emit) => _act(emit,
        () => useCases.deletePastBooking(event.id), 'تم حذف الحجز السابق'));
    on<BookEmployeeAppointment>((event, emit) => _act(
        emit, () => useCases.book(event.input), 'تم إرسال طلب الحجز بنجاح'));
    on<ClearAppointmentAction>(
        (event, emit) => emit(state.copyWith(clearMessages: true)));
  }

  Future<void> _loadAvailable(LoadAvailableAppointmentSlots event,
      Emitter<AppointmentsState> emit) async {
    final result = await useCases.getAvailable();
    result.fold(
      (_) {},
      (slots) => emit(state.copyWith(availableSlots: slots)),
    );
  }

  Future<void> _load(
      LoadAppointments event, Emitter<AppointmentsState> emit) async {
    emit(state.copyWith(
      filter: event.filter,
      loading: state.slots.isEmpty,
      refreshing: state.slots.isNotEmpty,
      clearMessages: true,
    ));
    final result = await useCases.getManaged(event.filter);
    result.fold(
      (failure) => emit(state.copyWith(
          loading: false, refreshing: false, error: failure.message)),
      (slots) => emit(state.copyWith(
          slots: slots,
          loading: false,
          refreshing: false,
          clearMessages: true)),
    );
  }

  Future<void> _act(
    Emitter<AppointmentsState> emit,
    Future<dynamic> Function() action,
    String success,
  ) async {
    emit(state.copyWith(actionLoading: true, clearMessages: true));
    final result = await action();
    await result.fold(
      (failure) async => emit(
          state.copyWith(actionLoading: false, actionError: failure.message)),
      (_) async {
        emit(state.copyWith(actionLoading: false, successMessage: success));
        add(LoadAppointments(state.filter, refresh: true));
      },
    );
  }
}
