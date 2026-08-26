import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../../document_verification/presentation/widgets/document_verification_widgets.dart';
import '../bloc/certificate_details/department_certificate_bloc.dart';
import '../bloc/certificate_details/department_certificate_event.dart';
import '../bloc/certificate_details/department_certificate_state.dart';

class DepartmentTransactionDetailsPage extends StatefulWidget {
  final String transactionId;

  const DepartmentTransactionDetailsPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<DepartmentTransactionDetailsPage> createState() =>
      _DepartmentTransactionDetailsPageState();
}

class _DepartmentTransactionDetailsPageState
    extends State<DepartmentTransactionDetailsPage> {
  late final DepartmentCertificateBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<DepartmentCertificateBloc>();
    _load();
  }

  void _load() {
    _bloc.add(LoadDepartmentCertificate(widget.transactionId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<DepartmentCertificateBloc, DepartmentCertificateState>(
        builder: (context, state) {
          String processName = 'تفاصيل المعاملة';
          String? status;
          int? priority;

          if (state is DepartmentCertificateLoaded) {
            final history = state.data.transactionHistory;
            if (history.processName.isNotEmpty) {
              processName = history.processName;
            }
            status = state.data.transaction.status;
            priority = history.priority;
          }

          final isWide = MediaQuery.of(context).size.width > 950;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: AppColors.goldLight,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1320),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Breadcrumb
                          AppBackButton(
                            label: 'العودة لمعاملات الدائرة',
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/department-transactions');
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          // Header Widget
                          _DepartmentTransactionHeader(
                            processName: processName,
                            transactionId: widget.transactionId,
                            status: status,
                            priority: priority,
                            onRefresh: _load,
                          ),
                          const SizedBox(height: 24),
                          // Content Widget
                          switch (state) {
                            DepartmentCertificateLoading() ||
                            DepartmentCertificateInitial() =>
                              _buildSkeletonLoader(isWide),
                            DepartmentCertificateLoaded(:final data) =>
                              VerificationResult(
                                data: data,
                                transactionId:
                                    int.tryParse(widget.transactionId) ??
                                        data.transaction.id,
                                onDocumentGenerated: _load,
                              ),
                            DepartmentCertificateFailure(:final message) =>
                              VerificationErrorCard(
                                isNetworkError: message.contains('اتصال') ||
                                    message.contains('خادم') ||
                                    message.contains('network') ||
                                    message.contains('connect'),
                                isExpired: false,
                                onRetry: _load,
                                onReset: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/department-transactions');
                                  }
                                },
                              ),
                            _ => const SizedBox.shrink(),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader(bool isWide) {
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: const [
                CustomSkeletonLoader(width: double.infinity, height: 120),
                SizedBox(height: 20),
                CustomSkeletonLoader(width: double.infinity, height: 220),
                SizedBox(height: 20),
                CustomSkeletonLoader(width: double.infinity, height: 160),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const SizedBox(
            width: 320,
            child: CustomSkeletonLoader(width: double.infinity, height: 400),
          ),
        ],
      );
    }
    return Column(
      children: const [
        CustomSkeletonLoader(width: double.infinity, height: 120),
        SizedBox(height: 20),
        CustomSkeletonLoader(width: double.infinity, height: 220),
        SizedBox(height: 20),
        CustomSkeletonLoader(width: double.infinity, height: 160),
      ],
    );
  }
}

class _DepartmentTransactionHeader extends StatelessWidget {
  final String processName;
  final String transactionId;
  final String? status;
  final int? priority;
  final VoidCallback onRefresh;

  const _DepartmentTransactionHeader({
    required this.processName,
    required this.transactionId,
    required this.status,
    required this.priority,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeFg;
    String statusLabel = 'قيد المعالجة';

    final normalizedStatus = status?.trim().toLowerCase() ?? '';
    if (normalizedStatus == 'completed') {
      badgeBg = AppColors.forestLight.withOpacity(0.12);
      badgeFg = AppColors.forest;
      statusLabel = 'منجزة';
    } else if (normalizedStatus == 'rejected') {
      badgeBg = AppColors.umber.withOpacity(0.08);
      badgeFg = AppColors.umber;
      statusLabel = 'تم الرفض';
    } else if (normalizedStatus == 'in_progress') {
      badgeBg = Colors.orange.shade50;
      badgeFg = Colors.orange.shade700;
      statusLabel = 'قيد التنفيذ';
    } else {
      badgeBg = Colors.blue.shade50;
      badgeFg = Colors.blue.shade700;
      statusLabel = 'قيد المعالجة';
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          textDirection: TextDirection.rtl,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Wrap(
                  textDirection: TextDirection.rtl,
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      processName,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 26,
                        fontWeight: AppTextStyles.semiBold,
                        color: AppColors.forest,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusLabel,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: AppTextStyles.medium,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    if (priority == 1) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.umber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'مستعجل',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.medium,
                            color: AppColors.umber,
                          ),
                        ),
                      ),
                    ] else if (priority == 2) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'أولوية عادية',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: AppTextStyles.medium,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'رقم المعاملة: $transactionId',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: AppTextStyles.medium,
                    color: AppColors.charcoal.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              tooltip: 'تحديث البيانات',
              onPressed: onRefresh,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
