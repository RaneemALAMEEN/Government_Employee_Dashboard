import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/verify_document.dart';
import 'document_verification_event.dart';
import 'document_verification_state.dart';

class DocumentVerificationBloc
    extends Bloc<DocumentVerificationEvent, DocumentVerificationState> {
  final VerifyDocument verifyDocument;

  DocumentVerificationBloc({required this.verifyDocument})
      : super(const DocumentVerificationInitial()) {
    on<VerifyDocumentRequested>(_verify);
    on<ResetDocumentVerification>(
      (_, emit) => emit(const DocumentVerificationInitial()),
    );
  }

  Future<void> _verify(
    VerifyDocumentRequested event,
    Emitter<DocumentVerificationState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty || state is DocumentVerificationLoading) return;
    emit(DocumentVerificationLoading(code));
    final result = await verifyDocument(code);
    result.fold(
      (failure) => emit(
        DocumentVerificationFailure.fromFailure(code, failure),
      ),
      (data) => emit(DocumentVerificationSuccess(code: code, data: data)),
    );
  }
}
