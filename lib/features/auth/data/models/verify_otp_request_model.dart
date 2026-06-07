class VerifyOtpRequestModel {
  final String sessionId;
  final String otp;

  VerifyOtpRequestModel({
    required this.sessionId,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "session_id": sessionId,
      "otp": otp,
    };
  }
}