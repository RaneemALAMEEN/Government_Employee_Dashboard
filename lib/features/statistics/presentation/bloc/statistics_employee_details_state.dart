import '../../domain/entities/statistics_employee_details_entity.dart';

abstract class StatisticsEmployeeDetailsState {
  const StatisticsEmployeeDetailsState();
}

class EmployeeDetailsInitial extends StatisticsEmployeeDetailsState {
  const EmployeeDetailsInitial();
}

class EmployeeDetailsLoading extends StatisticsEmployeeDetailsState {
  const EmployeeDetailsLoading();
}

class EmployeeDetailsLoaded extends StatisticsEmployeeDetailsState {
  final StatisticsEmployeeDetailsEntity employee;

  const EmployeeDetailsLoaded({required this.employee});
}

class EmployeeDetailsError extends StatisticsEmployeeDetailsState {
  final String message;

  const EmployeeDetailsError({required this.message});
}
