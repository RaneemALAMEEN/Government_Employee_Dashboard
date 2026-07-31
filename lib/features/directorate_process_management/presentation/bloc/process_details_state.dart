import 'package:equatable/equatable.dart';

import '../../domain/entities/process_details_entity.dart';
import '../../../internal_transactions/domain/entities/document_template_entity.dart';

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
  final Map<int, DocumentTemplateEntity> templatesById;
  final Set<int> loadingTemplateIds;
  final Set<int> failedTemplateIds;

  const ProcessDetailsLoaded({
    required this.details,
    this.templatesById = const {},
    this.loadingTemplateIds = const {},
    this.failedTemplateIds = const {},
  });

  ProcessDetailsLoaded copyWith({
    Map<int, DocumentTemplateEntity>? templatesById,
    Set<int>? loadingTemplateIds,
    Set<int>? failedTemplateIds,
  }) =>
      ProcessDetailsLoaded(
        details: details,
        templatesById: templatesById ?? this.templatesById,
        loadingTemplateIds: loadingTemplateIds ?? this.loadingTemplateIds,
        failedTemplateIds: failedTemplateIds ?? this.failedTemplateIds,
      );

  @override
  List<Object?> get props => [
        details,
        templatesById,
        loadingTemplateIds,
        failedTemplateIds,
      ];
}

class ProcessDetailsError extends ProcessDetailsState {
  final String message;

  const ProcessDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
