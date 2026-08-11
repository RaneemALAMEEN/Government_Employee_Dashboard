import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/collections/cache_entry.dart';
import '../../../../core/cache/services/cache_manager.dart';
import '../../../../core/cache/services/user_scope_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_template_entity.dart';
import '../../domain/entities/dynamic_form_entity.dart';
import '../../domain/entities/internal_category_entity.dart';
import '../../domain/entities/internal_processes_page_entity.dart';
import '../../domain/entities/internal_transaction_first_stage_entity.dart';
import '../../domain/entities/internal_transaction_counts_entity.dart';
import '../../domain/entities/internal_transactions_page_entity.dart';
import '../../domain/repositories/internal_transactions_repository.dart';
import '../datasources/internal_transactions_remote_data_source.dart';
import '../models/document_template_model.dart';
import '../models/dynamic_form_model.dart';
import '../models/internal_category_model.dart';
import '../models/internal_processes_page_model.dart';
import '../models/internal_transaction_first_stage_model.dart';
import '../models/internal_transaction_counts_model.dart';
import '../models/internal_transactions_page_model.dart';

class InternalTransactionsRepositoryImpl
    implements InternalTransactionsRepository {
  final InternalTransactionsRemoteDataSource remoteDataSource;
  final CacheManager? cacheManager;
  final UserScopeService? userScopeService;

  InternalTransactionsRepositoryImpl(
    this.remoteDataSource, {
    this.cacheManager,
    this.userScopeService,
  });

  @override
  Future<Either<Failure, List<InternalCategoryEntity>>> getCategories() async {
    final rawKey = 'internal_categories';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    // 1. Offline-First: Check if cached data exists in Isar database
    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    // 2. If cache exists (even if expired TTL), return it IMMEDIATELY (0ms UI latency)
    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = _parseCategories(jsonMap);

      _triggerCategoriesBackgroundRefresh(scopedKey: scopedKey);

      return Right(cachedResult);
    }

    // 3. If NO cache exists, fetch from network synchronously
    try {
      final rawData = await remoteDataSource.getCategories();

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached fresh categories for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = _parseCategories(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerCategoriesBackgroundRefresh({required String scopedKey}) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData = await remoteDataSource.getCategories();
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  List<InternalCategoryEntity> _parseCategories(Map<String, dynamic> jsonMap) {
    final rawList = jsonMap['items'] ?? jsonMap['data'];
    if (rawList is List) {
      return rawList
          .map((item) => InternalCategoryModel.fromJson(item))
          .toList();
    }
    return [];
  }

  @override
  Future<Either<Failure, InternalProcessesPageEntity>> getProcessesByCategory({
    required int categoryId,
    required int page,
    required int limit,
  }) async {
    final rawKey =
        'internal_processes_cat_${categoryId}_page_${page}_limit_$limit';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = InternalProcessesPageModel.fromJson(jsonMap);

      _triggerProcessesBackgroundRefresh(
        scopedKey: scopedKey,
        categoryId: categoryId,
        page: page,
        limit: limit,
      );

      return Right(cachedResult);
    }

    try {
      final rawData = await remoteDataSource.getProcessesByCategory(
        categoryId: categoryId,
        page: page,
        limit: limit,
      );

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached fresh processes for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = InternalProcessesPageModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerProcessesBackgroundRefresh({
    required String scopedKey,
    required int categoryId,
    required int page,
    required int limit,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData = await remoteDataSource.getProcessesByCategory(
          categoryId: categoryId,
          page: page,
          limit: limit,
        );
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  @override
  Future<Either<Failure, InternalTransactionCountsEntity>>
      getMyTransactionCounts() async {
    final rawKey = 'internal_transaction_counts';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = InternalTransactionCountsModel.fromJson(jsonMap);

      _triggerCountsBackgroundRefresh(scopedKey: scopedKey);

      return Right(cachedResult);
    }

    try {
      final rawData = await remoteDataSource.getMyTransactionCounts();

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached fresh counts for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = InternalTransactionCountsModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerCountsBackgroundRefresh({required String scopedKey}) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData = await remoteDataSource.getMyTransactionCounts();
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  @override
  Future<Either<Failure, InternalTransactionsPageEntity>> getMyTransactions({
    required int page,
    required int limit,
    String? status,
  }) async {
    final rawKey =
        'internal_transactions_page_${page}_limit_${limit}_status_${status ?? "all"}';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = InternalTransactionsPageModel.fromJson(jsonMap);

      _triggerMyTransactionsBackgroundRefresh(
        scopedKey: scopedKey,
        page: page,
        limit: limit,
        status: status,
      );

      return Right(cachedResult);
    }

    try {
      final rawData = await remoteDataSource.getMyTransactions(
        page: page,
        limit: limit,
        status: status,
      );

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached fresh transactions for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = InternalTransactionsPageModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerMyTransactionsBackgroundRefresh({
    required String scopedKey,
    required int page,
    required int limit,
    String? status,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData = await remoteDataSource.getMyTransactions(
          page: page,
          limit: limit,
          status: status,
        );

        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: cacheManager!.ttlManager.getTtlForFeature('internal_transactions'),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  @override
  Future<Either<Failure, InternalTransactionFirstStageEntity>>
      getFirstStageTransaction({
    required int transactionId,
  }) async {
    final rawKey = 'internal_first_stage_tx_$transactionId';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = InternalTransactionFirstStageModel.fromJson(jsonMap);

      _triggerFirstStageBackgroundRefresh(
        scopedKey: scopedKey,
        transactionId: transactionId,
      );

      return Right(cachedResult);
    }

    try {
      final rawData = await remoteDataSource.getFirstStageTransaction(
        transactionId: transactionId,
      );

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(minutes: 10),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached first stage for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = InternalTransactionFirstStageModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerFirstStageBackgroundRefresh({
    required String scopedKey,
    required int transactionId,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData = await remoteDataSource.getFirstStageTransaction(
          transactionId: transactionId,
        );
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(minutes: 10),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  @override
  Future<Either<Failure, DynamicFormEntity>> getStageConfig({
    required int processId,
  }) async {
    final rawKey = 'internal_stage_config_$processId';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = DynamicFormModel.fromJson(jsonMap);

      _triggerStageConfigBackgroundRefresh(
        scopedKey: scopedKey,
        processId: processId,
      );

      return Right(cachedResult);
    }

    try {
      final rawData =
          await remoteDataSource.getStageConfig(processId: processId);

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(hours: 12),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached stage config for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = DynamicFormModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerStageConfigBackgroundRefresh({
    required String scopedKey,
    required int processId,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData =
            await remoteDataSource.getStageConfig(processId: processId);
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(hours: 12),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  }) async {
    try {
      final data = await remoteDataSource.uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId,
        key: key,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required int processId,
    required String pin,
  }) async {
    try {
      final data = await remoteDataSource.createSigningChallenge(
        processId: processId,
        pin: pin,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> completeSignedTransaction({
    required int transactionId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final data = await remoteDataSource.completeSignedTransaction(
        transactionId: transactionId,
        payload: payload,
      );
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  @override
  Future<Either<Failure, DocumentTemplateEntity>> getDocumentTemplate({
    required int templateId,
  }) async {
    final rawKey = 'internal_document_template_$templateId';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[InternalTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[InternalTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap = jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = DocumentTemplateModel.fromJson(jsonMap);

      _triggerTemplateBackgroundRefresh(
        scopedKey: scopedKey,
        templateId: templateId,
      );

      return Right(cachedResult);
    }

    try {
      final rawData =
          await remoteDataSource.getDocumentTemplate(templateId: templateId);

      if (cacheManager != null) {
        try {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(hours: 12),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Cached template for $scopedKey',
          );
        } catch (e) {
          debugPrint(
              '[InternalTransactionsRepositoryImpl] Cache write error: $e');
        }
      }

      final result = DocumentTemplateModel.fromJson(rawData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(_cleanError(e)));
    }
  }

  void _triggerTemplateBackgroundRefresh({
    required String scopedKey,
    required int templateId,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final rawData =
            await remoteDataSource.getDocumentTemplate(templateId: templateId);
        if (cacheManager != null) {
          await cacheManager!.write<Map<String, dynamic>>(
            cacheKey: scopedKey,
            data: rawData,
            toJson: (item) => item,
            ttl: const Duration(hours: 12),
          );
          debugPrint(
            '[InternalTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
          );
        }
      } catch (e) {
        debugPrint(
          '[InternalTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
