import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';

import '../../../../core/services/usb_signing_service.dart';
import '../../../internal_transactions/domain/entities/dynamic_widget_entity.dart';
import '../repositories/my_transactions_repository.dart';

typedef TransactionSubmitProgressCallback = void Function(
  String statusMessage, {
  bool? isUploadingFiles,
  String? stage,
  String? currentFileName,
  int? currentFileIndex,
  int? totalFiles,
  double? progress,
});

class SubmitTransaction {
  final MyTransactionsRepository repository;
  final UsbSigningService usbSigningService;

  SubmitTransaction(this.repository, this.usbSigningService);

  Future<Either<Failure, dynamic>> call({
    required String taskId,
    required List<DynamicWidgetEntity> widgets,
    required Map<String, dynamic> formValues,
    required String formId,
    required String formName,
    required bool isApprove,
    String? note,
    String? pin,
    String? keysDirectoryPath,
    List<int> templateIds = const [],
    List<Map<String, dynamic>> loadedTemplates = const [],
    Map<String, dynamic> templateFormValues = const {},
    int? expectedVersion,
    List<Map<String, dynamic>>? assignments,
    TransactionSubmitProgressCallback? onProgress,
  }) async {
    try {
      final isSubmitDocuments =
          formId.contains('sign') || formId.contains('document');

      onProgress?.call(
        'جاري فحص المرفقات وتجهيز البيانات...',
        isUploadingFiles: false,
        stage: 'preparing',
        progress: 0.1,
      );

      // 1. Set Programmatic Decision Value
      _setProgrammaticDecisionValue(widgets, formValues, isApprove);

      // 2. Upload Files and Build Payload
      final payloadResult =
          await _buildSubmitPayload(widgets, formValues, onProgress: onProgress);
      if (payloadResult.isLeft()) return payloadResult;

      final payload = payloadResult.getOrElse(() => {});
      final decisionValue = isApprove ? 'approve' : 'reject';

      // 3. Build templates payload — use loaded templates or fallback to fetch
      final templatesPayload = <Map<String, dynamic>>[];
      for (final templateId in templateIds) {
        final templateWidgets = <Map<String, dynamic>>[];

        final existingTemplate = loadedTemplates
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (t) =>
                  (t?['id'] == templateId || t?['template_id'] == templateId),
              orElse: () => null,
            );

        if (existingTemplate != null) {
          final configJson =
              existingTemplate['config_json'] as Map<String, dynamic>? ?? {};
          final fields = configJson['widgets'] as List? ??
              configJson['fields'] as List? ??
              [];
          for (final field in fields) {
            if (field is Map<String, dynamic>) {
              final fieldId = field['data']?['id']?.toString() ??
                  field['id']?.toString() ??
                  '';
              templateWidgets.add({
                'widget_type':
                    field['widget_type'] ?? field['type'] ?? 'text_field',
                'data': field['data'] ?? field,
                'value': templateFormValues[fieldId] ?? field['value'] ?? '',
              });
            }
          }
        } else {
          final templateResult =
              await repository.getDocumentTemplate(templateId: templateId);
          templateResult.fold(
            (_) {}, // If template fetch fails, send empty widgets
            (templateResponse) {
              final templateData =
                  templateResponse['data'] as Map<String, dynamic>? ??
                      templateResponse;
              final configJson =
                  templateData['config_json'] as Map<String, dynamic>? ?? {};
              final fields = configJson['widgets'] as List? ??
                  configJson['fields'] as List? ??
                  [];

              for (final field in fields) {
                if (field is Map<String, dynamic>) {
                  final fieldId = field['data']?['id']?.toString() ??
                      field['id']?.toString() ??
                      '';
                  templateWidgets.add({
                    'widget_type':
                        field['widget_type'] ?? field['type'] ?? 'text_field',
                    'data': field['data'] ?? field,
                    'value': templateFormValues[fieldId] ??
                        formValues[fieldId] ??
                        field['value'] ??
                        '',
                  });
                }
              }
            },
          );
        }

        templatesPayload.add({
          'id': templateId,
          'widgets': templateWidgets,
        });
      }

      // 4. Base Task payload structure
      final basePayload = <String, dynamic>{
        'form_id': formId,
        'form_name': formName,
        'widgets': payload['widgets'],
        'templates': templatesPayload,
        'note': note ?? '',
        'decision': decisionValue,
        if (assignments != null && assignments.isNotEmpty)
          'assignments': assignments,
      };

      final completePayload = <String, dynamic>{
        ...basePayload,
        if (expectedVersion != null) 'expected_version': expectedVersion,
      };

      // 5. Handle Signature if required (when pin/keys exist)
      if (pin != null &&
          keysDirectoryPath != null &&
          pin.isNotEmpty &&
          keysDirectoryPath.isNotEmpty) {
        debugPrint('==================================================');
        debugPrint('[SubmitTransaction] 🔐 Transaction Signing PIN: $pin');
        debugPrint('==================================================');

        final challengePayload = <String, dynamic>{
          'pin': pin,
          ...basePayload,
        };

        debugPrint('==================================================');
        debugPrint('[SubmitTransaction] 🔐 Signing Challenge Request:');
        debugPrint('Task ID: $taskId');
        debugPrint('--- Signing Challenge Payload (JSON) ---');
        try {
          const encoder = JsonEncoder.withIndent('  ');
          final prettyJson = encoder.convert(challengePayload);
          for (final line in prettyJson.split('\n')) {
            debugPrint(line, wrapWidth: 1024);
          }
        } catch (_) {
          debugPrint(challengePayload.toString());
        }
        debugPrint('----------------------------------------');
        debugPrint('==================================================');

        // Request Signing Challenge
        onProgress?.call(
          'جاري إنشاء طلب التوقيع الرقمي...',
          isUploadingFiles: false,
          stage: 'signing',
          progress: 0.85,
        );
        final challengeResult = await repository.createSigningChallenge(
          taskId: taskId,
          payload: challengePayload,
          isSubmitDocuments: isSubmitDocuments,
        );

        if (challengeResult.isLeft()) return challengeResult;

        final challengeData = challengeResult.getOrElse(() => {})['data']
                as Map<String, dynamic>? ??
            {};
        final message = challengeData['message']?.toString() ?? '';
        final challengeId = challengeData['challenge_id']?.toString() ?? '';
        if (message.isEmpty || challengeId.isEmpty) {
          return const Left(
            ServerFailure(
                'استجابة طلب التوقيع غير مكتملة، يرجى المحاولة مجدداً.'),
          );
        }

        // Generate Signature
        try {
          onProgress?.call(
            'جاري توقيع المعاملة رقمياً عبر فلاشة USB...',
            isUploadingFiles: false,
            stage: 'signing',
            progress: 0.90,
          );
          final signature = await usbSigningService.signMessageFromUsb(
            keysDirectoryPath: keysDirectoryPath,
            pin: pin,
            message: message,
            expectedKeyFingerprint:
                challengeData['key_fingerprint']?.toString(),
          );

          completePayload['signature'] = {
            'challenge_id': challengeId,
            'signature': signature,
          };
        } catch (e) {
          return Left(
              ServerFailure(e.toString().replaceFirst('Exception: ', '')));
        }
      }

      onProgress?.call(
        'جاري إرسال واعتماد المعاملة على الخادم...',
        isUploadingFiles: false,
        stage: 'submitting',
        progress: 0.95,
      );
      debugPrint('==================================================');
      debugPrint('[SubmitTransaction] 🚀 Complete Task Request:');
      debugPrint('Task ID: $taskId');
      debugPrint('--- Complete Task Payload (JSON) ---');
      try {
        const encoder = JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(completePayload);
        for (final line in prettyJson.split('\n')) {
          debugPrint(line, wrapWidth: 1024);
        }
      } catch (_) {
        debugPrint(completePayload.toString());
      }
      debugPrint('------------------------------------');
      debugPrint('==================================================');

      // 6. Submit Complete Task API
      return await repository.completeTask(
        taskId: taskId,
        payload: completePayload,
        isSubmitDocuments: isSubmitDocuments,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _setProgrammaticDecisionValue(List<DynamicWidgetEntity> widgets,
      Map<String, dynamic> formValues, bool isApprove) {
    for (final widget in widgets) {
      final wData = widget.data;
      if (wData['is_gateway'] == true || wData['id'] == 'decision') {
        final id = wData['id']?.toString() ?? 'decision';
        final options = wData['options'] as List? ?? [];
        if (options.isNotEmpty) {
          String? selectedValue;
          for (final opt in options) {
            final val = (opt['value'] ?? opt['key'] ?? '').toString();
            final key = (opt['key'] ?? opt['value'] ?? '').toString();
            if (isApprove) {
              if (val.contains('مقبول') ||
                  val.contains('موافق') ||
                  val.contains('نعم') ||
                  val.toLowerCase().contains('approve') ||
                  val.toLowerCase().contains('yes') ||
                  key.toLowerCase().contains('approve')) {
                selectedValue = key;
                break;
              }
            } else {
              if (val.contains('مرفوض') ||
                  val.contains('رفض') ||
                  val.contains('لا') ||
                  val.toLowerCase().contains('reject') ||
                  val.toLowerCase().contains('no') ||
                  key.toLowerCase().contains('reject')) {
                selectedValue = key;
                break;
              }
            }
          }
          if (selectedValue == null && options.isNotEmpty) {
            if (isApprove) {
              selectedValue =
                  (options.last['key'] ?? options.last['value'] ?? '')
                      .toString();
            } else {
              selectedValue =
                  (options.first['key'] ?? options.first['value'] ?? '')
                      .toString();
            }
          }
          if (selectedValue != null) {
            formValues[id] = selectedValue;
          }
        } else {
          formValues[id] = isApprove ? 'approved' : 'rejected';
        }
      }
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _buildSubmitPayload(
    List<DynamicWidgetEntity> widgets,
    Map<String, dynamic> formValues, {
    TransactionSubmitProgressCallback? onProgress,
  }) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    // Calculate total files to upload across all widgets
    int totalFilesToUpload = 0;
    for (final widget in widgets) {
      if (widget.widgetType == 'file_picker') {
        final id = widget.data['id']?.toString() ?? '';
        final value = formValues[id];
        if (value is List) {
          for (final f in value) {
            final path = _extractFilePath(f);
            if (path != null && path.isNotEmpty && (f is! Map || f['id'] == null)) {
              totalFilesToUpload++;
            }
          }
        }
      }
    }

    int uploadedFilesCounter = 0;

    for (final widget in widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final label = widget.data['label']?.toString() ?? '';
      final value = formValues[id];

      dynamic finalValue = value;
      if (widget.widgetType == 'file_picker') {
        final uploadResult = await _uploadFiles(
          id,
          label,
          widget.data,
          value,
          totalFilesOverall: totalFilesToUpload,
          currentFileCounter: uploadedFilesCounter,
          onProgress: onProgress,
          onCounterIncrement: () {
            uploadedFilesCounter++;
          },
        );
        if (uploadResult.isLeft()) {
          return Left(uploadResult.fold((l) => l, (r) => throw Exception()));
        }
        finalValue = uploadResult.getOrElse(() => []);
      }

      widgetsPayload.add({
        'widget_type': widget.widgetType,
        'data': widget.data,
        'value': finalValue,
      });
    }

    return Right({'widgets': widgetsPayload});
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> _uploadFiles(
    String widgetId,
    String widgetLabel,
    Map<String, dynamic> widgetData,
    dynamic value, {
    int totalFilesOverall = 0,
    int currentFileCounter = 0,
    TransactionSubmitProgressCallback? onProgress,
    void Function()? onCounterIncrement,
  }) async {
    if (value == null || (value is! List) || value.isEmpty) {
      return const Right([]);
    }

    final typeDocId = widgetData['type_doc_id'];
    final uploadedFiles = <Map<String, dynamic>>[];

    final total = value.length;
    var index = 0;

    for (final file in value) {
      index++;
      if (file is Map &&
          file['path'] != null &&
          file['path'].toString().isNotEmpty) {
        uploadedFiles.add(Map<String, dynamic>.from(file));
        continue;
      }

      final filePath = _extractFilePath(file);
      if (filePath == null || filePath.isEmpty) {
        continue;
      }

      final fileName = _extractFileName(file);
      final displayName = widgetLabel.isNotEmpty
          ? widgetLabel
          : (fileName != null && fileName.isNotEmpty ? fileName : 'الوثيقة');

      onCounterIncrement?.call();
      final currentOverall = currentFileCounter + index;
      final displayTotal = totalFilesOverall > 0 ? totalFilesOverall : total;

      final progressVal = displayTotal > 0
          ? 0.15 + (0.65 * (currentOverall / displayTotal).clamp(0.0, 1.0))
          : 0.5;

      onProgress?.call(
        displayTotal > 1
            ? 'جاري رفع «$displayName» ($currentOverall من $displayTotal) إلى السيرفر...'
            : 'جاري رفع «$displayName» إلى السيرفر...',
        isUploadingFiles: true,
        stage: 'uploading',
        currentFileName: fileName ?? displayName,
        currentFileIndex: currentOverall,
        totalFiles: displayTotal,
        progress: progressVal,
      );

      final uploadedResult = await repository.uploadTransactionFile(
        filePath: filePath,
        typeDocId: typeDocId is int
            ? typeDocId
            : int.tryParse(typeDocId.toString()) ?? 1,
        key: widgetId,
      );

      if (uploadedResult.isLeft()) {
        return Left(uploadedResult.fold((l) => l, (r) => throw Exception()));
      }

      uploadedFiles.add(uploadedResult.getOrElse(() => {}));
    }

    return Right(uploadedFiles);
  }

  String? _extractFilePath(dynamic file) {
    if (file == null) return null;
    if (file is String) return file;
    if (file is Map) return file['path']?.toString();
    try {
      final path = (file as dynamic).path?.toString();
      if (path != null && path.isNotEmpty) return path;
    } catch (_) {}
    return null;
  }

  String? _extractFileName(dynamic file) {
    if (file == null) return null;
    if (file is Map) {
      return file['name']?.toString() ??
          file['original_name']?.toString() ??
          file['filename']?.toString();
    }
    try {
      final name = (file as dynamic).name?.toString();
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}
    final path = _extractFilePath(file);
    if (path != null && path.isNotEmpty) {
      return path.split(RegExp(r'[\\/]')).last;
    }
    return null;
  }
}
