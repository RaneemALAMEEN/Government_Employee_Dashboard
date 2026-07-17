
import 'package:equatable/equatable.dart';

abstract class InternalTransactionsEvent extends Equatable {
  const InternalTransactionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInternalTransactionsOverview extends InternalTransactionsEvent {
  const LoadInternalTransactionsOverview();
}

class LoadInternalTransactionsPage extends InternalTransactionsEvent {
  final int page;
  final String? status;

  const LoadInternalTransactionsPage({
    required this.page,
    this.status,
  });

  @override
  List<Object?> get props => [page, status];
}

class LoadMoreInternalTransactions extends InternalTransactionsEvent {
  const LoadMoreInternalTransactions();
}
