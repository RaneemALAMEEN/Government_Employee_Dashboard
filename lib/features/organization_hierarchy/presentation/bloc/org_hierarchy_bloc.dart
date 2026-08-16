import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/department_leaf_entity.dart';
import '../../domain/entities/department_role_entity.dart';
import '../../domain/entities/org_node_entity.dart';
import '../../domain/entities/organization_employee_entity.dart';
import '../../domain/entities/organization_search_entity.dart';
import '../../domain/usecases/get_department_leaves.dart';
import '../../domain/usecases/get_department_roles.dart';
import '../../domain/usecases/get_organization_employees.dart';
import '../../domain/usecases/search_organization.dart';
import 'org_hierarchy_event.dart';
import 'org_hierarchy_state.dart';

class OrgHierarchyBloc extends Bloc<OrgHierarchyEvent, OrgHierarchyState> {
  final SessionService sessionService;
  final SearchOrganization searchOrganization;
  final GetDepartmentLeaves getDepartmentLeaves;
  final GetDepartmentRoles getDepartmentRoles;
  final GetOrganizationEmployees getOrganizationEmployees;
  Timer? _searchDebounce;
  CancelToken? _searchCancelToken;
  int _searchGeneration = 0;

  OrgHierarchyBloc({
    required this.sessionService,
    required this.searchOrganization,
    required this.getDepartmentLeaves,
    required this.getDepartmentRoles,
    required this.getOrganizationEmployees,
  }) : super(const OrgHierarchyInitial()) {
    on<LoadOrgHierarchy>(_onLoadHierarchy);
    on<SearchOrganizationHierarchy>(_onSearchHierarchy);
    on<RetryOrganizationSearch>(_onRetrySearch);
    on<ExecuteOrganizationSearch>(_onExecuteSearch);
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
      emit(const OrgHierarchyFailure(AuthFailure(
        'تعذر تحديد المؤسسة من جلسة الدخول. يرجى تسجيل الخروج والدخول مجدداً.',
        statusCode: 401,
      )));
      return;
    }

    final result = await getDepartmentLeaves(resolvedOrganizationId);
    if (emit.isDone) return;
    result.fold(
      (failure) => emit(OrgHierarchyFailure(failure)),
      (leaves) => emit(OrgHierarchyLoaded(
        organizationId: resolvedOrganizationId,
        nodes: _buildDepartmentTree(leaves),
      )),
    );
  }

  void _onSearchHierarchy(
    SearchOrganizationHierarchy event,
    Emitter<OrgHierarchyState> emit,
  ) {
    final current = state;
    if (current is! OrgHierarchyLoaded) return;
    final query = event.query.trim();
    _searchDebounce?.cancel();
    _searchCancelToken?.cancel('organization search changed');
    _searchCancelToken = null;
    _searchGeneration++;

    if (query.length < 2) {
      emit(current.copyWith(
        searchQuery: query,
        searchStatus: OrganizationSearchStatus.idle,
        searchNodes: const [],
        clearSearchFailure: true,
      ));
      return;
    }

    emit(current.copyWith(
      searchQuery: query,
      searchStatus: OrganizationSearchStatus.loading,
      clearSearchFailure: true,
    ));
    final generation = _searchGeneration;
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => add(ExecuteOrganizationSearch(query, generation)),
    );
  }

  void _onRetrySearch(
    RetryOrganizationSearch event,
    Emitter<OrgHierarchyState> emit,
  ) {
    final current = state;
    if (current is OrgHierarchyLoaded && current.isSearching) {
      add(SearchOrganizationHierarchy(current.searchQuery));
    }
  }

  Future<void> _onExecuteSearch(
    ExecuteOrganizationSearch event,
    Emitter<OrgHierarchyState> emit,
  ) async {
    final query = event.query;
    final generation = event.generation;
    final current = state;
    if (current is! OrgHierarchyLoaded ||
        generation != _searchGeneration ||
        current.searchQuery != query) {
      return;
    }
    final cancelToken = CancelToken();
    _searchCancelToken = cancelToken;
    final result = await searchOrganization(
      organizationId: current.organizationId,
      query: query,
      limit: 20,
      cancelToken: cancelToken,
    );
    if (generation != _searchGeneration || cancelToken.isCancelled) return;
    final latest = state;
    if (latest is! OrgHierarchyLoaded || latest.searchQuery != query) return;

    result.fold(
      (failure) => emit(latest.copyWith(
        searchStatus: OrganizationSearchStatus.failure,
        searchFailure: failure,
      )),
      (response) {
        final nodes = _buildSearchTree(response);
        emit(latest.copyWith(
          searchStatus: nodes.isEmpty
              ? OrganizationSearchStatus.empty
              : OrganizationSearchStatus.success,
          searchNodes: nodes,
          clearSearchFailure: true,
        ));
      },
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

    emit(current.copyWith(
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
      (failure) => emit(OrgHierarchyFailure(failure)),
      (roles) => emit(latest.copyWith(
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

    emit(current.copyWith(
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
      (failure) => emit(OrgHierarchyFailure(failure)),
      (employees) => emit(latest.copyWith(
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

  List<OrgNodeEntity> _buildSearchTree(OrganizationSearchEntity response) {
    final departments = <int, _SearchDepartmentNode>{};

    for (final department in response.departments) {
      departments.putIfAbsent(
        department.id,
        () => _SearchDepartmentNode(department.id, department.name),
      );
    }

    for (final role in response.roles) {
      final departmentId = role.departmentId;
      final departmentName = role.departmentName;
      if (departmentId == null || departmentName == null) continue;
      final department = departments.putIfAbsent(
        departmentId,
        () => _SearchDepartmentNode(departmentId, departmentName),
      );
      department.expand = true;
      department.roles.putIfAbsent(
        role.id,
        () => _SearchRoleNode(role.id, role.name, role.code),
      );
    }

    for (final employee in response.employees) {
      for (final assignment in employee.assignments) {
        final department = departments.putIfAbsent(
          assignment.departmentId,
          () => _SearchDepartmentNode(
            assignment.departmentId,
            assignment.departmentName,
          ),
        );
        department.expand = true;
        final role = department.roles.putIfAbsent(
          assignment.roleId,
          () => _SearchRoleNode(
            assignment.roleId,
            assignment.roleName,
            assignment.roleCode,
          ),
        );
        role.expand = true;
        role.employees.putIfAbsent(
          employee.id,
          () => _searchEmployeeNode(employee, assignment),
        );
      }
    }

    return departments.values.map((item) => item.toEntity()).toList();
  }

  OrgNodeEntity _searchEmployeeNode(
    OrganizationSearchEmployeeEntity employee,
    OrganizationSearchAssignmentEntity assignment,
  ) {
    return OrgNodeEntity(
      id: 'search_employee_${employee.id}_${assignment.assignmentId}',
      title: employee.fullName,
      subtitle: employee.email.isEmpty ? employee.userName : employee.email,
      type: OrgNodeType.employee,
      employee: OrganizationEmployeeEntity(
        assignmentId: assignment.assignmentId,
        organizationDepartmentRolesId: assignment.odrId,
        priority: 0,
        isActive: employee.isActive,
        userId: employee.id,
        userName: employee.userName,
        email: employee.email,
        phoneNumber: '',
        firstName: employee.firstName,
        lastName: employee.lastName,
        fatherName: employee.fatherName,
        motherName: employee.motherName,
        nationalId: employee.nationalId,
        userIsActive: employee.isActive,
      ),
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _searchCancelToken?.cancel('organization hierarchy closed');
    return super.close();
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

class _SearchDepartmentNode {
  final int id;
  final String name;
  final Map<int, _SearchRoleNode> roles = {};
  bool expand = false;

  _SearchDepartmentNode(this.id, this.name);

  OrgNodeEntity toEntity() => OrgNodeEntity(
        id: 'search_department_$id',
        title: name,
        type: OrgNodeType.department,
        departmentId: id,
        childrenLoaded: true,
        initiallyExpanded: expand,
        children: roles.values.map((item) => item.toEntity(id)).toList(),
      );
}

class _SearchRoleNode {
  final int id;
  final String name;
  final String code;
  final Map<int, OrgNodeEntity> employees = {};
  bool expand = false;

  _SearchRoleNode(this.id, this.name, this.code);

  OrgNodeEntity toEntity(int departmentId) => OrgNodeEntity(
        id: 'search_role_${departmentId}_$id',
        title: name,
        subtitle: code.isEmpty ? null : code,
        type: OrgNodeType.role,
        departmentId: departmentId,
        roleId: id,
        roleCode: code,
        childrenLoaded: true,
        initiallyExpanded: expand,
        children: employees.values.toList(),
      );
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
