import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/department_leaf_entity.dart';
import '../repositories/organization_hierarchy_repository.dart';

class GetDepartmentLeaves {
  final OrganizationHierarchyRepository repository;

  const GetDepartmentLeaves(this.repository);

  Future<Either<Failure, List<DepartmentLeafEntity>>> call(
    int organizationId,
  ) =>
      repository.getDepartmentLeaves(organizationId);
}
