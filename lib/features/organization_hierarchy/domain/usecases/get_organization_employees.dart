import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/organization_employee_entity.dart';
import '../repositories/organization_hierarchy_repository.dart';

class GetOrganizationEmployees {
  final OrganizationHierarchyRepository repository;

  const GetOrganizationEmployees(this.repository);

  Future<Either<Failure, List<OrganizationEmployeeEntity>>> call({
    required int organizationId,
    required int departmentId,
    required int roleId,
  }) =>
      repository.getEmployees(
        organizationId: organizationId,
        departmentId: departmentId,
        roleId: roleId,
      );
}
