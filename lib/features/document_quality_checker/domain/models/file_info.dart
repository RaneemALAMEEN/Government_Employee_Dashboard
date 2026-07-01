import 'dart:typed_data';

/// Metadata about the file the user uploaded.
class UploadedFileInfo {
  final String name;
  final String extension;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final Uint8List bytes;

  const UploadedFileInfo({
    required this.name,
    required this.extension,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.bytes,
  });

  bool get isImage =>
      extension == 'jpg' ||
      extension == 'jpeg' ||
      extension == 'png';

  bool get isPdf => extension == 'pdf';

  String get typeLabel => isPdf ? 'PDF' : 'Image';

  String get formattedSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) {
      return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String get formattedDate {
    final d = uploadedAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
