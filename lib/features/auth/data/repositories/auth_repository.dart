abstract class AuthRepository {
  Future<String> login({
    required String username,
    required String password,
  });

  Future<String> verifyOtp({
    required String sessionId,
    required String otp,
  });
}