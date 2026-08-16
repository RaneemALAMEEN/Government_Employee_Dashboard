import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../collections/cache_entry.dart';
import '../collections/file_cache_entry.dart';

/// Service managing the lifecycle of the Isar database instance.
///
/// Supports dynamic schema registration so feature modules can register
/// their own Isar schemas during DI initialization while maintaining strict
/// Clean Architecture separation.
class IsarService {
  Isar? _isar;

  /// Default core schemas (feature-agnostic).
  final List<CollectionSchema<dynamic>> _registeredSchemas = [
    CacheEntrySchema,
    FileCacheEntrySchema,
  ];

  IsarService();

  /// Registers additional feature schemas dynamically before DB initialization.
  void registerSchema(CollectionSchema<dynamic> schema) {
    if (_isar != null && _isar!.isOpen) {
      debugPrint(
        'Warning: Attempted to register schema ${schema.name} after Isar was already opened.',
      );
      return;
    }
    if (!_registeredSchemas.contains(schema)) {
      _registeredSchemas.add(schema);
    }
  }

  /// Initializes and opens the Isar database.
  Future<Isar> init() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    final supportDir = await getApplicationSupportDirectory();
    debugPrint(
      '[IsarService] Initializing Isar DB at: ${supportDir.path} with ${_registeredSchemas.length} schemas',
    );

    _isar = await Isar.open(
      _registeredSchemas,
      directory: supportDir.path,
      name: 'employee_dashboard_cache',
    );

    return _isar!;
  }

  /// Gets the open Isar database instance.
  Isar get isar {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError(
        'IsarService has not been initialized. Call init() before accessing instance.',
      );
    }
    return _isar!;
  }

  /// Closes the open database instance cleanly.
  Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      await _isar!.close();
      _isar = null;
    }
  }
}
