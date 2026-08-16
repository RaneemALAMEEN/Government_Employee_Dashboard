import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/department_leaf_entity.dart';
import '../../domain/entities/department_role_entity.dart';
import '../../domain/entities/organization_employee_entity.dart';
import '../../domain/entities/organization_search_entity.dart';
import '../../domain/repositories/organization_hierarchy_repository.dart';
import '../datasources/organization_hierarchy_remote_data_source.dart';

class OrganizationHierarchyRepositoryImpl
    implements OrganizationHierarchyRepository {
  final OrganizationHierarchyRemoteDataSource remoteDataSource;

  const OrganizationHierarchyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<DepartmentLeafEntity>>> getDepartmentLeaves(
    int organizationId,
  ) =>
      _guard(() => remoteDataSource.getDepartmentLeaves(organizationId));

  @override
  Future<Either<Failure, List<DepartmentRoleEntity>>> getDepartmentRoles(
    int departmentId,
  ) =>
      _guard(() => remoteDataSource.getDepartmentRoles(departmentId));

  @override
  Future<Either<Failure, List<OrganizationEmployeeEntity>>> getEmployees({
    required int organizationId,
    required int departmentId,
    required int roleId,
  }) =>
      _guard(
        () => remoteDataSource.getEmployees(
          organizationId: organizationId,
          departmentId: departmentId,
          roleId: roleId,
        ),
      );

  @override
  Future<Either<Failure, OrganizationSearchEntity>> searchOrganization({
    required int organizationId,
    required String query,
    required String scope,
    required int limit,
    String? cursor,
    CancelToken? cancelToken,
  }) async {
    try {
      return Right(await remoteDataSource.searchOrganization(
        organizationId: organizationId,
        query: query,
        scope: scope,
        limit: limit,
        cursor: cursor,
        cancelToken: cancelToken,
      ));
    } on OrganizationHierarchyDataSourceException catch (error) {
      return Left(error.failure);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(
        ServerFailure('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.'),
      );
    }
  }

  Future<Either<Failure, List<T>>> _guard<T>(
    Future<List<T>> Function() request,
  ) async {
    try {
      return Right(await request());
    } on OrganizationHierarchyDataSourceException catch (error) {
      return Left(error.failure);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(
          ServerFailure('حدث خطأ غير متوقع، يرجى المحاولة لاحقاً.'));
    }
  }
}
