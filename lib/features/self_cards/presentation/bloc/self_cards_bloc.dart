import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_self_card_details_usecase.dart';
import '../../domain/usecases/recommend_self_cards_by_training_usecase.dart';
import '../../domain/usecases/search_self_cards_usecase.dart';
import '../utils/self_card_pdf_generator.dart';
import 'self_cards_event.dart';
import 'self_cards_state.dart';

class SelfCardsBloc extends Bloc<SelfCardsEvent, SelfCardsState> {
  final SearchSelfCardsUseCase searchSelfCards;
  final GetSelfCardDetailsUseCase getSelfCardDetails;
  final RecommendSelfCardsByTrainingUseCase recommendByTraining;

  SelfCardsBloc({
    required this.searchSelfCards,
    required this.getSelfCardDetails,
    required this.recommendByTraining,
  }) : super(SelfCardsState.initial()) {
    on<ChangeSelfCardViewModeEvent>(_onChangeViewMode);
    on<SearchSelfCardsEvent>(_onSearchSelfCards);
    on<RecommendByTrainingEvent>(_onRecommendByTraining);
    on<ClearTrainingRecommendationEvent>(_onClearTrainingRecommendation);
    on<SelectSelfCardEvent>(_onSelectSelfCard);
    on<ClearSelectedSelfCardEvent>(_onClearSelectedSelfCard);
    on<ExportSelfCardPdfEvent>(_onExportSelfCardPdf);
    on<ClearPdfExportStatusEvent>(_onClearPdfExportStatus);
  }

  void _onChangeViewMode(
    ChangeSelfCardViewModeEvent event,
    Emitter<SelfCardsState> emit,
  ) {
    emit(state.copyWith(
      viewMode: event.mode,
      clearDetailsError: true,
    ));
  }

  Future<void> _onSearchSelfCards(
    SearchSelfCardsEvent event,
    Emitter<SelfCardsState> emit,
  ) async {
    emit(state.copyWith(
      isSearching: true,
      clearSearchError: true,
      searchQuery: event.query,
      activeOnly: event.activeOnly,
    ));

    final result = await searchSelfCards(
      query: event.query.isEmpty ? null : event.query,
      activeOnly: event.activeOnly,
      cursor: event.cursor,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSearching: false,
          searchError: failure.message,
        ));
      },
      (items) {
        emit(state.copyWith(
          isSearching: false,
          searchResults: items,
          clearSearchError: true,
        ));
      },
    );
  }

  Future<void> _onRecommendByTraining(
    RecommendByTrainingEvent event,
    Emitter<SelfCardsState> emit,
  ) async {
    final cleanTitle = event.title.trim();
    if (cleanTitle.isEmpty) {
      emit(state.copyWith(
        recommendationError: 'يرجى إدخال اسم الدورة التدريبية للترشيح',
      ));
      return;
    }

    emit(state.copyWith(
      isRecommending: true,
      clearRecommendationError: true,
      lastRecommendedCourseTitle: cleanTitle,
    ));

    final result = await recommendByTraining(
      title: cleanTitle,
      limit: event.limit,
      publicEntity: event.publicEntity,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          isRecommending: false,
          recommendationError: failure.message,
        ));
      },
      (recommendationResult) {
        emit(state.copyWith(
          isRecommending: false,
          recommendationResult: recommendationResult,
          clearRecommendationError: true,
        ));
      },
    );
  }

  void _onClearTrainingRecommendation(
    ClearTrainingRecommendationEvent event,
    Emitter<SelfCardsState> emit,
  ) {
    emit(state.copyWith(
      clearRecommendationResult: true,
      clearRecommendationError: true,
      lastRecommendedCourseTitle: '',
    ));
  }

  Future<void> _onSelectSelfCard(
    SelectSelfCardEvent event,
    Emitter<SelfCardsState> emit,
  ) async {
    emit(state.copyWith(
      isLoadingDetails: true,
      clearDetailsError: true,
    ));

    final result = await getSelfCardDetails(event.selfCardId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingDetails: false,
          detailsError: failure.message,
        ));
      },
      (card) {
        emit(state.copyWith(
          isLoadingDetails: false,
          selectedCard: card,
          clearDetailsError: true,
        ));
      },
    );
  }

  void _onClearSelectedSelfCard(
    ClearSelectedSelfCardEvent event,
    Emitter<SelfCardsState> emit,
  ) {
    emit(state.copyWith(
      clearSelectedCard: true,
      clearDetailsError: true,
      clearPdfStatus: true,
    ));
  }

  Future<void> _onExportSelfCardPdf(
    ExportSelfCardPdfEvent event,
    Emitter<SelfCardsState> emit,
  ) async {
    emit(state.copyWith(
      isExportingPdf: true,
      clearPdfStatus: true,
    ));

    try {
      final path = await SelfCardPdfGenerator.generateAndSave(event.selfCard);
      emit(state.copyWith(
        isExportingPdf: false,
        pdfExportedPath: path,
        pdfExportSuccessMessage: 'تم تصدير ملف PDF بنجاح وحفظه في مجلد التنزيلات',
      ));
    } catch (e) {
      emit(state.copyWith(
        isExportingPdf: false,
        pdfExportError: 'فشل تصدير ملف PDF: $e',
      ));
    }
  }

  void _onClearPdfExportStatus(
    ClearPdfExportStatusEvent event,
    Emitter<SelfCardsState> emit,
  ) {
    emit(state.copyWith(clearPdfStatus: true));
  }
}
