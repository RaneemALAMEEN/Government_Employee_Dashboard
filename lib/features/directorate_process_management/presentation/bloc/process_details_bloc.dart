import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_process_details.dart';
import '../../../internal_transactions/domain/entities/document_template_entity.dart';
import '../../../internal_transactions/domain/usecases/get_document_template_usecase.dart';
import 'process_details_event.dart';
import 'process_details_state.dart';

class ProcessDetailsBloc
    extends Bloc<ProcessDetailsEvent, ProcessDetailsState> {
  final GetProcessDetails getProcessDetails;
  final GetDocumentTemplateUseCase getDocumentTemplate;
  final Map<int, DocumentTemplateEntity> _templateCache = {};

  ProcessDetailsBloc({
    required this.getProcessDetails,
    required this.getDocumentTemplate,
  }) : super(const ProcessDetailsInitial()) {
    on<LoadProcessDetails>(_load);
    on<RetryProcessTemplate>(_retryTemplate);
  }

  Future<void> _load(
    LoadProcessDetails event,
    Emitter<ProcessDetailsState> emit,
  ) async {
    if (event.processId <= 0) {
      emit(const ProcessDetailsError(message: 'معرّف العملية غير صالح'));
      return;
    }
    emit(const ProcessDetailsLoading());
    final result = await getProcessDetails(processId: event.processId);
    await result.fold<Future<void>>(
      (failure) async => emit(ProcessDetailsError(message: failure.message)),
      (details) async {
        final templateIds =
            details.stages.expand((stage) => stage.config.templateIds).toSet();
        final cached = <int, DocumentTemplateEntity>{
          for (final id in templateIds)
            if (_templateCache[id] != null) id: _templateCache[id]!,
        };
        final pendingIds = templateIds.difference(cached.keys.toSet());
        emit(ProcessDetailsLoaded(
          details: details,
          templatesById: cached,
          loadingTemplateIds: pendingIds,
        ));
        for (final id in pendingIds) {
          await _fetchTemplate(id, emit);
        }
      },
    );
  }

  Future<void> _retryTemplate(
    RetryProcessTemplate event,
    Emitter<ProcessDetailsState> emit,
  ) async {
    if (event.templateId <= 0 || state is! ProcessDetailsLoaded) return;
    final loaded = state as ProcessDetailsLoaded;
    if (loaded.loadingTemplateIds.contains(event.templateId)) return;
    emit(loaded.copyWith(
      loadingTemplateIds: {...loaded.loadingTemplateIds, event.templateId},
      failedTemplateIds: {...loaded.failedTemplateIds}
        ..remove(event.templateId),
    ));
    await _fetchTemplate(event.templateId, emit);
  }

  Future<void> _fetchTemplate(
    int templateId,
    Emitter<ProcessDetailsState> emit,
  ) async {
    if (_templateCache[templateId] case final cached?) {
      final current = state;
      if (current is ProcessDetailsLoaded) {
        emit(current.copyWith(
          templatesById: {...current.templatesById, templateId: cached},
          loadingTemplateIds: {...current.loadingTemplateIds}
            ..remove(templateId),
        ));
      }
      return;
    }
    final result = await getDocumentTemplate(templateId: templateId);
    final current = state;
    if (current is! ProcessDetailsLoaded) return;
    result.fold(
      (_) => emit(current.copyWith(
        loadingTemplateIds: {...current.loadingTemplateIds}..remove(templateId),
        failedTemplateIds: {...current.failedTemplateIds, templateId},
      )),
      (template) {
        _templateCache[templateId] = template;
        emit(current.copyWith(
          templatesById: {...current.templatesById, templateId: template},
          loadingTemplateIds: {...current.loadingTemplateIds}
            ..remove(templateId),
          failedTemplateIds: {...current.failedTemplateIds}..remove(templateId),
        ));
      },
    );
  }
}
