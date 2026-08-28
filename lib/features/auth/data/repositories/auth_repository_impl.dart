import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../models/user_role_model.dart';

import '../models/user_permissions_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final SecureStorageService storage;

  AuthRepositoryImpl(this.remote, this.storage);

  @override
  Future<Either<Failure, LoginResponse>> login({
    required String userName,
    required String password,
  }) async {
    final result = await remote.login(userName, password);
    return result.fold<Either<Failure, LoginResponse>>(
      (failure) => Left(failure),
      (data) {
        try {
          return Right(
            LoginResponseModel.fromJson(data as Map<String, dynamic>),
          );
        } catch (_) {
          return const Left(ServerFailure('تعذّر قراءة استجابة الخادم.'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, AuthResponse>> verifyOtp({
    required String sessionId,
    required String otp,
  }) async {
    final result = await remote.verifyOtp(sessionId: sessionId, otp: otp);
    return result.fold<Future<Either<Failure, AuthResponse>>>(
      (failure) async => Left(failure),
      (data) async {
        try {
          final authResponse =
              AuthResponseModel.fromJson(data as Map<String, dynamic>);

          // Save tokens first so subsequent authenticated requests succeed
          await storage.saveTokens(
            token: authResponse.token,
            refreshToken: authResponse.refreshToken,
          );
          await storage.saveDepartmentIds(authResponse.departmentIds);

          final userModel = authResponse.user as UserModel;
          await storage.writeUser(userModel);

          if (authResponse.roles.isNotEmpty) {
            final roleModels = authResponse.roles.cast<UserRoleModel>();
            await storage.writeRoles(roleModels);
            await storage.writeRole(roleModels.first);
          }

          // Fetch user permissions before completing login
          final userId = userModel.id;
          if (userId > 0) {
            final permResult = await remote.getUserPermissions(userId);
            final permFailureOrSuccess = permResult.fold<Either<Failure, List<String>>>(
              (failure) => Left(failure),
              (permData) {
                try {
                  final permModel = UserPermissionsResponseModel.fromJson(
                    permData as Map<String, dynamic>,
                  );
                  return Right(permModel.permissionCodes);
                } catch (_) {
                  return const Left(
                    ServerFailure('تعذّر تحليل صلاحيات المستخدم من الخادم.'),
                  );
                }
              },
            );

            if (permFailureOrSuccess.isLeft()) {
              // Revert saved credentials so incomplete session is not preserved
              await storage.clear();
              return Left(
                permFailureOrSuccess.fold(
                  (f) => f,
                  (_) => const ServerFailure('تعذّر جلب صلاحيات المستخدم.'),
                ),
              );
            }

            final permissionCodes =
                permFailureOrSuccess.getOrElse(() => <String>[]);
            await storage.writePermissions(permissionCodes);
          }

          return Right(authResponse);
        } catch (_) {
          await storage.clear();
          return const Left(
            ServerFailure('تعذّر إكمال تسجيل الدخول، يرجى المحاولة لاحقًا.'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, Set<String>>> fetchUserPermissions(int userId) async {
    final result = await remote.getUserPermissions(userId);
    return result.fold<Future<Either<Failure, Set<String>>>>(
      (failure) async => Left(failure),
      (data) async {
        try {
          final permModel = UserPermissionsResponseModel.fromJson(
            data as Map<String, dynamic>,
          );
          final codes = permModel.permissionCodes;
          await storage.writePermissions(codes);
          return Right(codes.toSet());
        } catch (_) {
          return const Left(ServerFailure('تعذّر تحليل صلاحيات المستخدم.'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> verifyAppPin(String pin) async {
    final result = await remote.verifyAppPin(pin);
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> changePin({
    required String oldPin,
    required String newPin,
    required String confirmNewPin,
  }) async {
    final result = await remote.changePin(
      oldPin: oldPin,
      newPin: newPin,
      confirmNewPin: confirmNewPin,
    );
    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
