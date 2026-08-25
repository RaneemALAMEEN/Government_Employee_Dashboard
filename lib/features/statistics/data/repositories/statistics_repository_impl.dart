import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_employee_details_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../domain/entities/statistics_paginated_result.dart';
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
  Future<Either<Failure, StatisticsPaginatedResult<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({
    required List<int> departmentIds,
    required int limit,
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
    required int limit,
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
