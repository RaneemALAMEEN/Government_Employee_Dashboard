import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employees_repository.dart';
import '../datasources/employees_local_data_source.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  final EmployeesLocalDataSource localDataSource;

  EmployeesRepositoryImpl(this.localDataSource);

  @override
  Future<List<EmployeeEntity>> getEmployees() async {
    return await localDataSource.getEmployees();
  }

  @override
  Future<EmployeeEntity?> getEmployeeById(String id) async {
    return await localDataSource.getEmployeeById(id);
  }
}
