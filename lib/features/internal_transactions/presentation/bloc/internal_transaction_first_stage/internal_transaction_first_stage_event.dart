import 'package:equatable/equatable.dart';

abstract class InternalTransactionFirstStageEvent extends Equatable {
  const InternalTransactionFirstStageEvent();

  @override
  List<Object?> get props => [];
}

class LoadInternalTransactionFirstStage
    extends InternalTransactionFirstStageEvent {
  final int transactionId;

  const LoadInternalTransactionFirstStage(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}
