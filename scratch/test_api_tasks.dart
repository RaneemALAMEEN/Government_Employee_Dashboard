import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (cert, host, port) => true;

  try {
    // 1. Login
    final loginReq = await client.postUrl(Uri.parse('https://dev-education-directorate.abukm.com/api/auth/login'));
    loginReq.headers.contentType = ContentType.json;
    loginReq.write(jsonEncode({
      'userName': 'rawan_doe',
      'password': 'Test123',
    }));
    final loginRes = await loginReq.close();
    final loginBody = await loginRes.transform(utf8.decoder).join();
    print('Login Response: $loginBody');
    final loginData = jsonDecode(loginBody);
    final sessionId = loginData['data']['session_id'];

    // 2. Verify OTP (we try '123456' which is standard dev OTP)
    final otpReq = await client.postUrl(Uri.parse('https://dev-education-directorate.abukm.com/api/auth/verify-otp/login'));
    otpReq.headers.contentType = ContentType.json;
    otpReq.write(jsonEncode({
      'session_id': sessionId,
      'otp': '123456',
    }));
    final otpRes = await otpReq.close();
    final otpBody = await otpRes.transform(utf8.decoder).join();
    print('OTP Response: $otpBody');
    final otpData = jsonDecode(otpBody);
    final token = otpData['data']['token'];

    // 3. Fetch pending-pickup tasks
    final tasksReq = await client.getUrl(Uri.parse('https://dev-education-directorate.abukm.com/api/workflow/tasks/pending-pickup'));
    tasksReq.headers.set('Authorization', 'Bearer $token');
    final tasksRes = await tasksReq.close();
    final tasksBody = await tasksRes.transform(utf8.decoder).join();
    print('Tasks Response: $tasksBody');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
