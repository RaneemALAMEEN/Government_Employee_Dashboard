import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

class UsbSigningService {
  final _aes = AesGcm.with256bits();

  /// Automatically searches all available drive letters for folder `{username}-keys`
  /// containing both `employee-key.enc` and `employee-key.meta`.
  Future<String?> findUsbKeysDirectory(String username) async {
    if (username.trim().isEmpty) return null;

    final trimmed = username.trim();
    final folderNames = [
      '$trimmed-keys',
      '${trimmed.toLowerCase()}-keys',
    ].toSet();

    final driveLetters = [
      'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'C'
    ];

    final sep = Platform.pathSeparator;

    for (final drive in driveLetters) {
      for (final folderName in folderNames) {
        final dirPath = '$drive:$sep$folderName';
        try {
          final dir = Directory(dirPath);
          if (dir.existsSync()) {
            final encFile = File('$dirPath${sep}employee-key.enc');
            final metaFile = File('$dirPath${sep}employee-key.meta');
            if (encFile.existsSync() && metaFile.existsSync()) {
              return dirPath;
            }
          }
        } catch (_) {
          // Ignore unmounted/unreadable drives
        }
      }
    }

    return null;
  }

  Future<String> signMessageFromUsb({
    required String keysDirectoryPath,
    required String pin,
    required String message,
  }) async {
    final encFile = File('$keysDirectoryPath\\employee-key.enc');
    final metaFile = File('$keysDirectoryPath\\employee-key.meta');

    if (!await encFile.exists() || !await metaFile.exists()) {
      throw Exception(
        'لم يتم العثور على ملفات مفاتيح التوقيع داخل المجلد المحدد',
      );
    }

    final cipherText = await _readCipherText(encFile);
    final meta = await _readMeta(metaFile);

    final salt = _decodeBase64Field(meta, 'salt');
    final nonce = _decodeBase64Field(meta, 'nonce');
    final mac = Mac(_decodeBase64Field(meta, 'mac'));
    final iterations = _readIterations(meta);

    final secretKey = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    ).deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    final privateKeyBase64Bytes = await _decryptPrivateKey(
      cipherText: cipherText,
      nonce: nonce,
      mac: mac,
      secretKey: secretKey,
    );

    final privateKeyBytes = _decodePrivateKey(privateKeyBase64Bytes);

    final keyPair = await Ed25519().newKeyPairFromSeed(privateKeyBytes);

    final signature = await Ed25519().sign(
      utf8.encode(message),
      keyPair: keyPair,
    );

    return base64Encode(signature.bytes);
  }

  Future<List<int>> _readCipherText(File encFile) async {
    try {
      final content = await encFile.readAsString();
      return base64Decode(content.trim());
    } catch (_) {
      throw Exception('ملف employee-key.enc تالف أو غير صالح');
    }
  }

  Future<Map<String, dynamic>> _readMeta(File metaFile) async {
    try {
      final content = await metaFile.readAsString();
      final decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        throw Exception();
      }

      return decoded;
    } catch (_) {
      throw Exception('ملف employee-key.meta تالف أو غير صالح');
    }
  }

  List<int> _decodeBase64Field(
    Map<String, dynamic> meta,
    String fieldName,
  ) {
    try {
      final value = meta[fieldName]?.toString();

      if (value == null || value.isEmpty) {
        throw Exception();
      }

      return base64Decode(value);
    } catch (_) {
      throw Exception('قيمة $fieldName داخل ملف employee-key.meta غير صالحة');
    }
  }

  int _readIterations(Map<String, dynamic> meta) {
    final value = meta['iterations'];

    if (value is int) return value;

    final parsed = int.tryParse(value.toString());

    if (parsed == null || parsed <= 0) {
      throw Exception('قيمة iterations داخل ملف employee-key.meta غير صالحة');
    }

    return parsed;
  }

  Future<List<int>> _decryptPrivateKey({
    required List<int> cipherText,
    required List<int> nonce,
    required Mac mac,
    required SecretKey secretKey,
  }) async {
    try {
      return await _aes.decrypt(
        SecretBox(
          cipherText,
          nonce: nonce,
          mac: mac,
        ),
        secretKey: secretKey,
      );
    } catch (_) {
      throw Exception('رمز PIN غير صحيح أو أن ملف المفتاح تالف');
    }
  }

  List<int> _decodePrivateKey(List<int> privateKeyBase64Bytes) {
    try {
      final privateKeyBase64 = utf8.decode(privateKeyBase64Bytes);
      return base64Decode(privateKeyBase64);
    } catch (_) {
      throw Exception('تعذر قراءة المفتاح الخاص بعد فك التشفير');
    }
  }
}
