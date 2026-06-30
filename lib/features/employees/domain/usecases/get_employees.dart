import '../entities/employee_entity.dart';
import '../repositories/employees_repository.dart';

class GetEmployees {
  final EmployeesRepository repository;

  GetEmployees(this.repository);

  Future<List<EmployeeEntity>> call() async {
    return await repository.getEmployees();
  }
}
