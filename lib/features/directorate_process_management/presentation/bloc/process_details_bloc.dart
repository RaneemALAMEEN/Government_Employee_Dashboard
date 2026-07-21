import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_process_details.dart';
import 'process_details_event.dart';
import 'process_details_state.dart';

class ProcessDetailsBloc
    extends Bloc<ProcessDetailsEvent, ProcessDetailsState> {
  final GetProcessDetails getProcessDetails;

  ProcessDetailsBloc({required this.getProcessDetails})
      : super(const ProcessDetailsInitial()) {
    on<LoadProcessDetails>(_load);
  }

  Future<void> _load(
    LoadProcessDetails event,
    Emitter<ProcessDetailsState> emit,
  ) async {
    if (event.processId <= 0) {
      emit(const ProcessDetailsError(message: 'معرّف العملية غير صالح'));
      return;
    }
    emit(const ProcessDetailsLoading());
    final result = await getProcessDetails(processId: event.processId);
    result.fold(
      (failure) => emit(ProcessDetailsError(message: failure.message)),
      (details) => emit(ProcessDetailsLoaded(details: details)),
    );
  }
}
