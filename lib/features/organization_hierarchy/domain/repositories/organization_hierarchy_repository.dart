import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../entities/department_leaf_entity.dart';
import '../entities/department_role_entity.dart';
import '../entities/organization_employee_entity.dart';
import '../entities/organization_search_entity.dart';

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

  Future<Either<Failure, OrganizationSearchEntity>> searchOrganization({
    required int organizationId,
    required String query,
    required String scope,
    required int limit,
    String? cursor,
    CancelToken? cancelToken,
  });
}
