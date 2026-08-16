import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../../../core/di/injection.dart';
import '../../../../../../core/services/session_service.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_text_styles.dart';
import '../../../../../organization_hierarchy/domain/entities/department_leaf_entity.dart';
import '../../../../../organization_hierarchy/domain/entities/department_role_entity.dart';
import '../../../../../organization_hierarchy/domain/usecases/get_department_leaves.dart';
import '../../../../../organization_hierarchy/domain/usecases/get_department_roles.dart';

class TaskAssignmentCard extends StatefulWidget {
  final bool isEnabled;
  final String? errorText;
  final int? initialDepartmentId;
  final int? initialRoleId;
  final void Function(int organizationId, int? departmentId, int? roleId)
      onAssignmentChanged;

  const TaskAssignmentCard({
    Key? key,
    this.isEnabled = true,
    this.errorText,
    this.initialDepartmentId,
    this.initialRoleId,
    required this.onAssignmentChanged,
  }) : super(key: key);

  @override
  State<TaskAssignmentCard> createState() => _TaskAssignmentCardState();
}

class _TaskAssignmentCardState extends State<TaskAssignmentCard> {
  int _resolvedOrgId = 1;
  bool _isLoadingDepartments = false;
  String? _departmentsError;
  List<DepartmentLeafEntity> _departments = [];

  int? _selectedDepartmentId;

  bool _isLoadingRoles = false;
  String? _rolesError;
  List<DepartmentRoleEntity> _roles = [];

  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.initialDepartmentId;
    _selectedRoleId = widget.initialRoleId;
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoadingDepartments = true;
      _departmentsError = null;
    });

    try {
      final sessionService = getIt<SessionService>();
      final orgId = await sessionService.resolveOrganizationId();
      _resolvedOrgId = orgId > 0 ? orgId : 1;

      final getDepartmentLeaves = getIt<GetDepartmentLeaves>();
      final result = await getDepartmentLeaves(_resolvedOrgId);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoadingDepartments = false;
            _departmentsError = failure.message;
          });
        },
        (leaves) {
          setState(() {
            _isLoadingDepartments = false;
            _departments = leaves;
          });

          if (_selectedDepartmentId != null) {
            final exists =
                leaves.any((dept) => dept.id == _selectedDepartmentId);
            if (exists) {
              _loadRoles(_selectedDepartmentId!);
            } else {
              _selectedDepartmentId = null;
            }
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDepartments = false;
        _departmentsError = e.toString();
      });
    }
  }

  Future<void> _loadRoles(int departmentId) async {
    setState(() {
      _isLoadingRoles = true;
      _rolesError = null;
      _roles = [];
    });

    try {
      final getDepartmentRoles = getIt<GetDepartmentRoles>();
      final result = await getDepartmentRoles(departmentId);

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoadingRoles = false;
            _rolesError = failure.message;
          });
        },
        (roles) {
          setState(() {
            _isLoadingRoles = false;
            _roles = roles;
          });

          if (_selectedRoleId != null) {
            final exists = roles.any((r) => r.id == _selectedRoleId);
            if (!exists) {
              _selectedRoleId = null;
              widget.onAssignmentChanged(
                  _resolvedOrgId, _selectedDepartmentId, null);
            }
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRoles = false;
        _rolesError = e.toString();
      });
    }
  }

  void _handleDepartmentChange(int? newDepartmentId) {
    if (newDepartmentId == null) return;
    setState(() {
      _selectedDepartmentId = newDepartmentId;
      _selectedRoleId = null;
    });

    widget.onAssignmentChanged(_resolvedOrgId, newDepartmentId, null);
    _loadRoles(newDepartmentId);
  }

  void _handleRoleChange(int? newRoleId) {
    if (newRoleId == null) return;
    setState(() {
      _selectedRoleId = newRoleId;
    });
    widget.onAssignmentChanged(
        _resolvedOrgId, _selectedDepartmentId, newRoleId);
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.gold.withOpacity(0.3),
            width: widget.errorText != null ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.userCheck,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'توجيه المعاملة (المرحلة القادمة)',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'حدد القسم والوظيفة المعنية باستلام المهمة التالية',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Department Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'القسم / الدائرة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: AppTextStyles.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoadingDepartments) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.charcoal.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.forest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'جاري تحميل الأقسام...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoal.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_departmentsError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _departmentsError!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.red.shade800),
                          ),
                        ),
                        TextButton(
                          onPressed: _loadDepartments,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<int>(
                    value: _selectedDepartmentId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      enabled: widget.isEnabled,
                      hintText: 'اختر القسم...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: widget.isEnabled
                          ? Colors.grey.shade50
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.charcoal.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.charcoal.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.forest, width: 1.5),
                      ),
                    ),
                    items: _departments.map((dept) {
                      return DropdownMenuItem<int>(
                        value: dept.id,
                        child: Text(
                          dept.fullPath,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged:
                        widget.isEnabled ? _handleDepartmentChange : null,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Role Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'الوظيفة / الدور',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: AppTextStyles.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedDepartmentId == null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.charcoal.withOpacity(0.1)),
                    ),
                    child: Text(
                      'يرجى اختيار القسم أولاً لرؤية الوظائف المتاحة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal.withOpacity(0.5),
                      ),
                    ),
                  ),
                ] else if (_isLoadingRoles) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.goldLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.charcoal.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.forest,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'جاري تحميل الوظائف...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.charcoal.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_rolesError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.alertCircle,
                            color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _rolesError!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.red.shade800),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _loadRoles(_selectedDepartmentId!),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                ] else if (_roles.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      'لا توجد وظائف مرتبطة بهذا القسم',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ] else ...[
                  DropdownButtonFormField<int>(
                    value: _selectedRoleId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      enabled: widget.isEnabled,
                      hintText: 'اختر الوظيفة...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal.withOpacity(0.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: widget.isEnabled
                          ? Colors.grey.shade50
                          : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.charcoal.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.charcoal.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.forest, width: 1.5),
                      ),
                    ),
                    items: _roles.map((role) {
                      return DropdownMenuItem<int>(
                        value: role.id,
                        child: Text(
                          role.name,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: widget.isEnabled ? _handleRoleChange : null,
                  ),
                ],
              ],
            ),

            if (widget.errorText != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.errorText!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.red.shade800,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
