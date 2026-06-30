import 'dart:convert';
import 'package:cryptography/cryptography.dart';

void main() async {
  print('Starting crypto test...');
  try {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 1000,
      bits: 256,
    );
    print('Deriving key...');
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode('123456')),
      nonce: List<int>.generate(16, (i) => i),
    );
    print('Key derived successfully: ${secretKey != null}');
  } catch (e) {
    print('Error: $e');
  }
}
