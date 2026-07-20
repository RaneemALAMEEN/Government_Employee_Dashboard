abstract class StatisticsEmployeeDetailsEvent {
  const StatisticsEmployeeDetailsEvent();
}

class LoadEmployeeDetails extends StatisticsEmployeeDetailsEvent {
  final int employeeId;

  const LoadEmployeeDetails({required this.employeeId});
}
