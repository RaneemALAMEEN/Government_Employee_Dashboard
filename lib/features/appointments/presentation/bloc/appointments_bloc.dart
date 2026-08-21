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
  final String? successMessage;
  const UpdateAppointmentSlot(this.id, this.input, {this.successMessage});

  @override
  List<Object?> get props => [id, input, successMessage];
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
  final bool availableLoading;
  final bool refreshing;
  final bool actionLoading;
  final String? error;
  final String? availableError;
  final String? actionError;
  final String? successMessage;

  const AppointmentsState({
    this.filter = 'pending',
    this.slots = const [],
    this.availableSlots = const [],
    this.loading = false,
    this.availableLoading = false,
    this.refreshing = false,
    this.actionLoading = false,
    this.error,
    this.availableError,
    this.actionError,
    this.successMessage,
  });

  AppointmentsState copyWith({
    String? filter,
    List<AppointmentSlot>? slots,
    List<AppointmentSlot>? availableSlots,
    bool? loading,
    bool? availableLoading,
    bool? refreshing,
    bool? actionLoading,
    String? error,
    String? availableError,
    String? actionError,
    String? successMessage,
    bool clearMessages = false,
  }) =>
      AppointmentsState(
        filter: filter ?? this.filter,
        slots: slots ?? this.slots,
        availableSlots: availableSlots ?? this.availableSlots,
        loading: loading ?? this.loading,
        availableLoading: availableLoading ?? this.availableLoading,
        refreshing: refreshing ?? this.refreshing,
        actionLoading: actionLoading ?? this.actionLoading,
        error: clearMessages ? null : error ?? this.error,
        availableError: availableError,
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
        availableLoading,
        refreshing,
        actionLoading,
        error,
        availableError,
        actionError,
        successMessage
      ];
}

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  final AppointmentsUseCases useCases;
  AppointmentsBloc(this.useCases) : super(const AppointmentsState()) {
    on<LoadAppointments>(_load);
    on<LoadAvailableAppointmentSlots>(_loadAvailable);
    on<CreateAppointmentSlot>((event, emit) => _act(
        emit, () => useCases.createSlot(event.input), 'تمت إضافة الموعد بنجاح',
        reloadAvailable: true));
    on<UpdateAppointmentSlot>(_updateSlot);
    on<DeleteAppointmentSlot>(_deleteSlot);
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
    emit(state.copyWith(
      availableLoading: state.availableSlots.isEmpty,
      availableError: null,
    ));
    final result = await useCases.getAvailable();
    result.fold(
      (failure) => emit(state.copyWith(
        availableLoading: false,
        availableError: failure.message,
      )),
      (slots) {
        final fetchedSlots = slots as List<AppointmentSlot>;
        final fetchedIds = fetchedSlots.map((slot) => slot.id).toSet();
        final locallyInactive = state.availableSlots.where(
          (slot) => !slot.isActive && !fetchedIds.contains(slot.id),
        );
        emit(state.copyWith(
          availableSlots: [...fetchedSlots, ...locallyInactive],
          availableLoading: false,
          availableError: null,
        ));
      },
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

  Future<void> _updateSlot(
    UpdateAppointmentSlot event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearMessages: true));
    final result = await useCases.updateSlot(event.id, event.input);
    result.fold(
      (failure) => emit(state.copyWith(
        actionLoading: false,
        actionError: failure.message,
      )),
      (updatedSlot) {
        final typedSlot = updatedSlot as AppointmentSlot;
        final updatedSlots = state.availableSlots
            .map((slot) => slot.id == typedSlot.id ? typedSlot : slot)
            .toList(growable: false);
        emit(state.copyWith(
          availableSlots: updatedSlots,
          actionLoading: false,
          successMessage: event.successMessage ?? 'تم تعديل الموعد بنجاح',
        ));
      },
    );
  }

  Future<void> _deleteSlot(
    DeleteAppointmentSlot event,
    Emitter<AppointmentsState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearMessages: true));
    final result = await useCases.deleteSlot(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        actionLoading: false,
        actionError: failure.message,
      )),
      (_) => emit(state.copyWith(
        availableSlots: state.availableSlots
            .where((slot) => slot.id != event.id)
            .toList(growable: false),
        actionLoading: false,
        successMessage: 'تم حذف الموعد بنجاح',
      )),
    );
  }

  Future<void> _act(
    Emitter<AppointmentsState> emit,
    Future<dynamic> Function() action,
    String success, {
    bool reloadAvailable = false,
  }) async {
    emit(state.copyWith(actionLoading: true, clearMessages: true));
    final result = await action();
    await result.fold(
      (failure) async => emit(
          state.copyWith(actionLoading: false, actionError: failure.message)),
      (_) async {
        emit(state.copyWith(actionLoading: false, successMessage: success));
        if (reloadAvailable) {
          add(const LoadAvailableAppointmentSlots());
        } else {
          add(LoadAppointments(state.filter, refresh: true));
        }
      },
    );
  }
}
