import '../../domain/entities/org_node_entity.dart';

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

  const OrgHierarchyLoaded({
    required this.organizationId,
    required this.nodes,
  });
}

class OrgHierarchyFailure extends OrgHierarchyState {
  final String message;

  const OrgHierarchyFailure(this.message);
}
