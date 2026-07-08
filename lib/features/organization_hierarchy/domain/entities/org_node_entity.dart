enum OrgNodeType { department, section, employee }

class OrgNodeEntity {
  final String id;
  final String title;
  final String? subtitle;
  final OrgNodeType type;
  final String? role; // مثلاً: مدير دائرة، رئيس شعبة، موظف
  final String? avatarUrl;
  final List<OrgNodeEntity> children;

  const OrgNodeEntity({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.role,
    this.avatarUrl,
    this.children = const [],
  });
}
