import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/collections/cache_entry.dart';
import '../../../../core/cache/services/cache_manager.dart';
import '../../../../core/cache/services/user_scope_service.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/my_transaction_entity.dart';
import '../../domain/entities/my_transactions_paginated_result.dart';
import '../../domain/repositories/my_transactions_repository.dart';
import '../datasources/my_transactions_remote_data_source.dart';
import '../models/my_transaction_model.dart';

class MyTransactionsRepositoryImpl implements MyTransactionsRepository {
  final MyTransactionsRemoteDataSource remoteDataSource;
  final CacheManager? cacheManager;
  final UserScopeService? userScopeService;

  MyTransactionsRepositoryImpl(
    this.remoteDataSource, {
    this.cacheManager,
    this.userScopeService,
  });

  @override
  Future<Either<Failure, MyTransactionsPaginatedResult>> getMyTransactions({
    required String status,
    String? cursor,
    int limit = 6,
  }) async {
    final rawKey =
        'my_transactions_status_${status}_cursor_${cursor ?? "initial"}_limit_$limit';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    // 1. Offline-First: Check if cached data exists in Isar database
    CacheEntry? cachedEntry;
    if (cacheManager != null) {
      try {
        cachedEntry = await cacheManager!.readRawEntry(scopedKey);
      } catch (e) {
        debugPrint(
            '[MyTransactionsRepositoryImpl] Cache read error for $scopedKey: $e');
      }
    }

    // 2. If cache exists (even if stale/expired TTL), return it IMMEDIATELY (0ms UI latency)
    if (cachedEntry != null && cachedEntry.jsonData != null) {
      debugPrint(
        '[MyTransactionsRepositoryImpl] Offline cache hit for $scopedKey (0ms UI latency)',
      );
      final jsonMap =
          jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;
      final cachedResult = _parsePaginatedResult(jsonMap);

      // Trigger silent background API refresh
      _triggerBackgroundRefresh(
        scopedKey: scopedKey,
        status: status,
        cursor: cursor,
        limit: limit,
      );

      return Right(cachedResult);
    }

    // 3. If NO cache exists (e.g. first launch ever), fetch from network synchronously
    debugPrint(
      '[MyTransactionsRepositoryImpl] No cache available for $scopedKey. Fetching from network...',
    );
    final result = await remoteDataSource.getTasks(
      status: status,
      cursor: cursor,
      limit: limit,
    );

    return result.fold(
      (failure) {
        debugPrint(
          '[MyTransactionsRepositoryImpl] Network fetch failed with no cache available: $failure',
        );
        return Left(failure);
      },
      (data) async {
        if (data is Map && cacheManager != null) {
          try {
            final mapData = Map<String, dynamic>.from(data);
            await cacheManager!.write<Map<String, dynamic>>(
              cacheKey: scopedKey,
              data: mapData,
              toJson: (item) => item,
              ttl: cacheManager!.ttlManager.getTtlForFeature('my_transactions'),
            );
            debugPrint(
              '[MyTransactionsRepositoryImpl] Cached fresh transactions for $scopedKey',
            );
          } catch (e) {
            debugPrint('[MyTransactionsRepositoryImpl] Cache write error: $e');
          }
        }
        return Right(_parsePaginatedResult(data));
      },
    );
  }

  void _triggerBackgroundRefresh({
    required String scopedKey,
    required String status,
    String? cursor,
    required int limit,
  }) {
    Future.microtask(() async {
      try {
        debugPrint(
          '[MyTransactionsRepositoryImpl] Triggering background API refresh for $scopedKey...',
        );
        final result = await remoteDataSource.getTasks(
          status: status,
          cursor: cursor,
          limit: limit,
        );

        result.fold(
          (failure) {
            debugPrint(
              '[MyTransactionsRepositoryImpl] Background refresh skipped/failed (offline/timeout) for $scopedKey: $failure',
            );
          },
          (data) async {
            if (data is Map && cacheManager != null) {
              final mapData = Map<String, dynamic>.from(data);
              await cacheManager!.write<Map<String, dynamic>>(
                cacheKey: scopedKey,
                data: mapData,
                toJson: (item) => item,
                ttl: cacheManager!.ttlManager.getTtlForFeature('my_transactions'),
              );
              debugPrint(
                '[MyTransactionsRepositoryImpl] Background refresh updated cache for $scopedKey',
              );
            }
          },
        );
      } catch (e) {
        debugPrint(
          '[MyTransactionsRepositoryImpl] Background refresh error for $scopedKey: $e',
        );
      }
    });
  }

  MyTransactionsPaginatedResult _parsePaginatedResult(dynamic data) {
    final List<MyTransactionEntity> items = [];
    String? nextCursor;
    bool hasNext = false;
    int totalCount = 0;

    if (data is Map && data['data'] != null) {
      final dataMap = data['data'];

      // Parse items
      if (dataMap['items'] is List) {
        final itemsList = dataMap['items'] as List;
        for (final item in itemsList) {
          if (item is Map) {
            final mapItem = Map<String, dynamic>.from(item);
            items.add(MyTransactionModel.fromJson(mapItem));
          }
        }
      }

      // Parse pagination
      if (dataMap['pagination'] is Map) {
        final pagination = dataMap['pagination'];
        nextCursor = pagination['next_cursor'] as String?;
        hasNext = pagination['has_next'] as bool? ?? false;

        final totalRaw = pagination['total'] ?? pagination['total_items'];
        if (totalRaw != null) {
          totalCount = int.tryParse(totalRaw.toString()) ?? 0;
        }
      }
    }

    return MyTransactionsPaginatedResult(
      items: items,
      nextCursor: nextCursor,
      hasNext: hasNext,
      totalCount: totalCount,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskDetails(
      {required String taskId}) async {
    final rawKey = 'task_details_$taskId';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    if (cacheManager != null) {
      try {
        final cachedEntry = await cacheManager!.readRawEntry(scopedKey);
        if (cachedEntry != null && cachedEntry.jsonData != null) {
          debugPrint(
              '[MyTransactionsRepositoryImpl] Task details cache hit for $scopedKey (0ms UI latency)');
          final jsonMap =
              jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;

          _triggerTaskDetailsBackgroundRefresh(
              scopedKey: scopedKey, taskId: taskId);

          return Right(jsonMap);
        }
      } catch (e) {
        debugPrint(
            '[MyTransactionsRepositoryImpl] Task details cache read error: $e');
      }
    }

    final result = await remoteDataSource.getTaskDetails(taskId: taskId);
    return result.fold(
      (failure) => Left(failure),
      (data) async {
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          if (cacheManager != null) {
            try {
              await cacheManager!.write<Map<String, dynamic>>(
                cacheKey: scopedKey,
                data: mapData,
                toJson: (item) => item,
                ttl: const Duration(minutes: 10),
              );
            } catch (e) {
              debugPrint(
                  '[MyTransactionsRepositoryImpl] Task details cache write error: $e');
            }
          }
          return Right(mapData);
        }
        return const Right(<String, dynamic>{});
      },
    );
  }

  void _triggerTaskDetailsBackgroundRefresh({
    required String scopedKey,
    required String taskId,
  }) {
    Future.microtask(() async {
      try {
        final result = await remoteDataSource.getTaskDetails(taskId: taskId);
        result.fold(
          (_) {},
          (data) async {
            if (data is Map && cacheManager != null) {
              final mapData = Map<String, dynamic>.from(data);
              await cacheManager!.write<Map<String, dynamic>>(
                cacheKey: scopedKey,
                data: mapData,
                toJson: (item) => item,
                ttl: const Duration(minutes: 10),
              );
            }
          },
        );
      } catch (_) {}
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTransactionCertificate(
      {required String taskId}) async {
    final result =
        await remoteDataSource.getTransactionCertificate(taskId: taskId);
    return result.map((r) => r as Map<String, dynamic>);
  }

  @override
  Future<Either<Failure, dynamic>> pickupTask({required String taskId}) async {
    return await remoteDataSource.pickupTask(taskId: taskId);
  }

  @override
  Future<Either<Failure, dynamic>> releaseTask({required String taskId}) async {
    return await remoteDataSource.releaseTask(taskId: taskId);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createSigningChallenge({
    required String taskId,
    required String pin,
    required String decision,
    bool isSubmitDocuments = false,
  }) async {
    final result = await remoteDataSource.createSigningChallenge(
      taskId: taskId,
      pin: pin,
      decision: decision,
      isSubmitDocuments: isSubmitDocuments,
    );
    return result.map((r) => r as Map<String, dynamic>);
  }

  @override
  Future<Either<Failure, dynamic>> completeTask({
    required String taskId,
    required Map<String, dynamic> payload,
    bool isSubmitDocuments = false,
  }) async {
    return await remoteDataSource.completeTask(
      taskId: taskId,
      payload: payload,
      isSubmitDocuments: isSubmitDocuments,
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadTransactionFile({
    required String filePath,
    required int typeDocId,
    required String key,
  }) async {
    final result = await remoteDataSource.uploadTransactionFile(
      filePath: filePath,
      typeDocId: typeDocId,
      key: key,
    );
    return result.map((r) {
      if (r is Map) {
        return r['data'] as Map<String, dynamic>? ??
            Map<String, dynamic>.from(r);
      }
      return <String, dynamic>{};
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDocumentTemplate({
    required int templateId,
  }) async {
    final rawKey = 'document_template_$templateId';
    final scopedKey = userScopeService?.buildScopedKey(rawKey) ?? rawKey;

    if (cacheManager != null) {
      try {
        final cachedEntry = await cacheManager!.readRawEntry(scopedKey);
        if (cachedEntry != null && cachedEntry.jsonData != null) {
          debugPrint(
              '[MyTransactionsRepositoryImpl] Template cache hit for $scopedKey (0ms UI latency)');
          final jsonMap =
              jsonDecode(cachedEntry.jsonData!) as Map<String, dynamic>;

          _triggerTemplateBackgroundRefresh(
              scopedKey: scopedKey, templateId: templateId);

          return Right(jsonMap);
        }
      } catch (e) {
        debugPrint(
            '[MyTransactionsRepositoryImpl] Template cache read error: $e');
      }
    }

    final result =
        await remoteDataSource.getDocumentTemplate(templateId: templateId);
    return result.fold(
      (failure) => Left(failure),
      (data) async {
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          if (cacheManager != null) {
            try {
              await cacheManager!.write<Map<String, dynamic>>(
                cacheKey: scopedKey,
                data: mapData,
                toJson: (item) => item,
                ttl: const Duration(hours: 12),
              );
            } catch (e) {
              debugPrint(
                  '[MyTransactionsRepositoryImpl] Template cache write error: $e');
            }
          }
          return Right(mapData);
        }
        return const Right(<String, dynamic>{});
      },
    );
  }

  void _triggerTemplateBackgroundRefresh({
    required String scopedKey,
    required int templateId,
  }) {
    Future.microtask(() async {
      try {
        final result =
            await remoteDataSource.getDocumentTemplate(templateId: templateId);
        result.fold(
          (_) {},
          (data) async {
            if (data is Map && cacheManager != null) {
              final mapData = Map<String, dynamic>.from(data);
              await cacheManager!.write<Map<String, dynamic>>(
                cacheKey: scopedKey,
                data: mapData,
                toJson: (item) => item,
                ttl: const Duration(hours: 12),
              );
            }
          },
        );
      } catch (_) {}
    });
  }
}
