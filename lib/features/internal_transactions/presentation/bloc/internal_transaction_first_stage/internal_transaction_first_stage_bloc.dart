import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_internal_transaction_first_stage_usecase.dart';
import 'internal_transaction_first_stage_event.dart';
import 'internal_transaction_first_stage_state.dart';

class InternalTransactionFirstStageBloc extends Bloc<
    InternalTransactionFirstStageEvent, InternalTransactionFirstStageState> {
  final GetInternalTransactionFirstStageUseCase getFirstStage;

  InternalTransactionFirstStageBloc({required this.getFirstStage})
      : super(InternalTransactionFirstStageState.initial()) {
    on<LoadInternalTransactionFirstStage>(_onLoad);
  }

  Future<void> _onLoad(
    LoadInternalTransactionFirstStage event,
    Emitter<InternalTransactionFirstStageState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));

    final result = await getFirstStage(transactionId: event.transactionId);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            loading: false,
            errorMessage: failure.message,
          ),
        );
      },
      (details) {
        emit(
          state.copyWith(
            loading: false,
            details: details,
          ),
        );
      },
    );
  }
}
