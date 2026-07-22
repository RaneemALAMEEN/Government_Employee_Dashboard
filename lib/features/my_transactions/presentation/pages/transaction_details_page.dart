import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/my_transaction_entity.dart';
import '../../../internal_transactions/domain/entities/dynamic_widget_entity.dart';
import '../../../internal_transactions/data/models/dynamic_widget_model.dart';
import '../bloc/my_transactions_bloc.dart';
import '../bloc/my_transactions_event.dart';
import '../widgets/secure_signature_dialog.dart';

import '../bloc/transaction_details/transaction_details_bloc.dart';
import '../bloc/transaction_details/transaction_details_event.dart';
import '../bloc/transaction_details/transaction_details_state.dart';
import 'transaction_details/widgets/transaction_header_widget.dart';
import 'transaction_details/widgets/transaction_form_widget.dart';
import 'transaction_details/widgets/template_form_card.dart';
import 'transaction_details/widgets/employee_info_card.dart';
import 'transaction_details/widgets/stage_history_card.dart';
import 'transaction_details/widgets/lock_info_card.dart';
import 'transaction_details/widgets/workflow_timeline_widget.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;
  final String? status;

  const TransactionDetailsPage({
    Key? key,
    required this.transactionId,
    this.status,
  }) : super(key: key);

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late final TransactionDetailsBloc _bloc;
  final Map<String, dynamic> _formValues = {};

  @override
  void initState() {
    super.initState();
    _bloc = getIt<TransactionDetailsBloc>();
    _bloc.add(
        LoadTransactionDetails(widget.transactionId, status: widget.status));
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

  void _showSignatureDialog(List<DynamicWidgetEntity> widgets, String formId,
      String formName, bool isApprove,
      {List<int> templateIds = const [],
      List<Map<String, dynamic>> loadedTemplates = const [],
      Map<String, dynamic> templateFormValues = const {}}) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SecureSignatureDialog(
        transactionNumber: widget.transactionId,
      ),
    );

    if (result != null &&
        result.containsKey('pin') &&
        result.containsKey('keysDirectoryPath')) {
      _bloc.add(SubmitTransactionDetailsEvent(
        taskId: widget.transactionId,
        widgets: widgets,
        formValues: _formValues,
        formId: formId,
        formName: formName,
        isApprove: isApprove,
        pin: result['pin'],
        keysDirectoryPath: result['keysDirectoryPath'],
        templateIds: templateIds,
        loadedTemplates: loadedTemplates,
        templateFormValues: templateFormValues,
      ));
    }
  }

  void _handleActionSuccess(
      BuildContext context, TransactionDetailsActionSuccess state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(state.message), backgroundColor: AppColors.forest),
    );
    if (state.shouldReloadList) {
      if (getIt.isRegistered<MyTransactionsBloc>()) {
        getIt<MyTransactionsBloc>().add(LoadMyTransactions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.goldLight,
        body: BlocConsumer<TransactionDetailsBloc, TransactionDetailsState>(
          listener: (context, state) {
            if (state is TransactionDetailsFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.umber),
              );
            } else if (state is TransactionDetailsActionSuccess) {
              _handleActionSuccess(context, state);
            }
          },
          builder: (context, state) {
// ... (in builder)
            if (state is TransactionDetailsInitial ||
                state is TransactionDetailsLoading) {
              final isWide = MediaQuery.of(context).size.width > 950;
              return Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/my-transactions'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.arrowRight,
                              color: AppColors.charcoal,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'العودة للمعاملات',
                              style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: AppTextStyles.medium,
                                  color: AppColors.charcoal.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CustomSkeletonLoader(
                          width: double.infinity, height: 110),
                      const SizedBox(height: 24),
                      Expanded(
                        child: isWide
                            ? const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      children: [
                                        CustomSkeletonLoader(
                                            width: double.infinity,
                                            height: 120),
                                        SizedBox(height: 20),
                                        CustomSkeletonLoader(
                                            width: double.infinity,
                                            height: 250),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 24),
                                  Expanded(
                                    flex: 3,
                                    child: CustomSkeletonLoader(
                                        width: double.infinity, height: 400),
                                  ),
                                ],
                              )
                            : const SingleChildScrollView(
                                child: Column(
                                  children: [
                                    CustomSkeletonLoader(
                                        width: double.infinity, height: 120),
                                    SizedBox(height: 20),
                                    CustomSkeletonLoader(
                                        width: double.infinity, height: 250),
                                    SizedBox(height: 20),
                                    CustomSkeletonLoader(
                                        width: double.infinity, height: 400),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TransactionDetailsFailure &&
                _bloc.state is! TransactionDetailsLoaded) {
              return AppErrorWidget(
                onRetry: () =>
                    _bloc.add(LoadTransactionDetails(widget.transactionId)),
              );
            }

            TransactionDetailsLoaded? loadedState;
            bool isSubmitting = false;

            if (state is TransactionDetailsLoaded) {
              loadedState = state;
            } else if (state is TransactionDetailsSubmitting ||
                state is TransactionDetailsActionSuccess ||
                state is TransactionDetailsFailure) {
              // Try to find the latest loaded state from the bloc if possible, or just build a disabled view
              final currentState = _bloc.state;
              if (currentState is TransactionDetailsLoaded) {
                loadedState = currentState;
              } else if (state is TransactionDetailsSubmitting) {
                isSubmitting = true;
              }
            }

            if (state is TransactionDetailsSubmitting) {
              isSubmitting = true;
            }

            // Fallback if we don't have task data
            if (loadedState == null && !isSubmitting) {
              return const Center(child: Text('لا توجد بيانات'));
            }

            // If we are submitting and have no data, show loading
            if (loadedState == null && isSubmitting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.forest));
            }

            // Initialize form values from state if empty
            if (_formValues.isEmpty &&
                loadedState != null &&
                loadedState.formValues.isNotEmpty) {
              _formValues.addAll(loadedState.formValues);
            }

            final data = loadedState!.taskData;
            final processName =
                data['process_definition_name']?.toString() ?? 'تفاصيل العملية';
            final applicant = data['applicant'] as Map<String, dynamic>?;

            final history =
                data['transaction_history'] as Map<String, dynamic>? ?? {};
            final idProcess =
                history['id_process']?.toString() ?? widget.transactionId;
            final priorityVal = history['priority'];
            final priority = priorityVal == 1 ? 'عالية' : 'عادية';

            final historyData = history['data'] as Map<String, dynamic>? ?? {};
            final completedStages = historyData['stages'] as List? ?? [];

            final currentStage = data['currentStage'] as Map<String, dynamic>?;
            final config = currentStage?['config'] as Map<String, dynamic>?;
            final formId = config?['form_id']?.toString() ?? '';
            final formName = config?['form_name']?.toString() ?? '';

            final currentStageWidgets = (config?['widgets'] as List? ?? [])
                .map((w) =>
                    DynamicWidgetModel.fromJson(Map<String, dynamic>.from(w)))
                .toList();

            // Extract templateIds from config
            final templateJson = config?['template'] as List? ??
                config?['templates'] as List? ??
                [];
            final templateIds = templateJson
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return item['template_id'] ?? item['id'];
                  }
                  return item;
                })
                .where((id) => id != null)
                .map((id) => int.tryParse(id.toString()) ?? 0)
                .where((id) => id > 0)
                .toList();

            final taskLock = data['task_lock'] as Map<String, dynamic>? ?? {};
            final isLocked = taskLock['is_locked'] == true;
            final lockedByMe = taskLock['locked_by_me'] == true;

            String status = 'بانتظار الاستلام';
            if (data['status'] == 'completed') {
              status = 'منجزة';
            } else if (data['status'] == 'rejected') {
              status = 'تم الرفض';
            } else if (isLocked) {
              status = 'قيد التنفيذ';
            }

            final txn = MyTransactionEntity(
              idTask: widget.transactionId,
              number: idProcess,
              type: processName,
              applicant: applicant != null
                  ? '${applicant['first_name'] ?? ''} ${applicant['last_name'] ?? ''}'
                  : '',
              department: '',
              date: data['submitted_at']?.toString() ?? '',
              priority: priority,
              status: status,
              canSign: isLocked && lockedByMe,
            );

            final isWide = MediaQuery.of(context).size.width > 950;

            final rightContentList = [
              EmployeeInfoCard(applicant: applicant),
              const SizedBox(height: 20),
              if (data['final_document'] != null) ...[
                _buildFinalDocumentCard(
                    data['final_document'] as Map<String, dynamic>),
                const SizedBox(height: 20),
              ],
              ...completedStages.map((stage) => StageHistoryCard(
                    stage: Map<String, dynamic>.from(stage),
                    buildFileUrl: _buildFileUrl,
                    onDownloadFile: _downloadFile,
                  )),
              if (status != 'منجزة' && status != 'تم الرفض') ...[
                if (!isLocked) ...[
                  const LockInfoCard(),
                  const SizedBox(height: 20),
                ],
                if (currentStageWidgets.isNotEmpty) ...[
                  AbsorbPointer(
                    absorbing: !(isLocked && lockedByMe),
                    child: TransactionFormWidget(
                      widgets: currentStageWidgets,
                      formName: formName,
                      formValues: _formValues,
                      onChanged: (id, value) {
                        setState(() {
                          _formValues[id] = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (loadedState != null &&
                    loadedState.loadedTemplates.isNotEmpty) ...[
                  ...loadedState.loadedTemplates.map((template) {
                    final templateName = template['name']?.toString() ?? 'قالب';
                    final templateFilePath =
                        template['file_path']?.toString() ??
                            template['pdf_path']?.toString() ??
                            template['template_file']?.toString();
                    final configJson =
                        template['config_json'] as Map<String, dynamic>? ?? {};
                    final fields = configJson['widgets'] as List? ??
                        configJson['fields'] as List? ??
                        [];

                    final templateWidgets = fields.map((w) {
                      final wMap = w is Map
                          ? Map<String, dynamic>.from(w)
                          : <String, dynamic>{};
                      final widgetJson = {
                        'widget_type':
                            wMap['widget_type'] ?? wMap['type'] ?? 'text_field',
                        'data': wMap['data'] ?? wMap,
                      };
                      return DynamicWidgetModel.fromJson(widgetJson);
                    }).toList();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: AbsorbPointer(
                        absorbing: !(isLocked && lockedByMe),
                        child: TemplateFormCard(
                          templateName: templateName,
                          templateFilePath: templateFilePath,
                          onDownload: templateFilePath != null &&
                                  templateFilePath.isNotEmpty
                              ? () => _downloadFile(templateFilePath,
                                  templateFilePath.split('/').last)
                              : null,
                          widgets: templateWidgets,
                          formValues: loadedState!.templateFormValues,
                          onChanged: (id, value) {
                            _bloc.add(UpdateTemplateFormValue(id, value));
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ];

            final leftContent = WorkflowTimelineWidget(
                completedStages: completedStages,
                currentStage: currentStage,
                isLocked: isLocked,
                status: data['status']?.toString());

            final layoutWidget = Expanded(
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: rightContentList,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: leftContent,
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ...rightContentList,
                          const SizedBox(height: 20),
                          leftContent,
                        ],
                      ),
                    ),
            );

            return Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back breadcrumb
                    GestureDetector(
                      onTap: () => context.go('/my-transactions'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.arrowRight,
                            color: AppColors.charcoal,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'العودة للمعاملات',
                            style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: AppTextStyles.medium,
                                color: AppColors.charcoal.withOpacity(0.8)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Details Area
                    TransactionHeaderWidget(
                      txn: txn,
                      isLocked: isLocked,
                      lockedByMe: lockedByMe,
                      submitting: isSubmitting,
                      onPickup: () => _bloc
                          .add(PickupTransactionEvent(widget.transactionId)),
                      onRelease: () => _bloc
                          .add(ReleaseTransactionEvent(widget.transactionId)),
                      onApprove: () => _showSignatureDialog(
                          currentStageWidgets, formId, formName, true,
                          templateIds: templateIds,
                          loadedTemplates: loadedState?.loadedTemplates ?? [],
                          templateFormValues:
                              loadedState?.templateFormValues ?? {}),
                      onReject: () => _bloc.add(SubmitTransactionDetailsEvent(
                        taskId: widget.transactionId,
                        widgets: currentStageWidgets,
                        formValues: _formValues,
                        formId: formId,
                        formName: formName,
                        isApprove: false,
                        templateIds: templateIds,
                        loadedTemplates: loadedState?.loadedTemplates ?? [],
                        templateFormValues:
                            loadedState?.templateFormValues ?? {},
                      )),
                    ),
                    const SizedBox(height: 24),
                    layoutWidget,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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
}
