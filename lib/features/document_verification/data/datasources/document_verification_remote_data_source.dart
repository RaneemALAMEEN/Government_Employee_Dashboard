import 'package:flutter/foundation.dart';

import '../../../../core/enums/api_method.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/api_const.dart';
import '../../../../core/services/api_service.dart';
import '../models/document_verification_model.dart';

class DocumentVerificationRemoteDataSource {
  final ApiService apiService;

  const DocumentVerificationRemoteDataSource(this.apiService);

  static const _endPoints = EndPoints();

  Future<DocumentVerificationModel> verify(String code) async {
    final result = await apiService.makeRequest(
      method: ApiMethod.get,
      endPoint: _endPoints.verifyDocumentDetails,
      queryParameters: {'code': code},
    );
    return result.fold(
      (failure) => throw failure is NetworkFailure
          ? NetworkException(failure.message)
          : ServerException(failure.message),
      (response) {
        if (kDebugMode) {
          debugPrint('[DocumentVerification] Full response: $response');
        }
        if (response is! Map) {
          throw const ServerException('استجابة التحقق من الوثيقة غير صالحة');
        }
        return DocumentVerificationModel.fromJson(
          Map<String, dynamic>.from(response),
        );
      },
    );
  }
}
