import 'package:equatable/equatable.dart';

import '../../domain/entities/process_details_entity.dart';

sealed class ProcessDetailsState extends Equatable {
  const ProcessDetailsState();

  @override
  List<Object?> get props => [];
}

class ProcessDetailsInitial extends ProcessDetailsState {
  const ProcessDetailsInitial();
}

class ProcessDetailsLoading extends ProcessDetailsState {
  const ProcessDetailsLoading();
}

class ProcessDetailsLoaded extends ProcessDetailsState {
  final ProcessDetailsEntity details;

  const ProcessDetailsLoaded({required this.details});

  @override
  List<Object?> get props => [details];
}

class ProcessDetailsError extends ProcessDetailsState {
  final String message;

  const ProcessDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
