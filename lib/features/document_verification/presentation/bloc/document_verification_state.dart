import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_verification_entity.dart';

sealed class DocumentVerificationState extends Equatable {
  const DocumentVerificationState();

  @override
  List<Object?> get props => [];
}

class DocumentVerificationInitial extends DocumentVerificationState {
  const DocumentVerificationInitial();
}

class DocumentVerificationLoading extends DocumentVerificationState {
  final String code;

  const DocumentVerificationLoading(this.code);

  @override
  List<Object?> get props => [code];
}

class DocumentVerificationSuccess extends DocumentVerificationState {
  final String code;
  final DocumentVerificationEntity data;

  const DocumentVerificationSuccess({required this.code, required this.data});

  @override
  List<Object?> get props => [code, data];
}

class DocumentVerificationFailure extends DocumentVerificationState {
  final String code;
  final bool isNetworkError;
  final bool isExpired;

  const DocumentVerificationFailure({
    required this.code,
    required this.isNetworkError,
    required this.isExpired,
  });

  factory DocumentVerificationFailure.fromFailure(
    String code,
    Failure failure,
  ) =>
      DocumentVerificationFailure(
        code: code,
        isNetworkError: failure is NetworkFailure,
        isExpired: _isExpiredMessage(failure.message),
      );

  @override
  List<Object?> get props => [code, isNetworkError, isExpired];
}

bool _isExpiredMessage(String message) {
  final normalized = message.toLowerCase();
  return normalized.contains('منته') ||
      normalized.contains('انتهت') ||
      normalized.contains('صلاحية') ||
      normalized.contains('expired') ||
      normalized.contains('expire');
}
