import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Strategy for detecting changes between remote response payload/headers
/// and locally cached data.
///
/// Priority Order:
/// 1. ETag comparison (if present on both remote and cache)
/// 2. Version comparison (if present on both remote and cache)
/// 3. Last-Modified timestamp comparison (if present on both)
/// 4. Content Hash comparison (MD5 of JSON representation)
class ChangeDetectionStrategy {
  const ChangeDetectionStrategy();

  /// Returns `true` if the remote data or headers indicate that data has changed
  /// relative to the cached dataset.
  bool hasChanged({
    required String? cachedEtag,
    required String? remoteEtag,
    required String? cachedVersion,
    required String? remoteVersion,
    required String? cachedLastModified,
    required String? remoteLastModified,
    required String? cachedHash,
    required String? remoteDataJson,
  }) {
    // 1. ETag Priority
    if (cachedEtag != null && remoteEtag != null) {
      return cachedEtag != remoteEtag;
    }

    // 2. Version Priority
    if (cachedVersion != null && remoteVersion != null) {
      return cachedVersion != remoteVersion;
    }

    // 3. Last-Modified Priority
    if (cachedLastModified != null && remoteLastModified != null) {
      return cachedLastModified != remoteLastModified;
    }

    // 4. Hash Priority Fallback
    if (cachedHash != null && remoteDataJson != null) {
      final newHash = generateHash(remoteDataJson);
      return cachedHash != newHash;
    }

    // Default: Assume changed if insufficient comparison metadata exists
    return true;
  }

  /// Generates an MD5 content hash for stringified JSON payloads.
  String generateHash(String rawContent) {
    final bytes = utf8.encode(rawContent);
    return md5.convert(bytes).toString();
  }
}
