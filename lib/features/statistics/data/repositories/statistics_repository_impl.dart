import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/employee_search_result_entity.dart';
import '../../domain/entities/process_search_result_entity.dart';
import '../../domain/entities/statistics_employee_details_entity.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_paginated_result.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  const StatisticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, StatisticsEmployeeDetailsEntity>> getEmployeeDetails(
      {required int employeeId}) async {
    try {
      return Right(
        await remoteDataSource.getEmployeeDetails(employeeId: employeeId),
      );
    } on StatisticsDataSourceException catch (e) {
      return Left(e.failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, EmployeeSearchResultEntity>> searchEmployees({
    String? query,
    String? cursor,
    int limit = 6,
  }) async {
    try {
      final data = await remoteDataSource.searchEmployees(
        query: query,
        cursor: cursor,
        limit: limit,
      );
      return Right(data);
    } on StatisticsDataSourceException catch (e) {
      return Left(e.failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, ProcessSearchResultEntity>> searchProcessDefinitions({
    required int organizationId,
    String? query,
    String? cursor,
    int limit = 6,
    int? typeTransId,
    bool? isComplaint,
  }) async {
    try {
      final data = await remoteDataSource.searchProcessDefinitions(
        organizationId: organizationId,
        query: query,
        cursor: cursor,
        limit: limit,
        typeTransId: typeTransId,
        isComplaint: isComplaint,
      );
      return Right(data);
    } on StatisticsDataSourceException catch (e) {
      return Left(e.failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, StatisticsPaginatedResult<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
  }) async {
    try {
      final data = await remoteDataSource.getEmployeesByDepartments(
        departmentIds: departmentIds,
        limit: limit,
        cursor: cursor,
      );
      return Right(data);
    } on StatisticsDataSourceException catch (e) {
      return Left(e.failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, StatisticsPaginatedResult<StatisticsProcessEntity>>>
      getProcessDefinitionStats({
    required List<int> departmentIds,
    int limit = 6,
    String? cursor,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final data = await remoteDataSource.getProcessDefinitionStats(
        departmentIds: departmentIds,
        limit: limit,
        cursor: cursor,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Right(data);
    } on StatisticsDataSourceException catch (e) {
      return Left(e.failure);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
