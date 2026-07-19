import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/session_service.dart';
import '../../domain/entities/department_leaf_entity.dart';
import '../../domain/entities/department_role_entity.dart';
import '../../domain/entities/org_node_entity.dart';
import '../../domain/entities/organization_employee_entity.dart';
import '../../domain/usecases/get_department_leaves.dart';
import '../../domain/usecases/get_department_roles.dart';
import '../../domain/usecases/get_organization_employees.dart';
import 'org_hierarchy_event.dart';
import 'org_hierarchy_state.dart';

class OrgHierarchyBloc extends Bloc<OrgHierarchyEvent, OrgHierarchyState> {
  final SessionService sessionService;
  final GetDepartmentLeaves getDepartmentLeaves;
  final GetDepartmentRoles getDepartmentRoles;
  final GetOrganizationEmployees getOrganizationEmployees;

  OrgHierarchyBloc({
    required this.sessionService,
    required this.getDepartmentLeaves,
    required this.getDepartmentRoles,
    required this.getOrganizationEmployees,
  }) : super(const OrgHierarchyInitial()) {
    on<LoadOrgHierarchy>(_onLoadHierarchy);
    on<LoadDepartmentRoles>(_onLoadDepartmentRoles);
    on<LoadRoleEmployees>(_onLoadRoleEmployees);
  }

  Future<void> _onLoadHierarchy(
    LoadOrgHierarchy event,
    Emitter<OrgHierarchyState> emit,
  ) async {
    emit(const OrgHierarchyLoading());
    final resolvedOrganizationId = await sessionService.resolveOrganizationId();

    if (resolvedOrganizationId <= 0) {
      emit(const OrgHierarchyFailure(
        'تعذر تحديد المؤسسة من جلسة الدخول. يرجى تسجيل الخروج والدخول مجدداً.',
      ));
      return;
    }

    final result = await getDepartmentLeaves(resolvedOrganizationId);
    if (emit.isDone) return;
    result.fold(
      (failure) => emit(OrgHierarchyFailure(failure.message)),
      (leaves) => emit(OrgHierarchyLoaded(
        organizationId: resolvedOrganizationId,
        nodes: _buildDepartmentTree(leaves),
      )),
    );
  }

  Future<void> _onLoadDepartmentRoles(
    LoadDepartmentRoles event,
    Emitter<OrgHierarchyState> emit,
  ) async {
    final current = state;
    if (current is! OrgHierarchyLoaded) return;
    final target = _findNode(current.nodes, 'department_${event.departmentId}');
    if (target == null || target.loadingChildren || target.childrenLoaded) {
      return;
    }

    emit(OrgHierarchyLoaded(
      organizationId: current.organizationId,
      nodes: _updateNode(
        current.nodes,
        target.id,
        (node) => node.copyWith(
          loadingChildren: true,
          clearChildrenError: true,
        ),
      ),
    ));

    final result = await getDepartmentRoles(event.departmentId);
    if (emit.isDone) return;
    final latest = state;
    if (latest is! OrgHierarchyLoaded) return;

    result.fold(
      (failure) => emit(OrgHierarchyLoaded(
        organizationId: latest.organizationId,
        nodes: _updateNode(
          latest.nodes,
          target.id,
          (node) => node.copyWith(
            loadingChildren: false,
            childrenError: failure.message,
          ),
        ),
      )),
      (roles) => emit(OrgHierarchyLoaded(
        organizationId: latest.organizationId,
        nodes: _updateNode(
          latest.nodes,
          target.id,
          (node) => node.copyWith(
            loadingChildren: false,
            childrenLoaded: true,
            clearChildrenError: true,
            children: roles
                .map((role) => _roleNode(event.departmentId, role))
                .toList(),
          ),
        ),
      )),
    );
  }

  Future<void> _onLoadRoleEmployees(
    LoadRoleEmployees event,
    Emitter<OrgHierarchyState> emit,
  ) async {
    final current = state;
    if (current is! OrgHierarchyLoaded) return;
    final nodeId = 'role_${event.departmentId}_${event.roleId}';
    final target = _findNode(current.nodes, nodeId);
    if (target == null || target.loadingChildren || target.childrenLoaded) {
      return;
    }

    emit(OrgHierarchyLoaded(
      organizationId: current.organizationId,
      nodes: _updateNode(
        current.nodes,
        nodeId,
        (node) => node.copyWith(
          loadingChildren: true,
          clearChildrenError: true,
        ),
      ),
    ));

    final result = await getOrganizationEmployees(
      organizationId: current.organizationId,
      departmentId: event.departmentId,
      roleId: event.roleId,
    );
    if (emit.isDone) return;
    final latest = state;
    if (latest is! OrgHierarchyLoaded) return;

    result.fold(
      (failure) => emit(OrgHierarchyLoaded(
        organizationId: latest.organizationId,
        nodes: _updateNode(
          latest.nodes,
          nodeId,
          (node) => node.copyWith(
            loadingChildren: false,
            childrenError: failure.message,
          ),
        ),
      )),
      (employees) => emit(OrgHierarchyLoaded(
        organizationId: latest.organizationId,
        nodes: _updateNode(
          latest.nodes,
          nodeId,
          (node) => node.copyWith(
            loadingChildren: false,
            childrenLoaded: true,
            clearChildrenError: true,
            children: employees.map(_employeeNode).toList(),
          ),
        ),
      )),
    );
  }

  List<OrgNodeEntity> _buildDepartmentTree(List<DepartmentLeafEntity> leaves) {
    final roots = <String, _MutableDepartmentNode>{};
    for (final leaf in leaves) {
      final parts = leaf.fullPath
          .split(RegExp(r'[\\/]+'))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.isEmpty) continue;

      var currentMap = roots;
      _MutableDepartmentNode? current;
      for (var index = 0; index < parts.length; index++) {
        final part = parts[index];
        current = currentMap.putIfAbsent(
          part,
          () => _MutableDepartmentNode(title: part, level: index),
        );
        currentMap = current.children;
      }
      current?.departmentId = leaf.id;
    }

    return roots.values.map((node) => node.toEntity()).toList();
  }

  OrgNodeEntity _roleNode(int departmentId, DepartmentRoleEntity role) {
    return OrgNodeEntity(
      id: 'role_${departmentId}_${role.id}',
      title: role.name,
      subtitle: role.code.isEmpty ? null : role.code,
      type: OrgNodeType.role,
      departmentId: departmentId,
      roleId: role.id,
      roleCode: role.code,
      canLoadChildren: true,
    );
  }

  OrgNodeEntity _employeeNode(OrganizationEmployeeEntity employee) {
    return OrgNodeEntity(
      id: 'employee_${employee.assignmentId}_${employee.userId}',
      title: employee.fullName,
      subtitle: employee.email.isNotEmpty ? employee.email : employee.userName,
      type: OrgNodeType.employee,
      employee: employee,
    );
  }

  OrgNodeEntity? _findNode(List<OrgNodeEntity> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      final found = _findNode(node.children, id);
      if (found != null) return found;
    }
    return null;
  }

  List<OrgNodeEntity> _updateNode(
    List<OrgNodeEntity> nodes,
    String id,
    OrgNodeEntity Function(OrgNodeEntity) update,
  ) {
    return nodes.map((node) {
      if (node.id == id) return update(node);
      if (node.children.isEmpty) return node;
      return node.copyWith(children: _updateNode(node.children, id, update));
    }).toList();
  }
}

class _MutableDepartmentNode {
  final String title;
  final int level;
  int? departmentId;
  final Map<String, _MutableDepartmentNode> children = {};

  _MutableDepartmentNode({required this.title, required this.level});

  OrgNodeEntity toEntity() {
    final leaf = departmentId != null;
    return OrgNodeEntity(
      id: leaf ? 'department_$departmentId' : 'department_path_${level}_$title',
      title: title,
      type: level == 0 ? OrgNodeType.department : OrgNodeType.section,
      departmentId: departmentId,
      canLoadChildren: leaf,
      childrenLoaded: !leaf,
      children: children.values.map((child) => child.toEntity()).toList(),
    );
  }
}
