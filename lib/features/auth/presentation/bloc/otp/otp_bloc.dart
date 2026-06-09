import 'package:flutter_bloc/flutter_bloc.dart';

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

    result.fold(
      (failure) => emit(OtpFailure(failure.message)),
      (_) => emit(const OtpSuccess()),
    );
  }
}