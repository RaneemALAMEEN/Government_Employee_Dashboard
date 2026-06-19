import '../entities/employee_entity.dart';

abstract class EmployeesRepository {
  Future<List<EmployeeEntity>> getEmployees();
  Future<EmployeeEntity?> getEmployeeById(String id);
}
