import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_statistics_employee_details.dart';
import 'statistics_employee_details_event.dart';
import 'statistics_employee_details_state.dart';

class StatisticsEmployeeDetailsBloc extends Bloc<StatisticsEmployeeDetailsEvent,
    StatisticsEmployeeDetailsState> {
  final GetStatisticsEmployeeDetails getEmployeeDetails;

  StatisticsEmployeeDetailsBloc({required this.getEmployeeDetails})
      : super(const EmployeeDetailsInitial()) {
    on<LoadEmployeeDetails>(_onLoadEmployeeDetails);
  }

  Future<void> _onLoadEmployeeDetails(
    LoadEmployeeDetails event,
    Emitter<StatisticsEmployeeDetailsState> emit,
  ) async {
    emit(const EmployeeDetailsLoading());
    final result = await getEmployeeDetails(employeeId: event.employeeId);
    result.fold(
      (failure) => emit(EmployeeDetailsError(message: failure.message)),
      (details) => emit(EmployeeDetailsLoaded(employee: details)),
    );
  }
}
