import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../collections/file_cache_entry.dart';
import 'isar_service.dart';
import 'user_scope_service.dart';

/// Reusable manager for local file cache metadata (PDFs, images, attachments).
///
/// Actual file downloads and disk reads will occur in Phase 2.
/// Metadata is stored in Isar, and binaries are placed under the application's support directory.
class FileCacheManager {
  final IsarService isarService;
  final UserScopeService userScope;

  FileCacheManager({
    required this.isarService,
    required this.userScope,
  });

  /// Resolves the dedicated local directory for storing file cache binaries.
  Future<String> getFileCacheDirectoryPath() async {
    final supportDir = await getApplicationSupportDirectory();
    final userId = userScope.getCurrentUserId();
    final path = '${supportDir.path}/file_cache/user_$userId';
    return path;
  }

  /// Registers file cache metadata in Isar.
  Future<void> registerFileMetadata({
    required String cacheKey,
    required String relativeFilePath,
    required String originalUrl,
    required String mimeType,
    required int fileSizeBytes,
    String? etag,
    String? checksum,
  }) async {
    final isar = isarService.isar;
    final userId = userScope.getCurrentUserId();
    final scopedKey = userScope.buildScopedKey(cacheKey);

    final existing = await isar.fileCacheEntrys
        .filter()
        .cacheKeyEqualTo(scopedKey)
        .findFirst();

    final now = DateTime.now();
    final entry = existing ?? FileCacheEntry()
      ..downloadedAt = now;

    entry.cacheKey = scopedKey;
    entry.userId = userId;
    entry.relativeFilePath = relativeFilePath;
    entry.originalUrl = originalUrl;
    entry.mimeType = mimeType;
    entry.fileSizeBytes = fileSizeBytes;
    entry.lastAccessedAt = now;
    entry.etag = etag;
    entry.checksum = checksum;

    await isar.writeTxn(() async {
      await isar.fileCacheEntrys.put(entry);
    });

    debugPrint('[FileCacheManager] Registered file metadata for: $scopedKey');
  }

  /// Retrieves file metadata entry by cache key.
  Future<FileCacheEntry?> getFileMetadata(String cacheKey) async {
    final isar = isarService.isar;
    final scopedKey = userScope.buildScopedKey(cacheKey);

    final entry = await isar.fileCacheEntrys
        .filter()
        .cacheKeyEqualTo(scopedKey)
        .findFirst();

    if (entry != null) {
      // Touch last accessed timestamp
      await isar.writeTxn(() async {
        entry.lastAccessedAt = DateTime.now();
        await isar.fileCacheEntrys.put(entry);
      });
    }

    return entry;
  }

  /// Checks if file metadata exists for [cacheKey].
  Future<bool> isFileCached(String cacheKey) async {
    final metadata = await getFileMetadata(cacheKey);
    return metadata != null;
  }

  /// Removes file metadata for a specific key.
  Future<void> removeFileMetadata(String cacheKey) async {
    final isar = isarService.isar;
    final scopedKey = userScope.buildScopedKey(cacheKey);

    final entry = await isar.fileCacheEntrys
        .filter()
        .cacheKeyEqualTo(scopedKey)
        .findFirst();

    if (entry != null) {
      await isar.writeTxn(() async {
        await isar.fileCacheEntrys.delete(entry.id);
      });
    }
  }

  /// Clears all file cache metadata for the logged-in user.
  Future<void> clearUserFileMetadata() async {
    final userId = userScope.getCurrentUserId();
    final isar = isarService.isar;
    final entries = await isar.fileCacheEntrys
        .filter()
        .userIdEqualTo(userId)
        .findAll();

    final ids = entries.map((e) => e.id).toList();
    if (ids.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.fileCacheEntrys.deleteAll(ids);
      });
    }
  }
}
