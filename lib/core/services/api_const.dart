import 'package:flutter_dotenv/flutter_dotenv.dart';

/// All API endpoints used across the app.
///
/// Mirrors the backend routes mounted in `DirectorateOFEducation/src/app.js`.
/// The backend issues a short-lived access token plus a rotating refresh
/// token. The client refreshes via [refresh] on 401 and revokes the refresh
/// token via [logout].
///
/// Paths are relative (no leading slash); Dio resolves them against
/// [ApiConstants.baseUrl].
class EndPoints {
  const EndPoints();

  // ===== auth — password + OTP flow (2 steps) =====
  String get login => 'api/auth/login'; // step 1 → session_id + sends OTP
  String get verifyLoginOtp =>
      'api/auth/verify-otp/login'; // step 2 → token + refreshToken + user + roles
  String get myTransactionCounts => 'api/transaction/my/counts';
  // ===== auth — token lifecycle =====
  String get refresh =>
      'api/auth/refresh'; // { refreshToken } → { token, refreshToken }
  String get logout =>
      'api/auth/logout'; // { refreshToken } → revokes refresh token
  String get myTransactions => 'api/transaction/my';
  String get typeProcess => 'api/typeProcess';

  String processDefinitionsAuth(int typeProcessId) =>
      'api/process_definitions/auth/$typeProcessId';
  String get uploadTransactionFile => '/api/transaction/files/upload';
  String stageConfig(int processId) => 'api/stage_config/config/$processId';
  String signingChallenge(int processId) =>
      'api/transaction/process/$processId/submit-documents/signing-challenge';
  String completeSignedTransaction(int transactionId) =>
      'api/transaction/$transactionId/submit-documents/complete';
}

/// Base API configuration. The base url is read from the loaded environment
/// file (`env/*.env`) so it can change per flavor (dev / stage / prod)
/// without touching the code.
class ApiConstants {
  const ApiConstants();

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';
}
