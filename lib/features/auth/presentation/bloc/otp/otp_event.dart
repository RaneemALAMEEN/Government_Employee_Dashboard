import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class OtpSubmitted extends OtpEvent {
  final String sessionId;
  final String otp;

  const OtpSubmitted({
    required this.sessionId,
    required this.otp,
  });

  @override
  List<Object?> get props => [sessionId, otp];
}