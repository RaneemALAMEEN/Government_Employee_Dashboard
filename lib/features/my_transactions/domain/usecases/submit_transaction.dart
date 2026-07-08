import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/usb_signing_service.dart';
import '../../../internal_transactions/domain/entities/dynamic_widget_entity.dart';
import '../repositories/my_transactions_repository.dart';

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
    String? pin,
    String? keysDirectoryPath,
    List<int> templateIds = const [],
    List<Map<String, dynamic>> loadedTemplates = const [],
    Map<String, dynamic> templateFormValues = const {},
  }) async {
    try {
      final isSubmitDocuments = formId.contains('sign') || formId.contains('document');
      
      // 1. Set Programmatic Decision Value
      _setProgrammaticDecisionValue(widgets, formValues, isApprove);
      
      // 2. Upload Files and Build Payload
      final payloadResult = await _buildSubmitPayload(widgets, formValues);
      if (payloadResult.isLeft()) return payloadResult;
      
      final payload = payloadResult.getOrElse(() => {});
      final decisionValue = isApprove ? 'approve' : 'reject';
      
      // 3. Build templates payload — use loaded templates or fallback to fetch
      final templatesPayload = <Map<String, dynamic>>[];
      for (final templateId in templateIds) {
        final templateWidgets = <Map<String, dynamic>>[];
        
        final existingTemplate = loadedTemplates.cast<Map<String, dynamic>?>().firstWhere(
          (t) => (t?['id'] == templateId || t?['template_id'] == templateId),
          orElse: () => null,
        );

        if (existingTemplate != null) {
          final configJson = existingTemplate['config_json'] as Map<String, dynamic>? ?? {};
          final fields = configJson['widgets'] as List? ?? configJson['fields'] as List? ?? [];
          for (final field in fields) {
            if (field is Map<String, dynamic>) {
              final fieldId = field['data']?['id']?.toString() ?? field['id']?.toString() ?? '';
              templateWidgets.add({
                'widget_type': field['widget_type'] ?? field['type'] ?? 'text_field',
                'data': field['data'] ?? field,
                'value': templateFormValues[fieldId] ?? field['value'] ?? '',
              });
            }
          }
        } else {
          final templateResult = await repository.getDocumentTemplate(templateId: templateId);
          templateResult.fold(
            (_) {}, // If template fetch fails, send empty widgets
            (templateResponse) {
              final templateData = templateResponse['data'] as Map<String, dynamic>? ?? templateResponse;
              final configJson = templateData['config_json'] as Map<String, dynamic>? ?? {};
              final fields = configJson['widgets'] as List? ?? configJson['fields'] as List? ?? [];
              
              for (final field in fields) {
                if (field is Map<String, dynamic>) {
                  final fieldId = field['data']?['id']?.toString() ?? field['id']?.toString() ?? '';
                  templateWidgets.add({
                    'widget_type': field['widget_type'] ?? field['type'] ?? 'text_field',
                    'data': field['data'] ?? field,
                    'value': templateFormValues[fieldId] ?? formValues[fieldId] ?? field['value'] ?? '',
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

      // 4. Complete Task payload structure
      final completePayload = {
        'form_id': formId,
        'form_name': formName,
        'widgets': payload['widgets'],
        'templates': templatesPayload,
        'note': '',
        'decision': decisionValue,
      };

      // 4. Handle Signature if required (only for approve and when pin/keys exist)
      if (isApprove && pin != null && keysDirectoryPath != null && pin.isNotEmpty && keysDirectoryPath.isNotEmpty) {
        // Request Signing Challenge
        final challengeResult = await repository.createSigningChallenge(
          taskId: taskId,
          pin: pin,
          decision: decisionValue,
          isSubmitDocuments: isSubmitDocuments,
        );
        
        if (challengeResult.isLeft()) return challengeResult;
        
        final challengeData = challengeResult.getOrElse(() => {})['data'] as Map<String, dynamic>? ?? {};
        final message = challengeData['message']?.toString() ?? '';
        final challengeId = challengeData['challenge_id']?.toString() ?? '';
        
        // Generate Signature
        try {
          final signature = await usbSigningService.signMessageFromUsb(
            keysDirectoryPath: keysDirectoryPath,
            pin: pin,
            message: message,
          );
          
          completePayload['signature'] = {
            'challenge_id': challengeId,
            'signature': signature,
          };
        } catch (e) {
          return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
        }
      }

      // 5. Submit Complete Task API
      return await repository.completeTask(
        taskId: taskId,
        payload: completePayload,
        isSubmitDocuments: isSubmitDocuments,
      );
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _setProgrammaticDecisionValue(
      List<DynamicWidgetEntity> widgets, Map<String, dynamic> formValues, bool isApprove) {
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
              selectedValue = (options.last['key'] ?? options.last['value'] ?? '').toString();
            } else {
              selectedValue = (options.first['key'] ?? options.first['value'] ?? '').toString();
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
      List<DynamicWidgetEntity> widgets, Map<String, dynamic> formValues) async {
    final widgetsPayload = <Map<String, dynamic>>[];

    for (final widget in widgets) {
      final id = widget.data['id']?.toString() ?? '';
      final value = formValues[id];

      dynamic finalValue = value;
      if (widget.widgetType == 'file_picker') {
        final uploadResult = await _uploadFiles(id, widget.data, value);
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
    Map<String, dynamic> widgetData,
    dynamic value,
  ) async {
    if (value == null || (value is! List) || value.isEmpty) {
      return const Right([]);
    }

    final typeDocId = widgetData['type_doc_id'];
    final uploadedFiles = <Map<String, dynamic>>[];

    for (final file in value) {
      if (file is Map && file['path'] != null) {
        uploadedFiles.add(Map<String, dynamic>.from(file));
        continue;
      }
      final filePath = file.path;
      if (filePath == null || filePath.toString().isEmpty) {
        continue;
      }

      final uploadedResult = await repository.uploadTransactionFile(
        filePath: filePath.toString(),
        typeDocId: typeDocId is int ? typeDocId : int.tryParse(typeDocId.toString()) ?? 1,
        key: widgetId,
      );

      if (uploadedResult.isLeft()) {
        return Left(uploadedResult.fold((l) => l, (r) => throw Exception()));
      }
      
      uploadedFiles.add(uploadedResult.getOrElse(() => {}));
    }

    return Right(uploadedFiles);
  }
}
