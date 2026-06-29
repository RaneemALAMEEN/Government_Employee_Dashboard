import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

Uint8List hexDecode(String hex) {
  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < bytes.length; i++) {
    final slice = hex.substring(i * 2, i * 2 + 2);
    bytes[i] = int.parse(slice, radix: 16);
  }
  return bytes;
}

Uint8List deriveScryptKey(String pin, Uint8List salt, int n, int r, int p, int dkLen) {
  final derivator = pc.KeyDerivator('scrypt');
  final params = pc.ScryptParameters(n, r, p, dkLen, salt);
  derivator.init(params);
  return derivator.process(Uint8List.fromList(utf8.encode(pin)));
}

void main() async {
  print('Starting scrypt decryption and signature test...');
  try {
    final pin = '123456';
    final salt = base64Decode('MI12MuEIbR+fXANTNt/ZbQ==');
    final iv = base64Decode('5UX2wY3BUE0pkYUG');
    final authTag = base64Decode('YNvgfDUSrM83dS3RfH/ztA==');
    final cipherText = base64Decode(
      '1H4/+KEUfqIPqnRPHAUrh1/emQeXI1RERxvehdAZkxwAziYIbEoqBWcRzP3TaDtRgmZ+4b/5gwAvSPBa2dTEfkJhFcKsFdsYYMQITIH5MI+Ufh3MgrO0sS/t922OGECbs4+aGNEZsFy0B6wMFha8VML/TvOSuyT32E4='
    );
    final message = 'DOE-TX-SIGN|v1|93159bac-7d26-4603-9918-a87c61027d4a|f4ee6815-6777-11f1-a5bb-2e302e717c8a|1|Activity_1503q48|386a8292975d814976a76bb3d97f21d08665b101bf6ede643bdc8b44fd8e82c1|2026-06-20T00:01:30.055Z|49|3c2160816ef8013e3ebdb04242ee2a3e44c390beb4dc27c4208b55d7a6fc3859';

    // Derive key
    final derivedKeyBytes = deriveScryptKey(pin, salt, 16384, 8, 1, 32);
    print('Derived Key successfully: ${base64Encode(derivedKeyBytes)}');

    // Decrypt using cryptography package
    final aes = AesGcm.with256bits();
    final secretKey = SecretKey(derivedKeyBytes);
    final secretBox = SecretBox(
      cipherText,
      nonce: iv,
      mac: Mac(authTag),
    );

    final decryptedBytes = await aes.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    final privateKeyHex = utf8.decode(decryptedBytes);
    print('Decrypted private key Hex string: $privateKeyHex');
    final privateKeyBytes = hexDecode(privateKeyHex);
    print('Private key bytes length: ${privateKeyBytes.length}');

    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);
    final pubKey = await keyPair.extractPublicKey();
    print('Derived Public Key base64: ${base64Encode(pubKey.bytes)}');

    // Sign message
    final signature = await algorithm.sign(
      utf8.encode(message),
      keyPair: keyPair,
    );

    print('Signature generated successfully!');
    print('Signature base64: ${base64Encode(signature.bytes)}');

  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
