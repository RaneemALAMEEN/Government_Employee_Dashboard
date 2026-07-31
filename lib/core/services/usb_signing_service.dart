import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';

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

  factory UsbDiscoveryResult.error(UsbDiscoveryStatus status, String message, {String? log}) {
    return UsbDiscoveryResult(
      status: status,
      errorMessage: message,
      developerLog: log,
    );
  }
}

class UsbSigningService {
  final _aes = AesGcm.with256bits();

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
      final letters = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];
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

  String? _bfsSearch(
    Directory rootDir, 
    RegExp pattern, 
    StringBuffer logBuffer, {
    required void Function() onIncompleteFolder, 
    required void Function(dynamic) onIoError
  }) {
    final queue = <MapEntry<Directory, int>>[MapEntry(rootDir, 0)];
    final maxDepth = 4;
    
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
              
              if (encFile.existsSync() && metaFile.existsSync()) {
                 logBuffer.writeln('[USB] Valid folder found: ${entity.path}');
                 return entity.path;
              } else {
                 logBuffer.writeln('[USB] Missing files in folder: ${entity.path}');
                 onIncompleteFolder();
              }
            } else {
              queue.add(MapEntry(entity, currentDepth + 1));
            }
          }
        }
      } on FileSystemException catch (e) {
        logBuffer.writeln('[USB] FileSystemException on ${currentDir.path}: $e');
        onIoError(e);
      } catch (e) {
        logBuffer.writeln('[USB] Error reading directory ${currentDir.path}: $e');
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
      return UsbDiscoveryResult.error(
        UsbDiscoveryStatus.unknownError,
        'حدث خطأ أثناء البحث عن مفاتيح التوقيع.\n\nيرجى إعادة المحاولة، وإذا استمرت المشكلة تواصل مع الدعم الفني.',
        log: logBuffer.toString()
      );
    }

    try {
      final drives = await _getRemovableDrives(logBuffer);
      logBuffer.writeln('[USB] Detected drives: $drives');

      if (drives.isEmpty) {
        return UsbDiscoveryResult.error(
          UsbDiscoveryStatus.noDriveDetected,
          'لم يتم العثور على أي فلاشة متصلة.\n\nيرجى توصيل فلاشة التوقيع ثم إعادة المحاولة.',
          log: logBuffer.toString()
        );
      }

      final cleanUsername = username.trim().toLowerCase();
      // Regex to match: {username}-keys or {username}-keys (1) etc, ignoring spaces
      final pattern = RegExp('^$cleanUsername-keys(?:\\s*\\(\\d+\\))?\$', caseSensitive: false);

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
          print(logBuffer.toString()); // Print logs to developer console
          return UsbDiscoveryResult.success(resultPath, log: logBuffer.toString());
        }
      }

      logBuffer.writeln('[USB] ===============================');
      print(logBuffer.toString());

      if (foundIncompleteFolder) {
        return UsbDiscoveryResult.error(
          UsbDiscoveryStatus.missingFiles,
          'تم العثور على مجلد مفاتيح التوقيع، ولكن بعض ملفات التوقيع مفقودة أو غير مكتملة.\n\nيرجى التأكد من وجود جميع الملفات المطلوبة داخل المجلد.',
          log: logBuffer.toString()
        );
      }

      if (hasIoError) {
        return UsbDiscoveryResult.error(
          UsbDiscoveryStatus.ioError,
          'تعذر قراءة الفلاشة.\n\nقد تكون غير موصولة بشكل صحيح أو يوجد خلل في منفذ USB.\n\nجرّب إعادة توصيل الفلاشة أو استخدام منفذ USB آخر ثم أعد المحاولة.',
          log: logBuffer.toString()
        );
      }

      return UsbDiscoveryResult.error(
        UsbDiscoveryStatus.folderNotFound,
        'تم العثور على الفلاشة، ولكن لم يتم العثور على مجلد مفاتيح التوقيع الخاص بك.\n\nتأكد من وجود مجلد:\n\n$cleanUsername-keys',
        log: logBuffer.toString()
      );

    } catch (e) {
      logBuffer.writeln('[USB] Unexpected error: $e');
      print(logBuffer.toString());
      return UsbDiscoveryResult.error(
        UsbDiscoveryStatus.unknownError,
        'حدث خطأ أثناء البحث عن مفاتيح التوقيع.\n\nيرجى إعادة المحاولة، وإذا استمرت المشكلة تواصل مع الدعم الفني.',
        log: logBuffer.toString()
      );
    }
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
