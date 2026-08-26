import 'package:equatable/equatable.dart';

import '../../../domain/entities/self_card_entity.dart';

sealed class EmployeePickerEvent extends Equatable {
  const EmployeePickerEvent();

  @override
  List<Object?> get props => [];
}

class EmployeePickerOpened extends EmployeePickerEvent {
  const EmployeePickerOpened();
}

class EmployeePickerQueryChanged extends EmployeePickerEvent {
  final String query;

  const EmployeePickerQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class EmployeePickerLoadMore extends EmployeePickerEvent {
  const EmployeePickerLoadMore();
}

class EmployeePickerRetrySearch extends EmployeePickerEvent {
  const EmployeePickerRetrySearch();
}

class EmployeePickerSelected extends EmployeePickerEvent {
  final SelfCardEntity item;

  const EmployeePickerSelected(this.item);

  @override
  List<Object?> get props => [item.id];
}

class EmployeePickerValueHydrated extends EmployeePickerEvent {
  final int id;

  const EmployeePickerValueHydrated(this.id);

  @override
  List<Object?> get props => [id];
}

class EmployeePickerSelectionCleared extends EmployeePickerEvent {
  const EmployeePickerSelectionCleared();
}

class EmployeePickerRetryDetails extends EmployeePickerEvent {
  const EmployeePickerRetryDetails();
}

class ExecuteEmployeePickerSearch extends EmployeePickerEvent {
  final String query;
  final int generation;

  const ExecuteEmployeePickerSearch({
    required this.query,
    required this.generation,
  });

  @override
  List<Object?> get props => [query, generation];
}
