import 'package:equatable/equatable.dart';

import '../../domain/entities/self_card_entity.dart';
import '../../domain/entities/self_card_search_item_entity.dart';
import '../../domain/entities/training_recommendation_entity.dart';
import 'self_cards_event.dart';

class SelfCardsState extends Equatable {
  // Navigation / View mode
  final SelfCardViewMode viewMode;

  // Search state
  final bool isSearching;
  final List<SelfCardSearchItemEntity> searchResults;
  final String? searchError;
  final String searchQuery;
  final bool activeOnly;

  // Recommendation state
  final bool isRecommending;
  final TrainingRecommendationResultEntity? recommendationResult;
  final String? recommendationError;
  final String lastRecommendedCourseTitle;

  // Details state
  final bool isLoadingDetails;
  final SelfCardEntity? selectedCard;
  final String? detailsError;

  // PDF Export state
  final bool isExportingPdf;
  final String? pdfExportedPath;
  final String? pdfExportError;
  final String? pdfExportSuccessMessage;

  const SelfCardsState({
    this.viewMode = SelfCardViewMode.search,
    this.isSearching = false,
    this.searchResults = const [],
    this.searchError,
    this.searchQuery = '',
    this.activeOnly = true,
    this.isRecommending = false,
    this.recommendationResult,
    this.recommendationError,
    this.lastRecommendedCourseTitle = '',
    this.isLoadingDetails = false,
    this.selectedCard,
    this.detailsError,
    this.isExportingPdf = false,
    this.pdfExportedPath,
    this.pdfExportError,
    this.pdfExportSuccessMessage,
  });

  factory SelfCardsState.initial() => const SelfCardsState();

  SelfCardsState copyWith({
    SelfCardViewMode? viewMode,
    bool? isSearching,
    List<SelfCardSearchItemEntity>? searchResults,
    String? searchError,
    bool clearSearchError = false,
    String? searchQuery,
    bool? activeOnly,
    bool? isRecommending,
    TrainingRecommendationResultEntity? recommendationResult,
    bool clearRecommendationResult = false,
    String? recommendationError,
    bool clearRecommendationError = false,
    String? lastRecommendedCourseTitle,
    bool? isLoadingDetails,
    SelfCardEntity? selectedCard,
    bool clearSelectedCard = false,
    String? detailsError,
    bool clearDetailsError = false,
    bool? isExportingPdf,
    String? pdfExportedPath,
    String? pdfExportError,
    String? pdfExportSuccessMessage,
    bool clearPdfStatus = false,
  }) {
    return SelfCardsState(
      viewMode: viewMode ?? this.viewMode,
      isSearching: isSearching ?? this.isSearching,
      searchResults: searchResults ?? this.searchResults,
      searchError: clearSearchError ? null : (searchError ?? this.searchError),
      searchQuery: searchQuery ?? this.searchQuery,
      activeOnly: activeOnly ?? this.activeOnly,
      isRecommending: isRecommending ?? this.isRecommending,
      recommendationResult: clearRecommendationResult
          ? null
          : (recommendationResult ?? this.recommendationResult),
      recommendationError: clearRecommendationError
          ? null
          : (recommendationError ?? this.recommendationError),
      lastRecommendedCourseTitle:
          lastRecommendedCourseTitle ?? this.lastRecommendedCourseTitle,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
      selectedCard: clearSelectedCard ? null : (selectedCard ?? this.selectedCard),
      detailsError: clearDetailsError ? null : (detailsError ?? this.detailsError),
      isExportingPdf: isExportingPdf ?? this.isExportingPdf,
      pdfExportedPath: clearPdfStatus ? null : (pdfExportedPath ?? this.pdfExportedPath),
      pdfExportError: clearPdfStatus ? null : (pdfExportError ?? this.pdfExportError),
      pdfExportSuccessMessage: clearPdfStatus
          ? null
          : (pdfExportSuccessMessage ?? this.pdfExportSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        viewMode,
        isSearching,
        searchResults,
        searchError,
        searchQuery,
        activeOnly,
        isRecommending,
        recommendationResult,
        recommendationError,
        lastRecommendedCourseTitle,
        isLoadingDetails,
        selectedCard,
        detailsError,
        isExportingPdf,
        pdfExportedPath,
        pdfExportError,
        pdfExportSuccessMessage,
      ];
}
