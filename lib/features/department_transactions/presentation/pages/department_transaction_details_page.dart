import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../bloc/certificate_details/department_certificate_bloc.dart';
import '../bloc/certificate_details/department_certificate_event.dart';
import '../bloc/certificate_details/department_certificate_state.dart';
import '../../../my_transactions/presentation/pages/transaction_details/widgets/employee_info_card.dart';
import '../../../my_transactions/presentation/pages/transaction_details/widgets/workflow_timeline_widget.dart';
import '../../../my_transactions/presentation/pages/transaction_details/widgets/stage_history_card.dart';

class DepartmentTransactionDetailsPage extends StatefulWidget {
  final String transactionId;

  const DepartmentTransactionDetailsPage({
    Key? key,
    required this.transactionId,
  }) : super(key: key);

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
    _bloc.add(LoadDepartmentCertificate(widget.transactionId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _downloadFile(String path, String filename) async {
    try {
      final dio = getIt<Dio>();
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$filename';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل الملف...')),
      );

      final fileUrl = _buildFileUrl(path);

      await dio.download(fileUrl, savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحميل الملف بنجاح: $filename\nالمسار: $savePath'),
            backgroundColor: AppColors.forest,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage =
            'فشل تحميل الملف. قد يكون تالفاً أو غير موجود على الخادم.';
        if (e is DioException) {
          if (e.response?.statusCode == 404) {
            errorMessage =
                'هناك مشكلة في هذا الملف ولا يمكن عرضه أو تنزيله ، يرجى التواصل مع من أرفقه لإعادة إرفاقه مرة أخرى';
          } else {
            errorMessage = 'حدث خطأ في الاتصال بالخادم عند محاولة تحميل الملف.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.umber,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _buildFileUrl(String pathOrUrl) {
    final trimmed = pathOrUrl.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith(RegExp(r'https?://'))) {
      return trimmed;
    }

    var baseUrl = dotenv.env['BASE_URL']?.trim() ?? '';
    if (baseUrl.isEmpty) {
      baseUrl = const String.fromEnvironment('BASE_URL',
          defaultValue: 'http://10.0.2.2:5000');
    }

    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    var normalizedPath = trimmed.replaceAll('\\', '/');
    if (!normalizedPath.startsWith('/')) {
      normalizedPath = '/$normalizedPath';
    }
    return '$baseUrl$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.goldLight,
      body: BlocBuilder<DepartmentCertificateBloc, DepartmentCertificateState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is DepartmentCertificateLoading ||
              state is DepartmentCertificateInitial) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.forest));
          }

          if (state is DepartmentCertificateFailure) {
            return AppErrorWidget(
              onRetry: () =>
                  _bloc.add(LoadDepartmentCertificate(widget.transactionId)),
            );
          }

          if (state is DepartmentCertificateLoaded) {
            final data = state.data;
            final processName =
                data['process_name']?.toString() ?? 'تفاصيل المعاملة';

            final history =
                data['transaction_history'] as Map<String, dynamic>? ?? {};
            final historyData = history['data'] as Map<String, dynamic>? ?? {};
            final applicant = historyData['applicant'] as Map<String, dynamic>?;
            final stages = historyData['stages'] as List<dynamic>? ?? [];

            final idProcess =
                history['id_process']?.toString() ?? widget.transactionId;
            final priorityVal = history['priority'];
            final priority = priorityVal == 1
                ? 'عالية'
                : (priorityVal == 2 ? 'عادية' : 'متوسطة');
            final status = data['status']?.toString() ?? '';

            // Extract final document
            final finalDocument =
                data['final_document'] as Map<String, dynamic>? ?? {};
            final hasFinalDoc = (finalDocument['file_url']?.toString() ??
                    finalDocument['file_path']?.toString() ??
                    '')
                .isNotEmpty;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  _DepartmentTransactionHeaderWidget(
                    processName: processName,
                    idProcess: idProcess,
                    priority: priority,
                    onBack: () => context.pop(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (applicant != null) ...[
                                  _buildApplicantInfo(applicant),
                                  const SizedBox(height: 24),
                                ],
                                ...stages.map((stage) => StageHistoryCard(
                                      stage: Map<String, dynamic>.from(stage),
                                      buildFileUrl: _buildFileUrl,
                                      onDownloadFile: _downloadFile,
                                    )),
                                if (stages.isNotEmpty)
                                  const SizedBox(height: 24),
                                if (hasFinalDoc)
                                  _buildFinalDocumentCard(finalDocument)
                                else
                                  _buildPendingDocumentCard(
                                      finalDocument['message']?.toString() ??
                                          'لم يتم توليد نسخة pdf من هذا الطلب'),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                WorkflowTimelineWidget(
                                  completedStages: stages,
                                  currentStage: null,
                                  isLocked: false,
                                  status: status,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildApplicantInfo(Map<String, dynamic> applicant) {
    // Map the applicant from the format "first_name_employee" to "firstName" that EmployeeInfoCard expects
    final mappedApplicant = {
      'firstName': applicant['first_name_employee'] ?? '',
      'lastName': applicant['last_name_employee'] ?? '',
      'nationalId': applicant['national_id_employee'] ?? '',
      'phoneNumber': applicant['phone_number_employee'] ?? '',
    };

    return EmployeeInfoCard(applicant: mappedApplicant);
  }

  Widget _buildFinalDocumentCard(Map<String, dynamic> finalDoc) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.fileCheck,
                      color: AppColors.forest, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'الوثيقة النهائية (الشهادة)',
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: AppTextStyles.bold, color: AppColors.forest),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'تم إصدار الشهادة بنجاح. يمكنك عرضها وتحميلها أدناه.',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            ),
            const SizedBox(height: 24),
            if ((finalDoc['file_url']?.toString() ??
                    finalDoc['file_path']?.toString() ??
                    '')
                .isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final url =
                            finalDoc['file_url'] ?? finalDoc['file_path'] ?? '';
                        if (url.isNotEmpty) {
                          final fullUrl = _buildFileUrl(url);
                          context.push('/pdf-viewer', extra: fullUrl);
                        }
                      },
                      icon: const Icon(LucideIcons.eye),
                      label: const Text('عرض الوثيقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.charcoal,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final url =
                            finalDoc['file_url'] ?? finalDoc['file_path'] ?? '';
                        final originalName =
                            finalDoc['original_name'] ?? 'certificate.pdf';
                        if (url.isNotEmpty) {
                          _downloadFile(url, originalName);
                        }
                      },
                      icon: const Icon(LucideIcons.download),
                      label: const Text('تحميل الوثيقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingDocumentCard(String message) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.umber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.fileClock,
                      color: AppColors.umber, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  'الوثيقة النهائية (الشهادة)',
                  style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: AppTextStyles.bold, color: AppColors.umber),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentTransactionHeaderWidget extends StatelessWidget {
  final String processName;
  final String idProcess;
  final String priority;
  final VoidCallback onBack;

  const _DepartmentTransactionHeaderWidget({
    Key? key,
    required this.processName,
    required this.idProcess,
    required this.priority,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowRight, color: AppColors.charcoal),
            onPressed: onBack,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  processName,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: AppColors.forest),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'رقم المعاملة: $idProcess',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.charcoal),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priority == 'عالية'
                            ? AppColors.umber.withOpacity(0.1)
                            : AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        priority,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: priority == 'عالية'
                              ? AppColors.umber
                              : AppColors.goldDark,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
