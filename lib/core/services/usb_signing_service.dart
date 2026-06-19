import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

class UsbSigningService {
  final _aes = AesGcm.with256bits();

  Future<String> signMessageFromUsb({
    required String keysDirectoryPath,
    required String pin,
    required String message,
  }) async {
    final encFile = File('$keysDirectoryPath\\employee-key.enc');
    final metaFile = File('$keysDirectoryPath\\employee-key.meta');

    if (!await encFile.exists()) {
      throw Exception('ملف المفتاح الخاص غير موجود على الفلاشة');
    }

    if (!await metaFile.exists()) {
      throw Exception('ملف بيانات المفتاح غير موجود على الفلاشة');
    }

    final cipherText = base64Decode(await encFile.readAsString());

    final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;

    final salt = base64Decode(meta['salt'].toString());
    final nonce = base64Decode(meta['nonce'].toString());
    final mac = Mac(base64Decode(meta['mac'].toString()));

    final iterations = meta['iterations'] is int
        ? meta['iterations'] as int
        : int.parse(meta['iterations'].toString());

    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );

    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    final secretBox = SecretBox(
      cipherText,
      nonce: nonce,
      mac: mac,
    );

    final privateKeyBase64Bytes = await _aes.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    final privateKeyBase64 = utf8.decode(privateKeyBase64Bytes);
    final privateKeyBytes = base64Decode(privateKeyBase64);

    final algorithm = Ed25519();

    final keyPair = await algorithm.newKeyPairFromSeed(privateKeyBytes);

    final signature = await algorithm.sign(
      utf8.encode(message),
      keyPair: keyPair,
    );

    return base64Encode(signature.bytes);
  }
}