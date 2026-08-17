import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Shared helper for downloading files into a dedicated app folder
/// inside the device's Downloads directory.
///
/// Folder name: "ملفات من تطبيق مديرية التربية"
class AppFileDownloader {
  AppFileDownloader._();

  static const String _folderName = 'ملفات من تطبيق مديرية التربية';

  /// Returns the app's dedicated download directory, creating it if needed.
  static Future<Directory> getAppDownloadsDir() async {
    // Try to use the system Downloads folder first (Android/Windows/Linux).
    // Falls back to application documents directory on iOS or if unavailable.
    Directory? baseDir = await getDownloadsDirectory();
    baseDir ??= await getApplicationDocumentsDirectory();

    final appDir = Directory('${baseDir.path}${Platform.pathSeparator}$_folderName');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  /// Builds a clean, descriptive filename for a downloaded file.
  ///
  /// [applicantName] – صاحب المعاملة (e.g. "أحمد محمد").
  /// [documentType]  – وصف نوع الوثيقة (e.g. "الوثيقة النهائية", "صورة هوية", "قالب طلب إجازة").
  /// [originalFilename] – الاسم الأصلي للملف من الخادم (e.g. "file_123.png").
  /// [contentType] – نوع محتوى الاستجابة (e.g. "image/png").
  /// [bytes] – بايتات الملف للتعرف على صيغتها عبر التوقيع الرقمي (Magic Bytes).
  /// [fallbackExtension] – الامتداد البديل إذا لم يتم اكتشاف امتداد مناسب.
  static String buildFilename({
    String? applicantName,
    String? documentType,
    required String originalFilename,
    String? contentType,
    Uint8List? bytes,
    String? fallbackExtension,
  }) {
    final ext = extractExtension(
      originalFilename,
      contentType: contentType,
      bytes: bytes,
      fallbackExtension: fallbackExtension,
    );

    final parts = <String>[];

    final cleanApplicant = (applicantName ?? '').trim();
    if (cleanApplicant.isNotEmpty) {
      parts.add(cleanApplicant);
    }

    final cleanType = (documentType ?? '').trim();
    if (cleanType.isNotEmpty) {
      parts.add(cleanType);
    }

    var cleanOriginal = originalFilename.trim();
    cleanOriginal = cleanOriginal.split('?').first.split('#').first;
    final lastDot = cleanOriginal.lastIndexOf('.');
    if (lastDot != -1 && lastDot < cleanOriginal.length - 1) {
      cleanOriginal = cleanOriginal.substring(0, lastDot);
    }
    cleanOriginal = _sanitize(cleanOriginal);

    if (cleanOriginal.isNotEmpty &&
        cleanOriginal != 'file' &&
        cleanOriginal != 'image' &&
        cleanOriginal != 'document' &&
        cleanOriginal != 'ملف_مرفق' &&
        cleanOriginal != 'صورة_مرفقة' &&
        cleanOriginal != 'مستند_مرفق') {
      if (!parts.contains(cleanOriginal)) {
        parts.add(cleanOriginal);
      }
    }

    if (parts.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      return _sanitize('file_$now.$ext');
    }

    final name = parts.join(' - ');
    return _sanitize('$name.$ext');
  }

  /// Extracts the file extension from a filename, MIME type, binary bytes, or fallback.
  static String extractExtension(
    String filename, {
    String? contentType,
    Uint8List? bytes,
    String? fallbackExtension,
  }) {
    // 1. Try bytes signature (most reliable)
    if (bytes != null && bytes.isNotEmpty) {
      final byteExt = detectExtensionFromBytes(bytes);
      if (byteExt != null) return byteExt;
    }

    // 2. Try MIME Content-Type
    if (contentType != null && contentType.isNotEmpty) {
      final mimeExt = detectExtensionFromMimeType(contentType);
      if (mimeExt != null) return mimeExt;
    }

    // 3. Try filename / path extension
    final clean = filename.split('?').first.split('#').first;
    final lastDot = clean.lastIndexOf('.');
    if (lastDot != -1 && lastDot < clean.length - 1) {
      final ext = clean.substring(lastDot + 1).toLowerCase().trim();
      if (RegExp(r'^[a-z0-9]{2,5}$').hasMatch(ext)) {
        return ext;
      }
    }

    // 4. Fallback extension if provided
    if (fallbackExtension != null && fallbackExtension.trim().isNotEmpty) {
      return fallbackExtension.replaceAll('.', '').toLowerCase().trim();
    }

    // 5. Default fallback
    return 'png';
  }

  /// Detects file extension from binary magic bytes.
  static String? detectExtensionFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // PNG: 89 50 4E 47 (\x89PNG)
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'png';
    }

    // JPEG: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'jpg';
    }

    // PDF: %PDF- (25 50 44 46 2D)
    final checkLen = bytes.length > 1024 ? 1024 : bytes.length;
    for (var i = 0; i <= checkLen - 5; i++) {
      if (bytes[i] == 0x25 &&
          bytes[i + 1] == 0x50 &&
          bytes[i + 2] == 0x44 &&
          bytes[i + 3] == 0x46 &&
          bytes[i + 4] == 0x2D) {
        return 'pdf';
      }
    }

    // WEBP: RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46 &&
        bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 && bytes[11] == 0x50) {
      return 'webp';
    }

    // GIF: GIF87a or GIF89a
    if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
      return 'gif';
    }

    // BMP: BM (42 4D)
    if (bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return 'bmp';
    }

    return null;
  }

  /// Maps Content-Type header to file extension.
  static String? detectExtensionFromMimeType(String contentType) {
    final lower = contentType.toLowerCase().trim();
    if (lower.contains('image/png')) return 'png';
    if (lower.contains('image/jpeg') || lower.contains('image/jpg')) return 'jpg';
    if (lower.contains('image/webp')) return 'webp';
    if (lower.contains('image/gif')) return 'gif';
    if (lower.contains('image/bmp')) return 'bmp';
    if (lower.contains('image/svg+xml')) return 'svg';
    if (lower.contains('application/pdf')) return 'pdf';
    return null;
  }

  /// Sanitize filename to remove characters that are invalid in filenames.
  static String _sanitize(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .trim();
  }

  /// Convenience: returns the full save path for a file.
  static Future<String> getSavePath({
    String? applicantName,
    String? documentType,
    required String originalFilename,
    String? contentType,
    Uint8List? bytes,
    String? fallbackExtension,
  }) async {
    final dir = await getAppDownloadsDir();
    final filename = buildFilename(
      applicantName: applicantName,
      documentType: documentType,
      originalFilename: originalFilename,
      contentType: contentType,
      bytes: bytes,
      fallbackExtension: fallbackExtension,
    );
    return '${dir.path}${Platform.pathSeparator}$filename';
  }
}

