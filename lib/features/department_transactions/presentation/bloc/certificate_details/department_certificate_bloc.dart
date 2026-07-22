import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/department_transactions_repository.dart';
import 'department_certificate_event.dart';
import 'department_certificate_state.dart';

class DepartmentCertificateBloc extends Bloc<DepartmentCertificateEvent, DepartmentCertificateState> {
  final DepartmentTransactionsRepository repository;

  DepartmentCertificateBloc({required this.repository}) : super(DepartmentCertificateInitial()) {
    on<LoadDepartmentCertificate>(_onLoadDepartmentCertificate);
  }

  Future<void> _onLoadDepartmentCertificate(
    LoadDepartmentCertificate event,
    Emitter<DepartmentCertificateState> emit,
  ) async {
    emit(DepartmentCertificateLoading());
    final result = await repository.getTransactionCertificate(event.transactionId);

    result.fold(
      (failure) => emit(DepartmentCertificateFailure(failure.message)),
      (data) => emit(DepartmentCertificateLoaded(data: data)),
    );
  }
}
