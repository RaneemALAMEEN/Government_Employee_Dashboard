import 'package:isar/isar.dart';

part 'file_cache_entry.g.dart';

/// Metadata-only Isar Collection for locally cached files (PDFs, Images, Attachments).
///
/// Actual file binaries are stored under the application's support directory.
/// Sensitive files are NOT managed here.
@collection
class FileCacheEntry {
  Id id = Isar.autoIncrement;

  /// Unique file cache key (e.g. `user_123:pdf_doc_99`).
  @Index(unique: true, replace: true)
  late String cacheKey;

  /// User identifier for multi-user file isolation.
  @Index()
  late String userId;

  /// Relative path to file binary inside application support directory.
  late String relativeFilePath;

  /// Original remote URL or endpoint.
  late String originalUrl;

  /// MIME type (e.g., `application/pdf`, `image/png`).
  late String mimeType;

  /// Total file size in bytes.
  late int fileSizeBytes;

  /// Timestamp when file was downloaded.
  late DateTime downloadedAt;

  /// Timestamp when file was last accessed.
  late DateTime lastAccessedAt;

  /// ETag of the remote file resource.
  String? etag;

  /// MD5 or SHA256 checksum of the file binary.
  String? checksum;
}
