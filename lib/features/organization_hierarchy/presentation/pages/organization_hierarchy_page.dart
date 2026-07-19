import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/org_node_entity.dart';
import '../bloc/org_hierarchy_bloc.dart';
import '../bloc/org_hierarchy_event.dart';
import '../bloc/org_hierarchy_state.dart';
import '../widgets/org_node_widget.dart';

class OrganizationHierarchyPage extends StatelessWidget {
  const OrganizationHierarchyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrgHierarchyBloc>()..add(const LoadOrgHierarchy()),
      child: const _OrganizationHierarchyView(),
    );
  }
}

class _OrganizationHierarchyView extends StatelessWidget {
  const _OrganizationHierarchyView();

  void _showNodeDetails(BuildContext context, OrgNodeEntity node) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: Icon(
                  node.type == OrgNodeType.employee
                      ? LucideIcons.user
                      : LucideIcons.building,
                  size: 40,
                  color: AppColors.goldDark,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                node.title,
                style: AppTextStyles.headlineLarge
                    .copyWith(color: AppColors.charcoalDark),
                textAlign: TextAlign.center,
              ),
              if (node.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  node.subtitle!,
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.charcoal.withValues(alpha: 0.7)),
                  textAlign: TextAlign.center,
                ),
              ],
              if (node.employee != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.forestLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.forest.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'اسم المستخدم: ${node.employee!.userName}',
                    style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.forest,
                        fontWeight: AppTextStyles.bold),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.charcoalDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('إغلاق', style: AppTextStyles.titleSmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent, // assuming it's inside main dashboard
      body: BlocConsumer<OrgHierarchyBloc, OrgHierarchyState>(
        listenWhen: (previous, current) => current is OrgHierarchyFailure,
        listener: (context, state) {
          final failure = state as OrgHierarchyFailure;
          AppSnackBar.show(
            context,
            message: failure.message,
            isError: true,
            title: 'تعذر تحميل الهيكل التنظيمي',
          );
        },
        builder: (context, state) {
          if (state is OrgHierarchyLoading || state is OrgHierarchyInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.forest));
          }

          if (state is OrgHierarchyFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<OrgHierarchyBloc>()
                        .add(const LoadOrgHierarchy()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest),
                    child: const Text('إعادة المحاولة',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is OrgHierarchyLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الهيكل التنظيمي',
                            style: AppTextStyles.displayMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'هيكلية الأقسام والشعب والموظفين في المديرية',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.goldDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.charcoal.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: state.nodes.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(
                                  child: Text(
                                    'لا توجد أقسام مرتبطة بهذه المؤسسة.',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                ),
                              )
                            : Column(
                                children: state.nodes
                                    .map((node) => OrgNodeWidget(
                                          key: ValueKey(node.id),
                                          node: node,
                                          onNodeTap: (n) =>
                                              _showNodeDetails(context, n),
                                          onLoadChildren: (node) {
                                            if (node.type == OrgNodeType.role &&
                                                node.departmentId != null &&
                                                node.roleId != null) {
                                              context
                                                  .read<OrgHierarchyBloc>()
                                                  .add(
                                                    LoadRoleEmployees(
                                                      departmentId:
                                                          node.departmentId!,
                                                      roleId: node.roleId!,
                                                    ),
                                                  );
                                            } else if (node.departmentId !=
                                                null) {
                                              context
                                                  .read<OrgHierarchyBloc>()
                                                  .add(
                                                    LoadDepartmentRoles(
                                                      node.departmentId!,
                                                    ),
                                                  );
                                            }
                                          },
                                        ))
                                    .toList(),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
