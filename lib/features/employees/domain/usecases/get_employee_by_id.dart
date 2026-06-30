import '../entities/employee_entity.dart';
import '../repositories/employees_repository.dart';

class GetEmployeeById {
  final EmployeesRepository repository;

  GetEmployeeById(this.repository);

  Future<EmployeeEntity?> call(String id) async {
    return await repository.getEmployeeById(id);
  }
}
