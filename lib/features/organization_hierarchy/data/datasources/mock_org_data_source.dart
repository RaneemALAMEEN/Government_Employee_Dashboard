import '../../domain/entities/org_node_entity.dart';

class MockOrgDataSource {
  Future<List<OrgNodeEntity>> getOrganizationHierarchy() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      const OrgNodeEntity(
        id: 'dept_1',
        title: 'مديرية التربية',
        subtitle: 'الإدارة العامة لمديرية التربية',
        type: OrgNodeType.department,
        children: [
          OrgNodeEntity(
            id: 'emp_1',
            title: 'د. أحمد سالم',
            subtitle: 'مدير التربية',
            type: OrgNodeType.employee,
            role: 'مدير التربية',
          ),
          OrgNodeEntity(
            id: 'sec_1',
            title: 'دائرة الموارد البشرية',
            type: OrgNodeType.section,
            children: [
              OrgNodeEntity(
                id: 'emp_2',
                title: 'م. خالد النجار',
                subtitle: 'مدير دائرة الموارد البشرية',
                type: OrgNodeType.employee,
                role: 'مدير دائرة',
              ),
              OrgNodeEntity(
                id: 'emp_3',
                title: 'سميرة محمود',
                subtitle: 'معاون مدير دائرة',
                type: OrgNodeType.employee,
                role: 'معاون مدير',
              ),
              OrgNodeEntity(
                id: 'subsec_1',
                title: 'شعبة التوظيف',
                type: OrgNodeType.section,
                children: [
                  OrgNodeEntity(
                    id: 'emp_4',
                    title: 'رامي الحسن',
                    subtitle: 'رئيس شعبة التوظيف',
                    type: OrgNodeType.employee,
                    role: 'رئيس شعبة',
                  ),
                  OrgNodeEntity(
                    id: 'emp_5',
                    title: 'ليلى الخالدي',
                    subtitle: 'موظف توظيف',
                    type: OrgNodeType.employee,
                    role: 'موظف',
                  ),
                ]
              )
            ],
          ),
          OrgNodeEntity(
            id: 'sec_2',
            title: 'دائرة تقنية المعلومات',
            type: OrgNodeType.section,
            children: [
              OrgNodeEntity(
                id: 'emp_6',
                title: 'وسيم الجاسم',
                subtitle: 'مدير تقنية المعلومات',
                type: OrgNodeType.employee,
                role: 'مدير دائرة',
              ),
              OrgNodeEntity(
                id: 'subsec_2',
                title: 'شعبة الشبكات والدعم الفني',
                type: OrgNodeType.section,
                children: [
                  OrgNodeEntity(
                    id: 'emp_7',
                    title: 'علي درويش',
                    subtitle: 'رئيس شعبة',
                    type: OrgNodeType.employee,
                    role: 'رئيس شعبة',
                  ),
                  OrgNodeEntity(
                    id: 'emp_8',
                    title: 'سعد ياسين',
                    subtitle: 'مهندس شبكات',
                    type: OrgNodeType.employee,
                    role: 'موظف',
                  ),
                ]
              ),
            ],
          ),
        ],
      ),
      const OrgNodeEntity(
        id: 'dept_2',
        title: 'مديرية الشؤون المالية',
        subtitle: 'إدارة الموازنة والرواتب',
        type: OrgNodeType.department,
        children: [
          OrgNodeEntity(
            id: 'emp_9',
            title: 'فاطمة الزهراء',
            subtitle: 'مدير مالي',
            type: OrgNodeType.employee,
            role: 'مدير دائرة',
          ),
          OrgNodeEntity(
            id: 'subsec_3',
            title: 'شعبة الرواتب',
            type: OrgNodeType.section,
            children: [
              OrgNodeEntity(
                id: 'emp_10',
                title: 'عمر العبدالله',
                subtitle: 'محاسب رواتب',
                type: OrgNodeType.employee,
                role: 'موظف',
              ),
            ]
          )
        ],
      ),
    ];
  }
}
