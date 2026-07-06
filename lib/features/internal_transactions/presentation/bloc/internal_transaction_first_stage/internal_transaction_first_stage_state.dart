import 'package:equatable/equatable.dart';

import '../../../domain/entities/internal_transaction_first_stage_entity.dart';

class InternalTransactionFirstStageState extends Equatable {
  final bool loading;
  final String? errorMessage;
  final InternalTransactionFirstStageEntity? details;

  const InternalTransactionFirstStageState({
    required this.loading,
    this.errorMessage,
    this.details,
  });

  factory InternalTransactionFirstStageState.initial() {
    return const InternalTransactionFirstStageState(loading: true);
  }

  InternalTransactionFirstStageState copyWith({
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    InternalTransactionFirstStageEntity? details,
  }) {
    return InternalTransactionFirstStageState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [loading, errorMessage, details];
}
