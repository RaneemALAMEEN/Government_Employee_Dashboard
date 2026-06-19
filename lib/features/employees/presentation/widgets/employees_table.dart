import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeesTable extends StatefulWidget {
  final List<EmployeeEntity> employees;

  const EmployeesTable({
    super.key,
    required this.employees,
  });

  @override
  State<EmployeesTable> createState() => _EmployeesTableState();
}

class _EmployeesTableState extends State<EmployeesTable> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double minWidth = 850;
          final double availableWidth = constraints.maxWidth;

          final tableContent = Column(
            children: [
              const _TableHeader(),
              if (widget.employees.isEmpty)
                Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const Text(
                    'لا يوجد موظفون يطابقون البحث',
                    style: TextStyle(
                      color: AppColors.charcoal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.employees.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    color: AppColors.gold.withOpacity(0.12),
                  ),
                  itemBuilder: (context, index) {
                    return _EmployeeRow(employee: widget.employees[index]);
                  },
                ),
            ],
          );

          if (availableWidth < minWidth) {
            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: minWidth,
                  child: tableContent,
                ),
              ),
            );
          } else {
            return tableContent;
          }
        },
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.goldLight.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          _HeaderText('الموظف', flex: 26),
          _HeaderText('الدور', flex: 18),
          _HeaderText('المعاملات النشطة', flex: 14),
          _HeaderText('المنجزة', flex: 12),
          _HeaderText('عبء العمل', flex: 18),
          _HeaderText('الحالة', flex: 12),
        ],
      ),
    );
  }
}

class _EmployeeRow extends StatelessWidget {
  final EmployeeEntity employee;

  const _EmployeeRow({required this.employee});

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(employee.avatarLetter);

    return InkWell(
      onTap: () {
        context.go('/employees/${employee.id}');
      },
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Employee Profile Avatar Info
            Expanded(
              flex: 26,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: avatarColor.withOpacity(0.12),
                    child: Text(
                      employee.avatarLetter,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: avatarColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        employee.department,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.charcoal.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Role
            Expanded(
              flex: 18,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  employee.role,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ),
            ),
            // Active Transactions
            Expanded(
              flex: 14,
              child: Center(
                child: Text(
                  '${employee.activeTxCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ),
            ),
            // Completed Transactions
            Expanded(
              flex: 12,
              child: Center(
                child: Text(
                  '${employee.doneTxCount}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ),
            ),
            // Workload (Percentage + bar)
            Expanded(
              flex: 18,
              child: Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${employee.workloadPercentage}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: employee.workloadPercentage / 100,
                        minHeight: 5,
                        backgroundColor: AppColors.goldLight,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getWorkloadColor(employee.workloadPercentage),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Status Badge
            Expanded(
              flex: 12,
              child: Center(
                child: _StatusBadge(status: employee.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String letter) {
    switch (letter) {
      case 'ح':
        return Colors.blue.shade700;
      case 'س':
        return Colors.teal.shade700;
      case 'ك':
        return Colors.blueGrey.shade700;
      case 'م':
        return AppColors.umber;
      case 'ت':
        return Colors.orange.shade800;
      case 'ر':
        return Colors.purple.shade700;
      case 'ب':
        return Colors.green.shade700;
      default:
        return AppColors.forest;
    }
  }

  Color _getWorkloadColor(int percent) {
    if (percent >= 80) {
      return AppColors.umber; // high load
    } else if (percent >= 50) {
      return AppColors.goldDark; // moderate
    } else {
      return AppColors.forest; // light
    }
  }
}

class _HeaderText extends StatelessWidget {
  final String text;
  final int flex;

  const _HeaderText(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (status) {
      case 'نشط':
        bg = AppColors.forestLight.withOpacity(0.12);
        fg = AppColors.forest;
        break;
      case 'مثقل':
        bg = AppColors.umber.withOpacity(0.1);
        fg = AppColors.umberLight;
        break;
      default: // غير نشط
        bg = AppColors.gold.withOpacity(0.15);
        fg = AppColors.goldDark;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          height: 1,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
