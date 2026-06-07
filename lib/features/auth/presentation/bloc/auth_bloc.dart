import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/secure_storage/secure_storage_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  String? _sessionId;

  AuthBloc({required this.loginUseCase, required this.verifyOtpUseCase})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);

    on<VerifyOtpRequested>(_onVerifyOtp);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      final sessionId = await loginUseCase(
        username: event.username,
        password: event.password,
      );

      _sessionId = sessionId;

      emit(OtpSentState(sessionId));
    } catch (e) {
     emit(
  AuthErrorState(
    'اسم المستخدم أو كلمة المرور غير صحيحة',
  ),
);
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await verifyOtpUseCase(
        sessionId: _sessionId!,
        otp: event.otp,
      );

      await SecureStorageService.saveToken(token);

      emit(AuthenticatedState());
    } catch (e) {
      emit(AuthErrorState('رمز التحقق غير صحيح'));
    }
  }
}
