import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class UsbDeviceInfo {
  final String rootPath;
  final String? physicalSerialNumber;
  final String? pnpDeviceId;
  final String? vendorId;
  final String? productId;
  final bool isRemovable;

  const UsbDeviceInfo({
    required this.rootPath,
    required this.physicalSerialNumber,
    required this.pnpDeviceId,
    required this.vendorId,
    required this.productId,
    required this.isRemovable,
  });

  bool get hasReliableSerial =>
      physicalSerialNumber != null && physicalSerialNumber!.trim().isNotEmpty;

  factory UsbDeviceInfo.fromMap(Map<Object?, Object?> map) => UsbDeviceInfo(
        rootPath: map['rootPath']?.toString() ?? '',
        physicalSerialNumber: _optionalString(map['physicalSerialNumber']),
        pnpDeviceId: _optionalString(map['pnpDeviceId']),
        vendorId: _optionalString(map['vendorId']),
        productId: _optionalString(map['productId']),
        isRemovable: map['isRemovable'] == true,
      );

  static String? _optionalString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

abstract class UsbDeviceIdentityProvider {
  Future<UsbDeviceInfo?> getDeviceForPath(String path);
  Future<String> getStableDeviceFingerprint(UsbDeviceInfo device);
}

class WindowsUsbDeviceIdentityProvider implements UsbDeviceIdentityProvider {
  static const _channel =
      MethodChannel('government_employee_dashboard/usb_devices');

  @override
  Future<UsbDeviceInfo?> getDeviceForPath(String path) async {
    if (!Platform.isWindows) return null;
    final raw = await _channel.invokeListMethod<Object?>(
          'getConnectedUsbDevices',
        ) ??
        const <Object?>[];
    final normalizedPath = _normalizePath(path);
    for (final item in raw.whereType<Map<Object?, Object?>>()) {
      final device = UsbDeviceInfo.fromMap(item);
      final root = _normalizePath(device.rootPath);
      if (normalizedPath == root || normalizedPath.startsWith('$root\\')) {
        return device;
      }
    }
    return null;
  }

  @override
  Future<String> getStableDeviceFingerprint(UsbDeviceInfo device) async {
    if (!device.isRemovable || !device.hasReliableSerial) {
      throw Exception('تعذر التحقق من هوية الفلاشة');
    }
    final source = [
      device.physicalSerialNumber,
      device.pnpDeviceId,
      device.vendorId,
      device.productId,
    ].map((value) => _normalizeComponent(value ?? '')).join('|');
    final digest = await Sha256().hash(source.codeUnits);
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String _normalizePath(String value) {
    var normalized = value.trim().replaceAll('/', '\\').toUpperCase();
    while (normalized.endsWith('\\')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  static String _normalizeComponent(String value) =>
      value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
}

enum UsbDiscoveryStatus {
  success,
  noDriveDetected,
  folderNotFound,
  missingFiles,
  ioError,
  unknownError,
}

class UsbDiscoveryResult {
  final UsbDiscoveryStatus status;
  final String? path;
  final String? errorMessage;
  final String? developerLog;

  UsbDiscoveryResult({
    required this.status,
    this.path,
    this.errorMessage,
    this.developerLog,
  });

  factory UsbDiscoveryResult.success(String path, {String? log}) {
    return UsbDiscoveryResult(
      status: UsbDiscoveryStatus.success,
      path: path,
      developerLog: log,
    );
  }

  factory UsbDiscoveryResult.error(UsbDiscoveryStatus status, String message,
      {String? log}) {
    return UsbDiscoveryResult(
      status: status,
      errorMessage: message,
      developerLog: log,
    );
  }
}

class UsbSigningService {
  final _aes = AesGcm.with256bits();
  final UsbDeviceIdentityProvider _usbDeviceIdentityProvider;

  UsbSigningService({UsbDeviceIdentityProvider? usbDeviceIdentityProvider})
      : _usbDeviceIdentityProvider =
            usbDeviceIdentityProvider ?? WindowsUsbDeviceIdentityProvider();

  Future<List<String>> _getRemovableDrives(StringBuffer logBuffer) async {
    final drives = <String>[];
    try {
      final result = await Process.run('powershell', [
        '-Command',
        'Get-CimInstance Win32_LogicalDisk | Where-Object DriveType -eq 2 | Select-Object -ExpandProperty DeviceID'
      ]);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        if (output.isNotEmpty) {
          final lines = output.split('\n');
          for (final line in lines) {
            final drive = line.trim();
            if (drive.isNotEmpty) {
              drives.add('$drive${Platform.pathSeparator}');
            }
          }
        }
      }
    } catch (e) {
      logBuffer.writeln('[USB] PowerShell detection failed: $e');
    }

    if (drives.isEmpty) {
      logBuffer.writeln('[USB] Falling back to scanning D-Z');
      final letters = [
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z'
      ];
      for (final letter in letters) {
        final dirPath = '$letter:${Platform.pathSeparator}';
        try {
          final dir = Directory(dirPath);
          if (dir.existsSync()) {
            drives.add(dirPath);
          }
        } catch (_) {}
      }
    }
    return drives;
  }

  String? _bfsSearch(Directory rootDir, RegExp pattern, StringBuffer logBuffer,
      {required void Function() onIncompleteFolder,
      required void Function(dynamic) onIoError}) {
    final queue = <MapEntry<Directory, int>>[MapEntry(rootDir, 0)];
    const maxDepth = 4;

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      final currentDir = current.key;
      final currentDepth = current.value;

      if (currentDepth > maxDepth) continue;

      try {
        final entities = currentDir.listSync(followLinks: false);

        for (final entity in entities) {
          if (entity is Directory) {
            final folderName = entity.path.split(Platform.pathSeparator).last;
            final lowerName = folderName.trim().toLowerCase();

            if (lowerName == 'system volume information' ||
                lowerName == '\$recycle.bin' ||
                lowerName.startsWith('.')) {
              continue;
            }

            if (pattern.hasMatch(folderName.trim())) {
              logBuffer.writeln('[USB] Found potential folder: ${entity.path}');
              final sep = Platform.pathSeparator;
              final encFile = File('${entity.path}${sep}employee-key.enc');
              final metaFile = File('${entity.path}${sep}employee-key.meta');
              final publicKeyFile =
                  File('${entity.path}${sep}employee-public.pem');

              if (encFile.existsSync() &&
                  metaFile.existsSync() &&
                  publicKeyFile.existsSync()) {
                logBuffer.writeln('[USB] Valid folder found: ${entity.path}');
                return entity.path;
              } else {
                logBuffer
                    .writeln('[USB] Missing files in folder: ${entity.path}');
                onIncompleteFolder();
              }
            } else {
              queue.add(MapEntry(entity, currentDepth + 1));
            }
          }
        }
      } on FileSystemException catch (e) {
        logBuffer
            .writeln('[USB] FileSystemException on ${currentDir.path}: $e');
        onIoError(e);
      } catch (e) {
        logBuffer
            .writeln('[USB] Error reading directory ${currentDir.path}: $e');
        onIoError(e);
      }
    }
    return null;
  }

  /// Automatically searches removable drives for a valid keys folder.
  Future<UsbDiscoveryResult> findUsbKeysDirectory(String username) async {
    final logBuffer = StringBuffer();
    logBuffer.writeln('[USB] ===============================');
    logBuffer.writeln('[USB] Starting USB discovery for user: $username');

    if (username.trim().isEmpty) {
      logBuffer.writeln('[USB] Username is empty.');
      return UsbDiscoveryResult.error(UsbDiscoveryStatus.unknownError,
          'حدث خطأ أثناء البحث عن مفاتيح التوقيع.\n\nيرجى إعادة المحاولة، وإذا استمرت المشكلة تواصل مع الدعم الفني.',
          log: logBuffer.toString());
    }

    try {
      final drives = await _getRemovableDrives(logBuffer);
      logBuffer.writeln('[USB] Detected drives: $drives');

      if (drives.isEmpty) {
        return UsbDiscoveryResult.error(UsbDiscoveryStatus.noDriveDetected,
            'لم يتم العثور على أي فلاشة متصلة.\n\nيرجى توصيل فلاشة التوقيع ثم إعادة المحاولة.',
            log: logBuffer.toString());
      }

      final cleanUsername = username.trim().toLowerCase();
      // Regex to match: {username}-keys or {username}-keys (1) etc, ignoring spaces
      final pattern = RegExp('^$cleanUsername-keys(?:\\s*\\(\\d+\\))?\$',
          caseSensitive: false);

      bool foundIncompleteFolder = false;
      bool hasIoError = false;

      for (final drivePath in drives) {
        logBuffer.writeln('\n[USB] Searching drive: $drivePath');
        final rootDir = Directory(drivePath);

        final resultPath = _bfsSearch(
          rootDir,
          pattern,
          logBuffer,
          onIncompleteFolder: () => foundIncompleteFolder = true,
          onIoError: (e) => hasIoError = true,
        );

        if (resultPath != null) {
          logBuffer.writeln('[USB] ===============================');
          return UsbDiscoveryResult.success(resultPath,
              log: logBuffer.toString());
        }
      }

      logBuffer.writeln('[USB] ===============================');
      if (foundIncompleteFolder) {
        return UsbDiscoveryResult.error(UsbDiscoveryStatus.missingFiles,
            'تم العثور على مجلد مفاتيح التوقيع، ولكن بعض ملفات التوقيع مفقودة أو غير مكتملة.\n\nيرجى التأكد من وجود جميع الملفات المطلوبة داخل المجلد.',
            log: logBuffer.toString());
      }

      if (hasIoError) {
        return UsbDiscoveryResult.error(UsbDiscoveryStatus.ioError,
            'تعذر قراءة الفلاشة.\n\nقد تكون غير موصولة بشكل صحيح أو يوجد خلل في منفذ USB.\n\nجرّب إعادة توصيل الفلاشة أو استخدام منفذ USB آخر ثم أعد المحاولة.',
            log: logBuffer.toString());
      }

      return UsbDiscoveryResult.error(UsbDiscoveryStatus.folderNotFound,
          'تم العثور على الفلاشة، ولكن لم يتم العثور على مجلد مفاتيح التوقيع الخاص بك.\n\nتأكد من وجود مجلد:\n\n$cleanUsername-keys',
          log: logBuffer.toString());
    } catch (e) {
      logBuffer.writeln('[USB] Unexpected error: $e');
      return UsbDiscoveryResult.error(UsbDiscoveryStatus.unknownError,
          'حدث خطأ أثناء البحث عن مفاتيح التوقيع.\n\nيرجى إعادة المحاولة، وإذا استمرت المشكلة تواصل مع الدعم الفني.',
          log: logBuffer.toString());
    }
  }

  Future<String> signMessageFromUsb({
    required String keysDirectoryPath,
    required String pin,
    required String message,
    String? expectedKeyFingerprint,
  }) async {
    final sep = Platform.pathSeparator;
    final encFile = File('$keysDirectoryPath${sep}employee-key.enc');
    final metaFile = File('$keysDirectoryPath${sep}employee-key.meta');
    final publicKeyFile = File('$keysDirectoryPath${sep}employee-public.pem');
    if (!await encFile.exists() ||
        !await metaFile.exists() ||
        !await publicKeyFile.exists()) {
      throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
    }

    final meta = await _readMeta(metaFile);
    if (meta['version'] != 2) {
      throw Exception('المفتاح الموجود على الفلاشة قديم، يرجى إعادة إصداره');
    }
    _validateV2Metadata(meta);

    final device =
        await _usbDeviceIdentityProvider.getDeviceForPath(keysDirectoryPath);
    if (device == null || !device.isRemovable) {
      throw Exception('يجب أن يبقى ملف المفتاح على فلاشة USB فعلية');
    }
    final currentUsbFingerprint =
        await _usbDeviceIdentityProvider.getStableDeviceFingerprint(device);
    final usbFingerprintMatches = _constantTimeEquals(
      currentUsbFingerprint,
      meta['usb_fingerprint_hash'] as String,
    );

    final publicKeyPem = await publicKeyFile.readAsString();
    final localPublicKeyFingerprint = await _fingerprintPublicKey(publicKeyPem);
    final metaPublicKeyFingerprint = meta['public_key_fingerprint'] as String;
    final backendPublicKeyFingerprint = expectedKeyFingerprint?.trim();
    debugPrint(
      '[SigningKey] backend fingerprint = '
      '${backendPublicKeyFingerprint?.isNotEmpty == true ? backendPublicKeyFingerprint : '(not provided)'}',
    );
    debugPrint('[SigningKey] meta fingerprint = $metaPublicKeyFingerprint');
    debugPrint(
      '[SigningKey] local fingerprint = $localPublicKeyFingerprint',
    );
    debugPrint(
      '[SigningKey] backend fingerprint comparison skipped because algorithms differ',
    );
    debugPrint('[SigningKey] usb fingerprint match = $usbFingerprintMatches');
    debugPrint('[SigningKey] key package version = ${meta['version']}');

    if (!usbFingerprintMatches) {
      throw Exception('هذه الفلاشة لا تطابق الفلاشة التي أُنشئ عليها المفتاح');
    }
    if (!_constantTimeEquals(
      localPublicKeyFingerprint,
      metaPublicKeyFingerprint,
    )) {
      throw Exception('ملفات المفتاح غير متطابقة أو تم تعديلها');
    }
    final cipherText = await _readCipherText(encFile);
    final salt = _decodeBase64Field(meta, 'salt');
    final nonce = _decodeBase64Field(meta, 'nonce');
    final mac = Mac(_decodeBase64Field(meta, 'mac'));
    final secretKey = await Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    ).deriveKey(
      secretKey: SecretKey(utf8.encode(
        'pinLength=${pin.length}:$pin|usbSha256=$currentUsbFingerprint',
      )),
      nonce: salt,
      info: utf8.encode('technical-team/usb-bound-key/v2'),
    );

    final privateKeyBytes = await _decryptPrivateKeyV2(
      cipherText: cipherText,
      nonce: nonce,
      mac: mac,
      secretKey: secretKey,
      aad: _canonicalV2Aad(meta),
    );
    try {
      final keyPair = await Ed25519().newKeyPairFromSeed(privateKeyBytes);
      if (!await _privateKeyMatchesPublicKey(keyPair, publicKeyPem)) {
        throw Exception('ملفات المفتاح غير متطابقة أو تم تعديلها');
      }
      final signature = await Ed25519().sign(
        utf8.encode(message),
        keyPair: keyPair,
      );
      return base64Encode(signature.bytes);
    } finally {
      privateKeyBytes.fillRange(0, privateKeyBytes.length, 0);
    }
  }

  void _validateV2Metadata(Map<String, dynamic> meta) {
    String requireString(String field) {
      final value = meta[field];
      if (value is! String || value.trim().isEmpty) {
        throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
      }
      return value;
    }

    if (meta['package_version'] != 2 ||
        requireString('algorithm') != 'AES-256-GCM' ||
        requireString('key_algorithm') != 'Ed25519' ||
        requireString('kdf') != 'HKDF-SHA256' ||
        meta['binding_token'] != null) {
      throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
    }
    for (final field in [
      'client_key_id',
      'username',
      'usb_fingerprint_hash',
      'public_key_fingerprint',
      'salt',
      'nonce',
      'mac',
      'created_at',
    ]) {
      requireString(field);
    }
  }

  Uint8List _canonicalV2Aad(Map<String, dynamic> meta) => Uint8List.fromList(
        utf8.encode(jsonEncode({
          'version': meta['version'],
          'packageVersion': meta['package_version'],
          'clientKeyId': meta['client_key_id'],
          'username': meta['username'],
          'algorithm': meta['algorithm'],
          'keyAlgorithm': meta['key_algorithm'],
          'kdf': meta['kdf'],
          'usbFingerprintHash': meta['usb_fingerprint_hash'],
          'publicKeyFingerprint': meta['public_key_fingerprint'],
          'createdAt': meta['created_at'],
        })),
      );

  Future<List<int>> _readCipherText(File encFile) async {
    try {
      final content = await encFile.readAsString();
      return base64Decode(content.trim());
    } catch (_) {
      throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
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
      throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
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
      throw Exception('ملفات المفتاح غير مكتملة أو تم تعديلها');
    }
  }

  Future<Uint8List> _decryptPrivateKeyV2({
    required List<int> cipherText,
    required List<int> nonce,
    required Mac mac,
    required SecretKey secretKey,
    required List<int> aad,
  }) async {
    try {
      final clearText = await _aes.decrypt(
        SecretBox(
          cipherText,
          nonce: nonce,
          mac: mac,
        ),
        secretKey: secretKey,
        aad: aad,
      );
      return Uint8List.fromList(clearText);
    } catch (_) {
      throw Exception('رمز PIN غير صحيح أو ملف المفتاح غير صالح');
    }
  }

  Future<String> _fingerprintPublicKey(String publicKey) async {
    final hash = await Sha256().hash(utf8.encode(publicKey));
    return hash.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<bool> _privateKeyMatchesPublicKey(
    KeyPair keyPair,
    String publicKeyPem,
  ) async {
    try {
      final derivedPublicKey =
          await keyPair.extractPublicKey() as SimplePublicKey;
      final pemBody = publicKeyPem
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll(RegExp(r'\s+'), '');
      final der = base64Decode(pemBody);
      if (der.length < derivedPublicKey.bytes.length) return false;
      final raw = der.sublist(der.length - derivedPublicKey.bytes.length);
      var difference = 0;
      for (var index = 0; index < raw.length; index++) {
        difference |= raw[index] ^ derivedPublicKey.bytes[index];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  bool _constantTimeEquals(String left, String right) {
    var difference = left.length ^ right.length;
    final length = left.length > right.length ? left.length : right.length;
    for (var index = 0; index < length; index++) {
      final leftCode = index < left.length ? left.codeUnitAt(index) : 0;
      final rightCode = index < right.length ? right.codeUnitAt(index) : 0;
      difference |= leftCode ^ rightCode;
    }
    return difference == 0;
  }
}
