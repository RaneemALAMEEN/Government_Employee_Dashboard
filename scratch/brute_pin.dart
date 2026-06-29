import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

Uint8List deriveScryptKey(String pin, Uint8List salt, int n, int r, int p, int dkLen) {
  final derivator = pc.KeyDerivator('scrypt');
  final params = pc.ScryptParameters(n, r, p, dkLen, salt);
  derivator.init(params);
  return derivator.process(Uint8List.fromList(utf8.encode(pin)));
}

void main() async {
  final aes = AesGcm.with256bits();
  final salt = base64Decode('MI12MuEIbR+fXANTNt/ZbQ==');
  final iv = base64Decode('5UX2wY3BUE0pkYUG');
  final authTag = base64Decode('YNvgfDUSrM83dS3RfH/ztA==');
  final cipherText = base64Decode(
    '1H4/+KEUfqIPqnRPHAUrh1/emQeXI1RERxvehdAZkxwAziYIbEoqBWcRzP3TaDtRgmZ+4b/5gwAvSPBa2dTEfkJhFcKsFdsYYMQITIH5MI+Ufh3MgrO0sS/t922OGECbs4+aGNEZsFy0B6wMFha8VML/TvOSuyT32E4='
  );

  final candidatePins = [
    '123456',
    '000000',
    '111111',
    '12345678',
    '1234',
    '888888',
    '999999',
    '123123',
    '112233',
    '321321'
  ];

  for (final pin in candidatePins) {
    try {
      final keyBytes = deriveScryptKey(pin, salt, 16384, 8, 1, 32);
      final secretKey = SecretKey(keyBytes);
      final secretBox = SecretBox(
        cipherText,
        nonce: iv,
        mac: Mac(authTag),
      );
      final decrypted = await aes.decrypt(secretBox, secretKey: secretKey);
      print('SUCCESS! PIN is: $pin');
      print('Decrypted bytes: $decrypted');
      print('Decrypted string: ${utf8.decode(decrypted)}');
      return;
    } catch (_) {
      // Ignore decryption failure and try next PIN
    }
  }
  print('None of the candidate PINs worked.');
}
