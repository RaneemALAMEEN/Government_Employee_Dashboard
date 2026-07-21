import 'package:equatable/equatable.dart';

sealed class DocumentVerificationEvent extends Equatable {
  const DocumentVerificationEvent();

  @override
  List<Object?> get props => [];
}

class VerifyDocumentRequested extends DocumentVerificationEvent {
  final String code;

  const VerifyDocumentRequested({required this.code});

  @override
  List<Object?> get props => [code];
}

class ResetDocumentVerification extends DocumentVerificationEvent {
  const ResetDocumentVerification();
}
