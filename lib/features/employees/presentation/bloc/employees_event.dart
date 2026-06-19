abstract class EmployeesEvent {
  const EmployeesEvent();
}

class LoadEmployees extends EmployeesEvent {
  const LoadEmployees();
}

class SelectEmployee extends EmployeesEvent {
  final String employeeId;
  const SelectEmployee(this.employeeId);
}

class SearchEmployees extends EmployeesEvent {
  final String query;
  const SearchEmployees(this.query);
}
