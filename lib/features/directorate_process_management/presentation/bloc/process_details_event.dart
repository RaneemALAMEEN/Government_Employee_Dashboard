import 'package:equatable/equatable.dart';

sealed class ProcessDetailsEvent extends Equatable {
  const ProcessDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadProcessDetails extends ProcessDetailsEvent {
  final int processId;

  const LoadProcessDetails({required this.processId});

  @override
  List<Object?> get props => [processId];
}
