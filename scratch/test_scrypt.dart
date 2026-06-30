import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

void main() async {
  print('Starting Scrypt testing...');
  try {
    // Check if Scrypt class is available in pointycastle
    final scrypt = pc.KeyDerivator('scrypt');
    final params = pc.ScryptParameters(
      16384, // N
      8,     // r
      1,     // p
      32,    // keyLength
      base64Decode('MI12MuEIbR+fXANTNt/ZbQ=='), // salt
    );
    scrypt.init(params);
    print('Scrypt object created and initialized successfully.');

    final derivedKeyBytes = scrypt.process(Uint8List.fromList(utf8.encode('123456')));
    print('Secret key derived successfully!');
    print('Key bytes length: ${derivedKeyBytes.length}');
    print('Derived Key Base64: ${base64Encode(derivedKeyBytes)}');
  } catch (e) {
    print('Error: $e');
  }
}

