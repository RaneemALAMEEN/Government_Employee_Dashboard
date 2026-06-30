import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/assigned_transaction_entity.dart';
import '../../domain/entities/employee_entity.dart';
import '../bloc/employees_bloc.dart';
import '../bloc/employees_event.dart';
import '../bloc/employees_state.dart';

class EmployeeDetailPage extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailPage({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeeDetailPage> createState() => _EmployeeDetailPageState();
}

class _EmployeeDetailPageState extends State<EmployeeDetailPage> {
  int _activeTab = 0; // 0 for basic info, 1 for system info

  @override
  void initState() {
    super.initState();
    // Dispatch details load event on start
    context.read<EmployeesBloc>().add(SelectEmployee(widget.employeeId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesBloc, EmployeesState>(
      builder: (context, state) {
        if (state is EmployeesLoading || state is EmployeesInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.forest,
            ),
          );
        }

        if (state is EmployeesFailure) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    context.read<EmployeesBloc>().add(SelectEmployee(widget.employeeId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forest,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        // We check if details are loaded or if we can extract from state
        if (state is EmployeeDetailsLoaded) {
          final employee = state.employee;
          return _buildDetailPageContent(context, employee);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDetailPageContent(BuildContext context, EmployeeEntity employee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button header
            GestureDetector(
              onTap: () {
                // Navigate back to the list screen
                context.read<EmployeesBloc>().add(const LoadEmployees());
                context.go('/employees');
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.arrowRight, // mirrors in RTL to face right for back
                      color: AppColors.forest,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'العودة إلى قائمة الموظفين',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Hero Banner
            _HeroProfileCard(employee: employee),
            const SizedBox(height: 24),

            // 6 Stats Cards Grid
            _StatsCardsGrid(employee: employee),
            const SizedBox(height: 24),

            // Split Grid columns for details/tabs and side metrics
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1150;

                final mainPanel = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tab Bar card
                    _InfoTabsCard(
                      employee: employee,
                      activeTab: _activeTab,
                      onTabChanged: (index) {
                        setState(() {
                          _activeTab = index;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Current assigned transactions table
                    _AssignedTransactionsTable(transactions: employee.assignedTransactions),
                  ],
                );

                final sidePanel = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _PerformanceIndicatorsCard(employee: employee),
                    const SizedBox(height: 20),
                    _CurrentWorkloadCard(employee: employee),
                  ],
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: mainPanel),
                      const SizedBox(width: 24),
                      SizedBox(width: 320, child: sidePanel),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      sidePanel,
                      const SizedBox(height: 24),
                      mainPanel,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Sub-widgets

class _HeroProfileCard extends StatelessWidget {
  final EmployeeEntity employee;

  const _HeroProfileCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Square Avatar box matching Figma mockup
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.forestDark.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.white.withOpacity(0.2), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    employee.avatarLetter,
                    style: AppTextStyles.headlineLarge.copyWith(fontSize: 28, color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name & Badges
                      Row(
                        children: [
                          Text(
                            employee.name,
                            style: AppTextStyles.headlineLarge.copyWith(color: AppColors.white),
                          ),
                          const SizedBox(width: 14),
                          // Badges
                          _HeroBadge(
                            text: employee.status,
                            color: employee.status == 'نشط'
                                ? Colors.teal.shade300
                                : employee.status == 'مثقل'
                                    ? Colors.red.shade300
                                    : Colors.orange.shade300,
                          ),
                          if (employee.workloadPercentage >= 80) ...[
                            const SizedBox(width: 8),
                            _HeroBadge(
                              text: 'ضغط مرتفع',
                              color: Colors.red.shade300,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Role & Department
                      Row(
                        children: [
                          Text(
                            employee.role,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1.5,
                            height: 12,
                            color: AppColors.white.withOpacity(0.3),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            LucideIcons.building,
                            size: 15,
                            color: AppColors.white.withOpacity(0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            employee.department,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.white.withOpacity(0.12),
          ),
          // Metadata bottom row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: LayoutBuilder(
              builder: (context, c) {
                final isCompact = c.maxWidth < 600;

                if (isCompact) {
                  return Column(
                    children: [
                      _MetaRowItem(label: 'رقم الموظف', value: employee.id),
                      const Divider(color: Colors.white12),
                      _MetaRowItem(label: 'تاريخ الانضمام', value: employee.joinDate),
                      const Divider(color: Colors.white12),
                      _MetaRowItem(label: 'مدة الخدمة', value: employee.serviceDuration),
                      const Divider(color: Colors.white12),
                      _MetaRowItem(label: 'آخر تسجيل دخول', value: employee.lastLogin),
                    ],
                  );
                }

                return Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _MetaRowItem(label: 'رقم الموظف', value: employee.id)),
                    Container(width: 1, height: 24, color: AppColors.white.withOpacity(0.12)),
                    Expanded(child: _MetaRowItem(label: 'تاريخ الانضمام', value: employee.joinDate)),
                    Container(width: 1, height: 24, color: AppColors.white.withOpacity(0.12)),
                    Expanded(child: _MetaRowItem(label: 'مدة الخدمة', value: employee.serviceDuration)),
                    Container(width: 1, height: 24, color: AppColors.white.withOpacity(0.12)),
                    Expanded(child: _MetaRowItem(label: 'آخر تسجيل دخول', value: employee.lastLogin)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _HeroBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: color),
      ),
    );
  }
}

class _MetaRowItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRowItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.white.withOpacity(0.5)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.white),
        ),
      ],
    );
  }
}

class _StatsCardsGrid extends StatelessWidget {
  final EmployeeEntity employee;

  const _StatsCardsGrid({required this.employee});

  @override
  Widget build(BuildContext context) {
    final list = [
      _StatData(
        value: '${employee.receivedTxCount}',
        label: 'المعاملات المستلمة',
        icon: LucideIcons.fileText,
        color: AppColors.forest,
      ),
      _StatData(
        value: '${employee.doneTxCount}',
        label: 'المعاملات المنجزة',
        icon: LucideIcons.checkCircle,
        color: AppColors.forest,
      ),
      _StatData(
        value: '${employee.activeTxCount}',
        label: 'قيد المعالجة',
        icon: LucideIcons.hourglass,
        color: AppColors.goldDark,
      ),
      _StatData(
        value: '${employee.lateTxCount}',
        label: 'معاملات متأخرة',
        icon: LucideIcons.alertTriangle,
        color: AppColors.umberLight,
      ),
      _StatData(
        value: '${employee.completionRate}%',
        label: 'معدل الإنجاز',
        icon: LucideIcons.trendingUp,
        color: AppColors.forest,
      ),
      _StatData(
        value: '${employee.avgProcessingTimeDays} يوم',
        label: 'متوسط زمن المعالجة',
        icon: LucideIcons.clock,
        color: AppColors.forest,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 950
                ? 3
                : 6;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final item = list[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.charcoal.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.icon, color: item.color, size: 18),
                      Text(
                        item.value,
                        style: AppTextStyles.headlineMedium.copyWith(color: item.color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      item.label,
                      style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoal.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StatData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _InfoTabsCard extends StatelessWidget {
  final EmployeeEntity employee;
  final int activeTab;
  final ValueChanged<int> onTabChanged;

  const _InfoTabsCard({
    required this.employee,
    required this.activeTab,
    required this.onTabChanged,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Tab Bar header
          Container(
            color: AppColors.goldLight.withOpacity(0.3),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _TabButton(
                  title: 'البيانات الأساسية',
                  isActive: activeTab == 0,
                  onTap: () => onTabChanged(0),
                ),
                _TabButton(
                  title: 'بيانات النظام',
                  isActive: activeTab == 1,
                  onTap: () => onTabChanged(1),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.gold.withOpacity(0.2)),

          // Tab content area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: activeTab == 0
                ? _buildBasicInfo(employee)
                : _buildSystemInfo(employee),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(EmployeeEntity emp) {
    final fields = [
      _InfoRow('الاسم الكامل', emp.name),
      _InfoRow('رقم الموظف', emp.id),
      _InfoRow('البريد الإلكتروني', emp.email),
      _InfoRow('رقم الهاتف', emp.phone),
      _InfoRow('القسم / الدائرة', emp.department),
      _InfoRow('المنصب الوظيفي', emp.role),
      _InfoRow('المدير المباشر', emp.directManager),
      _InfoRow('تاريخ التعيين', emp.hireDate),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final useGrid = c.maxWidth > 550;
        if (useGrid) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fields.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 16,
              childAspectRatio: 4.8,
            ),
            itemBuilder: (context, index) {
              final field = fields[index];
              return _buildFieldContainer(field.key, field.value);
            },
          );
        } else {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: fields.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final field = fields[index];
              return _buildFieldContainer(field.key, field.value);
            },
          );
        }
      },
    );
  }

  Widget _buildSystemInfo(EmployeeEntity emp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            final useGrid = c.maxWidth > 550;
            final fields = [
              _InfoRow('آخر تسجيل دخول', emp.lastLogin),
              _InfoRow('تاريخ إنشاء الحساب', emp.joinDate),
              _InfoRow('الدور الوظيفي', emp.role),
            ];

            if (useGrid) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fields.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 16,
                  childAspectRatio: 4.8,
                ),
                itemBuilder: (context, index) {
                  return _buildFieldContainer(fields[index].key, fields[index].value);
                },
              );
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: fields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildFieldContainer(fields[index].key, fields[index].value);
                },
              );
            }
          },
        ),
        const SizedBox(height: 24),
        Container(height: 1, color: AppColors.gold.withOpacity(0.15)),
        const SizedBox(height: 20),
        Text(
          'الصلاحيات الممنوحة',
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          textDirection: TextDirection.rtl,
          children: emp.permissions.map((perm) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.forestLight.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.forest.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.shield, size: 14, color: AppColors.forest),
                  const SizedBox(width: 6),
                  Text(
                    perm,
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFieldContainer(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            key,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal.withOpacity(0.5)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
          ),
        ],
      ),
    );
  }
}

class _InfoRow {
  final String key;
  final String value;
  const _InfoRow(this.key, this.value);
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.forest : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? AppColors.forest : AppColors.charcoal.withOpacity(0.8)),
        ),
      ),
    );
  }
}

class _AssignedTransactionsTable extends StatelessWidget {
  final List<AssignedTransactionEntity> transactions;

  const _AssignedTransactionsTable({required this.transactions});

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
      child: Column(
        children: [
          // Table header info section
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: AppColors.white,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'المعاملات المسندة حالياً',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${transactions.length} معاملة',
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.goldDark),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.gold.withOpacity(0.2)),

          LayoutBuilder(
            builder: (context, constraints) {
              const double minTableWidth = 750;
              final double availableWidth = constraints.maxWidth;

              final Widget tableContent = Column(
                children: [
                  // Table Header Row
                  Container(
                    height: 44,
                    color: AppColors.goldLight.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: const Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(flex: 12, child: _SubTableHeaderText('رقم المعاملة')),
                        Expanded(flex: 18, child: _SubTableHeaderText('النوع')),
                        Expanded(flex: 12, child: _SubTableHeaderText('تاريخ الاستلام')),
                        Expanded(flex: 10, child: _SubTableHeaderText('الأولوية')),
                        Expanded(flex: 12, child: _SubTableHeaderText('الحالة')),
                        Expanded(flex: 8, child: _SubTableHeaderText('الأيام')),
                      ],
                    ),
                  ),
                  if (transactions.isEmpty)
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text(
                        'لا توجد معاملات مسندة حالياً للموظف',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => Container(
                        height: 1,
                        color: AppColors.gold.withOpacity(0.12),
                      ),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        return Container(
                          height: 54,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // Number
                              Expanded(
                                flex: 12,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    tx.number,
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
                                  ),
                                ),
                              ),
                              // Type
                              Expanded(
                                flex: 18,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    tx.type,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoalDark),
                                  ),
                                ),
                              ),
                              // Date
                              Expanded(
                                flex: 12,
                                child: Center(
                                  child: Text(
                                    tx.receiveDate,
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.7)),
                                  ),
                                ),
                              ),
                              // Priority
                              Expanded(
                                flex: 10,
                                child: Center(
                                  child: _PriorityBadge(priority: tx.priority),
                                ),
                              ),
                              // Status
                              Expanded(
                                flex: 12,
                                child: Center(
                                  child: _TxStatusBadge(status: tx.status),
                                ),
                              ),
                              // Duration days
                              Expanded(
                                flex: 8,
                                child: Center(
                                  child: Text(
                                    '${tx.durationDays} يوم',
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );

              if (availableWidth < minTableWidth) {
                return Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minTableWidth,
                      child: tableContent,
                    ),
                  ),
                );
              } else {
                return tableContent;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SubTableHeaderText extends StatelessWidget {
  final String text;
  const _SubTableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: text == 'رقم المعاملة' || text == 'النوع' ? TextAlign.right : TextAlign.center,
      style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.bold),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final isHigh = priority == 'عالية';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHigh ? AppColors.umber.withOpacity(0.08) : AppColors.gold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.bold, color: isHigh ? AppColors.umberLight : AppColors.goldDark),
      ),
    );
  }
}

class _TxStatusBadge extends StatelessWidget {
  final String status;
  const _TxStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isReview = status == 'قيد المراجعة';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isReview ? Colors.blue.shade50 : AppColors.gold.withOpacity(0.14),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.bold, color: isReview ? Colors.blue.shade700 : AppColors.goldDark),
      ),
    );
  }
}

class _PerformanceIndicatorsCard extends StatelessWidget {
  final EmployeeEntity employee;

  const _PerformanceIndicatorsCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(LucideIcons.star, color: AppColors.forest, size: 20),
              SizedBox(width: 8),
              Text(
                'مؤشرات الأداء',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Completion Rate Progress Meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'معدل الإنجاز',
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
                  ),
                  Text(
                    '${employee.completionRate}%',
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: employee.completionRate / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.goldLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forest),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'متوسط القسم: 78%',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Avg processing duration indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.goldLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متوسط زمن المعالجة',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoal.withOpacity(0.6)),
                ),
                const SizedBox(height: 4),
                Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${employee.avgProcessingTimeDays} يوم',
                      style: AppTextStyles.headlineMedium,
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.trendingDown, size: 14, color: AppColors.forest),
                        SizedBox(width: 4),
                        Text(
                          'أفضل من المتوسط',
                          style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'متوسط القسم 2.4 يوم',
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.45)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Monthly Bar Chart
          Text(
            'المعاملات الشهرية (آخر 6 أشهر)',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.charcoalDark),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: employee.monthlyTxHistory.map((count) {
                // Determine height of the bar based on the count (max count around 35)
                final double barHeight = (count / 35) * 80;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 14,
                      height: barHeight.clamp(5, 80),
                      decoration: BoxDecoration(
                        color: AppColors.forestLight.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count',
                      style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.semiBold),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentWorkloadCard extends StatelessWidget {
  final EmployeeEntity employee;

  const _CurrentWorkloadCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'حجم العمل الحالي',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
              ),
              if (employee.workloadPercentage >= 80)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.umber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ضغط مرتفع',
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.umberLight),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Workload percentage & bar
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نسبة الحمل',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold),
              ),
              Text(
                '${employee.workloadPercentage}%',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: AppTextStyles.bold, color: AppColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: employee.workloadPercentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.goldLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                employee.workloadPercentage >= 80 ? AppColors.umber : AppColors.forest,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.gold.withOpacity(0.15)),
          const SizedBox(height: 16),

          // Detail rows of status
          _buildDetailRow('معاملات مفتوحة', '${employee.activeTxCount} معاملات'),
          const SizedBox(height: 10),
          _buildDetailRow('معاملات متأخرة', '${employee.lateTxCount} معاملات', isWarning: employee.lateTxCount > 0),
          const SizedBox(height: 10),
          _buildDetailRow('المعاملات المنجزة', '${employee.doneTxCount} معاملات'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoal.withOpacity(0.7)),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.bold, color: isWarning ? AppColors.umberLight : AppColors.charcoalDark),
        ),
      ],
    );
  }
}
