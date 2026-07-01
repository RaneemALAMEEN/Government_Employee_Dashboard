import 'package:equatable/equatable.dart';

abstract class CreateInternalTransactionEvent extends Equatable {
  const CreateInternalTransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCreateInternalTransactionData
    extends CreateInternalTransactionEvent {
  const LoadCreateInternalTransactionData();
}

class SelectInternalTransactionCategory
    extends CreateInternalTransactionEvent {
  final int categoryId;

  const SelectInternalTransactionCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchInternalTransactionProcesses
    extends CreateInternalTransactionEvent {
  final String query;

  const SearchInternalTransactionProcesses(this.query);

  @override
  List<Object?> get props => [query];
}