import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/core/di/injection.dart';
import 'package:government_employee_dashboard/core/services/session_service.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final VerifyOtpUseCase verifyOtpUseCase;

  OtpBloc(this.verifyOtpUseCase) : super(const OtpInitial()) {
    on<OtpSubmitted>(_onOtpSubmitted);
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());

    final result = await verifyOtpUseCase(
      sessionId: event.sessionId,
      otp: event.otp,
    );

    await result.fold<Future<void>>(
      (failure) async => emit(OtpFailure(failure.message)),
      (_) async {
        await getIt<SessionService>().loadSession();
        if (!emit.isDone) emit(const OtpSuccess());
      },
    );
  }
}
