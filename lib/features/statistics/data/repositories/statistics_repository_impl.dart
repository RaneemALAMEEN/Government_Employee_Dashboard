import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  const StatisticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<StatisticsEmployeeEntity>>>
      getEmployeesByDepartments({required List<int> departmentIds}) async {
    try {
      final data = await remoteDataSource.getEmployeesByDepartments(departmentIds: departmentIds);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, List<StatisticsProcessEntity>>>
      getProcessDefinitionStats({required List<int> departmentIds}) async {
    try {
      final data = await remoteDataSource.getProcessDefinitionStats(departmentIds: departmentIds);
      return Right(data);
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
