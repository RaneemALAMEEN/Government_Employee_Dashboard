import 'dart:io';

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
  /// [originalFilename] – الاسم الأصلي للملف من الخادم (e.g. "file_123.pdf").
  ///
  /// Result example: "أحمد محمد - الوثيقة النهائية.pdf"
  static String buildFilename({
    String? applicantName,
    String? documentType,
    required String originalFilename,
  }) {
    // Extract extension from the original filename
    final ext = _extractExtension(originalFilename);

    final parts = <String>[];

    final cleanApplicant = (applicantName ?? '').trim();
    if (cleanApplicant.isNotEmpty) {
      parts.add(cleanApplicant);
    }

    final cleanType = (documentType ?? '').trim();
    if (cleanType.isNotEmpty) {
      parts.add(cleanType);
    }

    if (parts.isEmpty) {
      // Fallback to original filename if no context is available
      return _sanitize(originalFilename);
    }

    final name = parts.join(' - ');
    return _sanitize('$name.$ext');
  }

  /// Extracts the file extension from a filename or path.
  static String _extractExtension(String filename) {
    final clean = filename.split('?').first; // Remove query params
    final lastDot = clean.lastIndexOf('.');
    if (lastDot == -1 || lastDot == clean.length - 1) return 'pdf';
    return clean.substring(lastDot + 1).toLowerCase();
  }

  /// Sanitize filename to remove characters that are invalid in filenames.
  static String _sanitize(String name) {
    // Replace characters that are not safe for filenames
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
  }) async {
    final dir = await getAppDownloadsDir();
    final filename = buildFilename(
      applicantName: applicantName,
      documentType: documentType,
      originalFilename: originalFilename,
    );
    return '${dir.path}${Platform.pathSeparator}$filename';
  }
}
