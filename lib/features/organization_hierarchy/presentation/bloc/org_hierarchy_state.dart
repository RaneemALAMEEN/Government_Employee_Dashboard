import '../../domain/entities/org_node_entity.dart';

abstract class OrgHierarchyState {}

class OrgHierarchyInitial extends OrgHierarchyState {}

class OrgHierarchyLoading extends OrgHierarchyState {}

class OrgHierarchyLoaded extends OrgHierarchyState {
  final List<OrgNodeEntity> nodes;
  OrgHierarchyLoaded(this.nodes);
}

class OrgHierarchyFailure extends OrgHierarchyState {
  final String message;
  OrgHierarchyFailure(this.message);
}
