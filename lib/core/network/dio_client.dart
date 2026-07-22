import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../services/token_refresh_service.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create(
    SecureStorageService storage,
    TokenRefreshService refreshService,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Bypass SSL certificate validation to prevent handshake freezes/timeouts
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    dio.interceptors.add(
      AuthInterceptor(
        dio: dio,
        storage: storage,
        refreshService: refreshService,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          request: true,
          // Never log request headers: they contain the Bearer access token.
          requestHeader: false,
          // Bodies may include passwords, OTPs, refresh tokens, or access
          // tokens returned by authentication endpoints.
          requestBody: false,
          responseHeader: false,
          responseBody: true,
          error: true,
          compact: false,
          maxWidth: 120,
          logPrint: (value) => debugPrint(value.toString()),
          // Response bodies are logged by the safe interceptor below after
          // recursively redacting credentials and tokens.
          filter: (options, args) => !args.isResponse,
        ),
      );
      dio.interceptors.add(const _SafeResponseLoggingInterceptor());
    }

    return dio;
  }
}

class _SafeResponseLoggingInterceptor extends Interceptor {
  const _SafeResponseLoggingInterceptor();

  static const _prettyJsonEncoder = JsonEncoder.withIndent('  ');

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        data: response.data,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    if (kDebugMode && error.response != null) {
      final response = error.response!;
      _logResponse(
        method: response.requestOptions.method,
        uri: response.requestOptions.uri,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        data: response.data,
      );
    }
    handler.next(error);
  }

  void _logResponse({
    required String method,
    required Uri uri,
    required int? statusCode,
    required String? statusMessage,
    required dynamic data,
  }) {
    final body = _safeBodyText(data);

    debugPrint(
      '┌─ Response ─────────────────────────────────────────────',
    );
    debugPrint('│ $method  $uri');
    debugPrint('│ Status: ${statusCode ?? '-'} ${statusMessage ?? ''}');
    debugPrint('├─ Body ────────────────────────────────────────────────');
    for (final line in body.split('\n')) {
      debugPrint('│ $line', wrapWidth: 120);
    }
    debugPrint('└────────────────────────────────────────────────────────');
  }

  String _safeBodyText(dynamic data) {
    // Skip binary data (e.g. PDF / image bytes) to avoid flooding the console.
    if (data is List<int>) {
      return '[Binary data: ${data.length} bytes]';
    }

    dynamic decodedData = data;
    if (data is String) {
      try {
        decodedData = jsonDecode(data);
      } catch (_) {
        return data;
      }
    }

    final safeData = _redactSensitiveData(decodedData);
    try {
      return safeData is String
          ? safeData
          : _prettyJsonEncoder.convert(safeData);
    } catch (_) {
      return safeData.toString();
    }
  }

  dynamic _redactSensitiveData(dynamic value) {
    if (value is Map) {
      return value.map((key, nestedValue) {
        final keyText = key.toString();
        return MapEntry(
          keyText,
          _isSensitiveKey(keyText)
              ? '[REDACTED]'
              : _redactSensitiveData(nestedValue),
        );
      });
    }
    if (value is List) {
      return value.map(_redactSensitiveData).toList(growable: false);
    }
    return value;
  }

  bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized == 'token' ||
        normalized.endsWith('token') ||
        normalized.contains('authorization') ||
        normalized.contains('password') ||
        normalized.contains('secret') ||
        normalized == 'otp' ||
        normalized == 'pin' ||
        normalized.contains('cookie') ||
        normalized == 'sessionid';
  }
}
