import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/department_role_entity.dart';
import '../repositories/organization_hierarchy_repository.dart';

class GetDepartmentRoles {
  final OrganizationHierarchyRepository repository;

  const GetDepartmentRoles(this.repository);

  Future<Either<Failure, List<DepartmentRoleEntity>>> call(
    int departmentId,
  ) =>
      repository.getDepartmentRoles(departmentId);
}
