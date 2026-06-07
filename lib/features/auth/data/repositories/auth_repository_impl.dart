import 'package:government_employee_dashboard/features/auth/data/repositories/auth_repository.dart';

import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/verify_otp_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<String> login({
    required String username,
    required String password,
  }) {
    return remote.login(
      LoginRequestModel(
        userName: username,
        password: password,
      ),
    );
  }

  @override
  Future<String> verifyOtp({
    required String sessionId,
    required String otp,
  }) {
    return remote.verifyOtp(
      VerifyOtpRequestModel(
        sessionId: sessionId,
        otp: otp,
      ),
    );
  }
}