import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/department_leaf_entity.dart';
import '../entities/department_role_entity.dart';
import '../entities/organization_employee_entity.dart';

abstract class OrganizationHierarchyRepository {
  Future<Either<Failure, List<DepartmentLeafEntity>>> getDepartmentLeaves(
    int organizationId,
  );

  Future<Either<Failure, List<DepartmentRoleEntity>>> getDepartmentRoles(
    int departmentId,
  );

  Future<Either<Failure, List<OrganizationEmployeeEntity>>> getEmployees({
    required int organizationId,
    required int departmentId,
    required int roleId,
  });
}
