import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/accessible_department_entity.dart';
import '../repositories/department_transactions_repository.dart';

class GetAccessibleDepartments {
  final DepartmentTransactionsRepository repository;

  GetAccessibleDepartments(this.repository);

  Future<Either<Failure, List<AccessibleDepartmentEntity>>> call() {
    return repository.getAccessibleDepartments();
  }
}
