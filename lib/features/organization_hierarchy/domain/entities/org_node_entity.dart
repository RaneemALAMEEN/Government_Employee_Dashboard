import 'organization_employee_entity.dart';

enum OrgNodeType { department, section, role, employee }

class OrgNodeEntity {
  final String id;
  final String title;
  final String? subtitle;
  final OrgNodeType type;
  final int? departmentId;
  final int? roleId;
  final String? roleCode;
  final OrganizationEmployeeEntity? employee;
  final bool canLoadChildren;
  final bool childrenLoaded;
  final bool loadingChildren;
  final String? childrenError;
  final List<OrgNodeEntity> children;

  const OrgNodeEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.departmentId,
    this.roleId,
    this.roleCode,
    this.employee,
    this.canLoadChildren = false,
    this.childrenLoaded = false,
    this.loadingChildren = false,
    this.childrenError,
    this.children = const [],
  });

  OrgNodeEntity copyWith({
    List<OrgNodeEntity>? children,
    bool? childrenLoaded,
    bool? loadingChildren,
    String? childrenError,
    bool clearChildrenError = false,
  }) {
    return OrgNodeEntity(
      id: id,
      title: title,
      subtitle: subtitle,
      type: type,
      departmentId: departmentId,
      roleId: roleId,
      roleCode: roleCode,
      employee: employee,
      canLoadChildren: canLoadChildren,
      childrenLoaded: childrenLoaded ?? this.childrenLoaded,
      loadingChildren: loadingChildren ?? this.loadingChildren,
      childrenError:
          clearChildrenError ? null : childrenError ?? this.childrenError,
      children: children ?? this.children,
    );
  }
}
