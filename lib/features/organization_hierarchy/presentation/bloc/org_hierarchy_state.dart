import '../../../../core/errors/failures.dart';
import '../../domain/entities/org_node_entity.dart';

enum OrganizationSearchStatus { idle, loading, success, empty, failure }

abstract class OrgHierarchyState {
  const OrgHierarchyState();
}

class OrgHierarchyInitial extends OrgHierarchyState {
  const OrgHierarchyInitial();
}

class OrgHierarchyLoading extends OrgHierarchyState {
  const OrgHierarchyLoading();
}

class OrgHierarchyLoaded extends OrgHierarchyState {
  final int organizationId;
  final List<OrgNodeEntity> nodes;
  final String searchQuery;
  final OrganizationSearchStatus searchStatus;
  final List<OrgNodeEntity> searchNodes;
  final Failure? searchFailure;

  const OrgHierarchyLoaded({
    required this.organizationId,
    required this.nodes,
    this.searchQuery = '',
    this.searchStatus = OrganizationSearchStatus.idle,
    this.searchNodes = const [],
    this.searchFailure,
  });

  bool get isSearching => searchQuery.trim().length >= 2;

  OrgHierarchyLoaded copyWith({
    List<OrgNodeEntity>? nodes,
    String? searchQuery,
    OrganizationSearchStatus? searchStatus,
    List<OrgNodeEntity>? searchNodes,
    Failure? searchFailure,
    bool clearSearchFailure = false,
  }) =>
      OrgHierarchyLoaded(
        organizationId: organizationId,
        nodes: nodes ?? this.nodes,
        searchQuery: searchQuery ?? this.searchQuery,
        searchStatus: searchStatus ?? this.searchStatus,
        searchNodes: searchNodes ?? this.searchNodes,
        searchFailure:
            clearSearchFailure ? null : searchFailure ?? this.searchFailure,
      );
}

class OrgHierarchyFailure extends OrgHierarchyState {
  final Failure failure;

  const OrgHierarchyFailure(this.failure);
}
