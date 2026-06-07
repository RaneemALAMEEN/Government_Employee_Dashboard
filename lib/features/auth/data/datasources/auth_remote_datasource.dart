import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/verify_otp_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(LoginRequestModel model);

  Future<String> verifyOtp(VerifyOtpRequestModel model);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final dio = DioClient.dio;

  @override
  Future<String> login(LoginRequestModel model) async {
    final response = await dio.post(
      '/auth/login',
      data: model.toJson(),
    );

    return response.data['data']['session_id'];
  }

  @override
  Future<String> verifyOtp(VerifyOtpRequestModel model) async {
    final response = await dio.post(
      '/auth/verify-otp/login',
      data: model.toJson(),
    );

    return response.data['data']['token'];
  }
}