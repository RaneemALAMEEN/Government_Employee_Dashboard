import 'package:equatable/equatable.dart';

sealed class DirectorateProcessEvent extends Equatable {
  const DirectorateProcessEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactionTypes extends DirectorateProcessEvent {
  const LoadTransactionTypes();
}

class SearchTransactionTypes extends DirectorateProcessEvent {
  final String query;
  const SearchTransactionTypes(this.query);
  @override
  List<Object?> get props => [query];
}

class LoadProcessDefinitions extends DirectorateProcessEvent {
  final int typeId;
  final String typeName;
  const LoadProcessDefinitions({required this.typeId, required this.typeName});
  @override
  List<Object?> get props => [typeId, typeName];
}

class LoadMoreProcessDefinitions extends DirectorateProcessEvent {
  const LoadMoreProcessDefinitions();
}

class RetryLoadMoreProcessDefinitions extends DirectorateProcessEvent {
  const RetryLoadMoreProcessDefinitions();
}

class SearchProcessDefinitions extends DirectorateProcessEvent {
  final String query;
  const SearchProcessDefinitions(this.query);
  @override
  List<Object?> get props => [query];
}

class BackToTransactionTypes extends DirectorateProcessEvent {
  const BackToTransactionTypes();
}

class RetryCurrentRequest extends DirectorateProcessEvent {
  const RetryCurrentRequest();
}
