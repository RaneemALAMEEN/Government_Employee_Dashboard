import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../self_cards/domain/entities/self_card_entity.dart';
import '../../../self_cards/domain/usecases/get_employee_self_card_usecase.dart';
import '../../domain/usecases/get_statistics_employee_details.dart';
import 'statistics_employee_details_event.dart';
import 'statistics_employee_details_state.dart';

class StatisticsEmployeeDetailsBloc extends Bloc<StatisticsEmployeeDetailsEvent,
    StatisticsEmployeeDetailsState> {
  final GetStatisticsEmployeeDetails getEmployeeDetails;
  final GetEmployeeSelfCardUseCase getEmployeeSelfCard;

  StatisticsEmployeeDetailsBloc({
    required this.getEmployeeDetails,
    required this.getEmployeeSelfCard,
  }) : super(const EmployeeDetailsInitial()) {
    on<LoadEmployeeDetails>(_onLoadEmployeeDetails);
  }

  Future<void> _onLoadEmployeeDetails(
    LoadEmployeeDetails event,
    Emitter<StatisticsEmployeeDetailsState> emit,
  ) async {
    emit(const EmployeeDetailsLoading());

    final employeeResult =
        await getEmployeeDetails(employeeId: event.employeeId);
    final selfCardResult =
        await getEmployeeSelfCard(event.employeeId);

    employeeResult.fold(
      (failure) => emit(EmployeeDetailsError(message: failure.message)),
      (details) {
        SelfCardEntity? selfCard;
        String? selfCardError;

        selfCardResult.fold(
          (failure) {
            selfCardError = failure.message;
          },
          (card) {
            selfCard = card;
          },
        );

        emit(
          EmployeeDetailsLoaded(
            employee: details,
            selfCard: selfCard,
            selfCardError: selfCardError,
          ),
        );
      },
    );
  }
}
