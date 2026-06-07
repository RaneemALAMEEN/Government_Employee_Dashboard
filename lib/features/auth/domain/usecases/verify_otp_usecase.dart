import 'package:government_employee_dashboard/features/auth/data/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<String> call({
    required String sessionId,
    required String otp,
  }) {
    return repository.verifyOtp(
      sessionId: sessionId,
      otp: otp,
    );
  }
}