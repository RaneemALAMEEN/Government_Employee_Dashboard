import 'dart:io';
import 'dart:typed_data';

import 'package:government_employee_dashboard/features/my_transactions/presentation/pages/image_viewer_page.dart';
import 'package:government_employee_dashboard/features/my_transactions/presentation/pages/pdf_viewer_page.dart';

import '../../../../shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../shared/utils/app_file_downloader.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/usb_signing_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';

import '../../domain/entities/my_transaction_entity.dart';
import '../../../internal_transactions/domain/entities/dynamic_widget_entity.dart';
import '../../../internal_transactions/data/models/dynamic_widget_model.dart';
import '../bloc/my_transactions_bloc.dart';
import '../bloc/my_transactions_event.dart';
import '../widgets/reject_transaction_dialog.dart';
import '../widgets/secure_signature_dialog.dart';
import '../widgets/transaction_signed_success_widget.dart';
import '../widgets/transaction_error_widget.dart';
import '../widgets/transaction_upload_progress_overlay.dart';

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
import 'transaction_details/widgets/transaction_info_card.dart';
import 'transaction_details/widgets/task_assignment_card.dart';
import 'transaction_details/widgets/signers_card.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;
  final String? status;
  final String? numericTransactionId;

  const TransactionDetailsPage({
    Key? key,
    required this.transactionId,
    this.status,
    this.numericTransactionId,
  }) : super(key: key);

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late final TransactionDetailsBloc _bloc;
  TransactionDetailsLoaded? _lastLoadedState;
  final Map<String, dynamic> _formValues = {};
  final Set<String> _formErrors = {};

  int? _assignmentOrgId;
  int? _assignmentDepartmentId;
  int? _assignmentRoleId;
  String? _assignmentError;

  bool _checkIsAssignment(
      Map<String, dynamic> data, Map<String, dynamic>? currentStage, Map<String, dynamic>? config) {
    for (final target in [currentStage, config, data]) {
      if (target == null) continue;
      final val = target['is_assignment'] ?? target['has_assignments'];
      if (val == true || val == 1 || val == '1' || val == 'true' || val == 'TRUE') {
        return true;
      }
      if (target['assignments'] is List) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _bloc = getIt<TransactionDetailsBloc>();
    _bloc.add(LoadTransactionDetails(
      widget.transactionId,
      status: widget.status,
      numericTransactionId: widget.numericTransactionId,
    ));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /// Returns the applicant's full name from the current loaded state.
  String _getApplicantName() {
    final state = _bloc.state;
    if (state is TransactionDetailsLoaded) {
      final applicant = state.taskData['applicant'] as Map<String, dynamic>?;
      if (applicant != null) {
        final first = applicant['first_name']?.toString() ?? '';
        final last = applicant['last_name']?.toString() ?? '';
        return '$first $last'.trim();
      }
    }
    return '';
  }

  Future<void> _downloadFile(String path, String filename,
      {String? documentType}) async {
    try {
      final dio = getIt<Dio>();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل الملف...')),
      );

      final fileUrl = _buildFileUrl(path);

      final response = await dio.get<List<int>>(
        fileUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': '*/*'},
        ),
      );

      final bytes =
          response.data != null ? Uint8List.fromList(response.data!) : null;

      if (response.statusCode != 200 || bytes == null || bytes.isEmpty) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      final contentType = response.headers.value('content-type');

      final savePath = await AppFileDownloader.getSavePath(
        applicantName: _getApplicantName(),
        documentType: documentType,
        originalFilename: filename,
        contentType: contentType,
        bytes: bytes,
      );

      final file = File(savePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        AppSnackBar.show(
          context,
          title: 'تم التحميل بنجاح',
          message: 'تم حفظ الملف بنجاح في:\n$savePath',
          isError: false,
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

        AppSnackBar.show(
          context,
          title: 'فشل التحميل',
          message: errorMessage,
          isError: true,
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

  void _showPickupRequiredNotice() {
    AppSnackBar.show(
      context,
      backgroundColor: AppColors.forest,
      icon: LucideIcons.info,
      title: 'المعاملة بانتظار الاستلام',
      message:
          'يرجى استلام المعاملة أولاً بالضغط على زر «استلام المعاملة» أعلاه لتتمكن من تعبئة الحقول واتخاذ الإجراءات.',
    );
  }


  void _showSignatureDialog(List<DynamicWidgetEntity> widgets, String formId,

      String formName, bool isApprove,
      {List<Map<String, dynamic>>? assignments,
      List<int> templateIds = const [],
      List<Map<String, dynamic>> loadedTemplates = const [],
      Map<String, dynamic> templateFormValues = const {},
      int? expectedVersion}) async {
    final sessionService = getIt<SessionService>();
    final sessionPin = sessionService.sessionPin;
    final username = sessionService.currentUserNotifier.value?.userName ?? '';

    final usbSigningService = getIt.isRegistered<UsbSigningService>()
        ? getIt<UsbSigningService>()
        : UsbSigningService();

    final discoveryResult =
        await usbSigningService.findUsbKeysDirectory(username);

    // 1. Auto-detection check: If USB keys folder is found AND session PIN exists, sign automatically!
    if (discoveryResult.status == UsbDiscoveryStatus.success &&
        discoveryResult.path != null &&
        sessionPin != null &&
        sessionPin.isNotEmpty) {
      _bloc.add(SubmitTransactionDetailsEvent(
        taskId: widget.transactionId,
        widgets: widgets,
        formValues: _formValues,
        formId: formId,
        formName: formName,
        isApprove: isApprove,
        pin: sessionPin,
        keysDirectoryPath: discoveryResult.path!,
        templateIds: templateIds,
        loadedTemplates: loadedTemplates,
        templateFormValues: templateFormValues,
        expectedVersion: expectedVersion,
        assignments: assignments,
      ));
      return;
    }

    // 2. If USB keys folder is missing or not inserted:
    if (discoveryResult.status != UsbDiscoveryStatus.success ||
        discoveryResult.path == null ||
        discoveryResult.path!.isEmpty) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'تعذر العثور على فلاشة التوقيع',
        message: discoveryResult.errorMessage ??
            'لم يتم العثور على وحدة USB متصلة تحتوي على مفاتيح التوقيع الرقمي الخاصة بحسابك.',
        isError: true,
        icon: LucideIcons.usb,
      );
      return;
    }

    // 3. If session PIN is missing:
    if (sessionPin == null || sessionPin.isEmpty) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'جلسة التوقيع غير مفعلة',
        message:
            'رمز PIN الخاص بجلسة التوقيع غير متوفر أو انتهت صلاحيته. يرجى تفعيل جلسة التوقيع أولاً.',
        isError: true,
        icon: LucideIcons.keyRound,
      );
      return;
    }



    /*
    // Manual Signature Dialog Fallback:
    if (!mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SecureSignatureDialog(
        transactionNumber: widget.transactionId,
        initialPin: sessionPin,
        initialKeysDirectory: discoveryResult.path,
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
        pin: result['pin']!,
        keysDirectoryPath: result['keysDirectoryPath']!,
        templateIds: templateIds,
        loadedTemplates: loadedTemplates,
        templateFormValues: templateFormValues,
        expectedVersion: expectedVersion,
      ));
    }
    */
  }

  void _handleRejectAction(
      List<DynamicWidgetEntity> widgets, String formId, String formName,
      {List<Map<String, dynamic>>? assignments,
      List<int> templateIds = const [],
      List<Map<String, dynamic>> loadedTemplates = const [],
      Map<String, dynamic> templateFormValues = const {},
      int? expectedVersion}) async {
    final note = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const RejectTransactionDialog(),
    );

    if (note == null || note.trim().isEmpty) {
      return;
    }

    final sessionService = getIt<SessionService>();
    final sessionPin = sessionService.sessionPin;
    final username = sessionService.currentUserNotifier.value?.userName ?? '';

    final usbSigningService = getIt.isRegistered<UsbSigningService>()
        ? getIt<UsbSigningService>()
        : UsbSigningService();

    final discoveryResult =
        await usbSigningService.findUsbKeysDirectory(username);

    if (discoveryResult.status == UsbDiscoveryStatus.success &&
        discoveryResult.path != null &&
        sessionPin != null &&
        sessionPin.isNotEmpty) {
      _bloc.add(SubmitTransactionDetailsEvent(
        taskId: widget.transactionId,
        widgets: widgets,
        formValues: _formValues,
        formId: formId,
        formName: formName,
        isApprove: false,
        note: note.trim(),
        pin: sessionPin,
        keysDirectoryPath: discoveryResult.path!,
        templateIds: templateIds,
        loadedTemplates: loadedTemplates,
        templateFormValues: templateFormValues,
        expectedVersion: expectedVersion,
        assignments: assignments,
      ));
      return;
    }

    // 2. If USB keys folder is missing or not inserted:
    if (discoveryResult.status != UsbDiscoveryStatus.success ||
        discoveryResult.path == null ||
        discoveryResult.path!.isEmpty) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'تعذر العثور على فلاشة التوقيع',
        message: discoveryResult.errorMessage ??
            'لم يتم العثور على وحدة USB متصلة تحتوي على مفاتيح التوقيع الرقمي الخاصة بحسابك.',
        isError: true,
        icon: LucideIcons.usb,
      );
      return;
    }

    // 3. If session PIN is missing:
    if (sessionPin == null || sessionPin.isEmpty) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        title: 'جلسة التوقيع غير مفعلة',
        message:
            'رمز PIN الخاص بجلسة التوقيع غير متوفر أو انتهت صلاحيته. يرجى تفعيل جلسة التوقيع أولاً.',
        isError: true,
        icon: LucideIcons.keyRound,
      );
      return;
    }



    /*
    // Manual Signature Dialog Fallback:
    if (!mounted) return;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SecureSignatureDialog(
        transactionNumber: widget.transactionId,
        initialPin: sessionPin,
        initialKeysDirectory: discoveryResult.path,
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
        isApprove: false,
        note: note.trim(),
        pin: result['pin']!,
        keysDirectoryPath: result['keysDirectoryPath']!,
        templateIds: templateIds,
        loadedTemplates: loadedTemplates,
        templateFormValues: templateFormValues,
        expectedVersion: expectedVersion,
      ));
    }
    */
  }

  void _handleActionSuccess(
      BuildContext context, TransactionDetailsActionSuccess state) {
    AppSnackBar.show(
      context,
      title: 'تمت العملية بنجاح',
      message: state.message,
      isError: false,
    );
    if (state.shouldReloadList) {
      if (getIt.isRegistered<MyTransactionsBloc>()) {
        getIt<MyTransactionsBloc>().add(const LoadMyTransactions());
      }
    }
  }

  bool _validateRequiredFields(List<DynamicWidgetModel> stageWidgets,
      TransactionDetailsLoaded? loadedState) {
    bool isValid = true;

    setState(() {
      _formErrors.clear();
    });

    // Validate stage widgets
    for (var widget in stageWidgets) {
      final isRequired = widget.data['is_required'] == true;
      final id = widget.data['id']?.toString() ?? '';

      // Skip decision and gateway fields
      if (widget.data['is_gateway'] == true || id == 'decision') continue;

      if (isRequired) {
        final value = _formValues[id];
        if (value == null ||
            (value is String && value.trim().isEmpty) ||
            (value is List && value.isEmpty)) {
          isValid = false;
          _formErrors.add(id);
        }
      }
    }

    // Validate template widgets
    if (loadedState != null && loadedState.loadedTemplates.isNotEmpty) {
      for (var template in loadedState.loadedTemplates) {
        final configJson =
            template['config_json'] as Map<String, dynamic>? ?? {};
        final fields = configJson['widgets'] as List? ??
            configJson['fields'] as List? ??
            [];
        final templateValues = loadedState.templateFormValues;

        for (var w in fields) {
          final wMap =
              w is Map ? Map<String, dynamic>.from(w) : <String, dynamic>{};
          final data = wMap['data'] ?? wMap;
          final isRequired = data['is_required'] == true;
          final id = data['id']?.toString() ?? '';

          if (isRequired) {
            final value = templateValues[id];
            if (value == null ||
                (value is String && value.trim().isEmpty) ||
                (value is List && value.isEmpty)) {
              isValid = false;
              _formErrors.add(id);
            }
          }
        }
      }
    }

    if (!isValid) {
      setState(() {});
      AppSnackBar.show(
        context,
        title: 'حقول مطلوبة',
        message: 'يرجى تعبئة جميع الحقول المطلوبة والمحددة باللون الأحمر.',
        isError: true,
      );
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.goldLight,
        body: BlocConsumer<TransactionDetailsBloc, TransactionDetailsState>(
          listener: (context, state) {
            if (state is TransactionSignedSuccess) {
              if (getIt.isRegistered<MyTransactionsBloc>()) {
                getIt<MyTransactionsBloc>().add(const LoadMyTransactions());
              }
            } else if (state is TransactionDetailsFailure) {
              AppSnackBar.show(
                context,
                title: 'فشل العملية',
                message: state.message,
                isError: true,
              );
            } else if (state is TransactionDetailsActionSuccess) {
              _handleActionSuccess(context, state);
            }
          },

          builder: (context, state) {
            if (state is TransactionDetailsLoaded) {
              _lastLoadedState = state;
            }

            if (state is TransactionSignedSuccess) {
              return TransactionSignedSuccessWidget(
                taskId: state.taskId,
                transactionId: state.transactionId,
                message: state.message,
                isApproved: state.isApproved,
                onBack: () => context.go('/my-transactions'),
                onViewCompleted: () {
                  _bloc.add(LoadTransactionDetails(
                    state.transactionId,
                    status: state.isApproved ? 'منجزة' : 'تم الرفض',
                  ));
                },
              );
            }

            if (state is TransactionSubmitError) {
              return TransactionErrorWidget(
                errorCode: state.errorCode,
                title: state.title,
                message: state.message,
                suggestions: state.suggestions,
                onBack: () => context.go('/my-transactions'),
                onRetry: () {
                  _bloc.add(LoadTransactionDetails(state.taskId));
                },
              );
            }

            if ((state is TransactionDetailsInitial ||
                    state is TransactionDetailsLoading) &&
                _lastLoadedState == null) {
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
                _lastLoadedState == null &&
                _bloc.state is! TransactionDetailsLoaded) {
              return AppErrorWidget(
                onRetry: () =>
                    _bloc.add(LoadTransactionDetails(widget.transactionId)),
              );
            }

            TransactionDetailsLoaded? loadedState;
            bool isSubmitting = false;
            bool isUploadingFiles = false;
            String? submittingMessage;
            String? submittingStage;
            String? submittingFileName;
            int? submittingFileIndex;
            int? submittingTotalFiles;
            double? submittingProgress;

            if (state is TransactionDetailsLoaded) {
              loadedState = state;
              _lastLoadedState = state;
            } else if (state is TransactionDetailsSubmitting) {
              loadedState = state.previousLoadedState ?? _lastLoadedState;
              isSubmitting = true;
              isUploadingFiles = state.isUploadingFiles;
              submittingMessage = state.message;
              submittingStage = state.stage;
              submittingFileName = state.currentFileName;
              submittingFileIndex = state.currentFileIndex;
              submittingTotalFiles = state.totalFiles;
              submittingProgress = state.progress;
            } else {
              loadedState = _lastLoadedState;
            }

            // Fallback if we don't have task data
            if (loadedState == null && !isSubmitting) {
              return const Center(child: Text('لا توجد بيانات'));
            }

            // If we are submitting and have no data
            if (loadedState == null && isSubmitting) {
              if (isUploadingFiles) {
                return TransactionUploadProgressOverlay(
                  message: submittingMessage,
                  stage: submittingStage,
                  currentFileName: submittingFileName,
                  currentFileIndex: submittingFileIndex,
                  totalFiles: submittingTotalFiles,
                  progress: submittingProgress,
                );
              }
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
              isLockedByMe: isLocked && lockedByMe,
            );

            final isWide = MediaQuery.of(context).size.width > 950;

            final signers = data['signers'] as List? ?? [];
            final finalDoc = data['final_document'] as Map<String, dynamic>?;

            final rightContentList = [
              EmployeeInfoCard(applicant: applicant),
              const SizedBox(height: 20),
              TransactionInfoCard(
                taskData: data,
                status: status,
                transactionNumber: idProcess,
              ),
              const SizedBox(height: 20),
              if (signers.isNotEmpty) ...[
                SignersCard(signers: signers),
                const SizedBox(height: 20),
              ],
              if (finalDoc != null || status == 'منجزة') ...[
                _buildFinalDocumentCard(
                  finalDoc ??
                      const {
                        'available': false,
                        'message': 'لم يتم توليد نسخة pdf من هذا الطلب'
                      },
                ),
                const SizedBox(height: 20),
              ],
              ...completedStages.where((stage) {
                final name = (stage as Map)['stage_name']?.toString() ?? '';
                final formName = stage['form_name']?.toString() ?? '';
                // Filter out internal system stages
                return !name.toUpperCase().contains('GENERATE_PDF') &&
                    !formName.toUpperCase().contains('GENERATE_PDF');
              }).map((stage) => StageHistoryCard(
                    stage: Map<String, dynamic>.from(stage as Map),
                    buildFileUrl: _buildFileUrl,
                    onDownloadFile: _downloadFile,
                  )),
              if (status != 'منجزة' && status != 'تم الرفض') ...[
                // Banner when locked by another employee
                if (isLocked && !lockedByMe) ...[
                  FadeInUp(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(LucideIcons.lock,
                                color: Colors.red.shade700, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'هذه المعاملة مقفلة حالياً',
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: AppTextStyles.bold,
                                    color: Colors.red.shade800,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'تم قفل هذه المعاملة بواسطة موظف آخر ولا يمكنك اتخاذ أي إجراء عليها حتى يتم تحريرها.',
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.red.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (!isLocked) ...[
                  const LockInfoCard(),
                  const SizedBox(height: 20),
                ],
                if (currentStageWidgets.isNotEmpty) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: !(isLocked && lockedByMe)
                        ? _showPickupRequiredNotice
                        : null,
                    child: AbsorbPointer(
                      absorbing: !(isLocked && lockedByMe),
                      child: TransactionFormWidget(
                        widgets: currentStageWidgets,
                        formName: formName,
                        formValues: _formValues,
                        formErrors: _formErrors,
                        onChanged: (id, value) {
                          _formValues[id] = value;
                          setState(() {
                            _formErrors.remove(id);
                          });
                        },

                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (status != 'منجزة' &&
                    status != 'تم الرفض' &&
                    _checkIsAssignment(data, currentStage, config)) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: !(isLocked && lockedByMe)
                        ? _showPickupRequiredNotice
                        : null,
                    child: TaskAssignmentCard(
                      isEnabled: isLocked && lockedByMe,
                      errorText: _assignmentError,
                      initialDepartmentId: _assignmentDepartmentId,
                      initialRoleId: _assignmentRoleId,
                      onAssignmentChanged: (orgId, deptId, roleId) {
                        setState(() {
                          _assignmentOrgId = orgId;
                          _assignmentDepartmentId = deptId;
                          _assignmentRoleId = roleId;
                          if (deptId != null && roleId != null) {
                            _assignmentError = null;
                          }
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: !(isLocked && lockedByMe)
                            ? _showPickupRequiredNotice
                            : null,
                        child: TemplateFormCard(
                          templateName: templateName,
                          templateFilePath: templateFilePath,
                          isReadOnly: !(isLocked && lockedByMe),
                          onDownload: templateFilePath != null &&
                                  templateFilePath.isNotEmpty
                              ? () => _downloadFile(templateFilePath,
                                  templateFilePath.split('/').last,
                                  documentType: 'قالب - $templateName')
                              : null,
                          onView: templateFilePath != null &&
                                  templateFilePath.isNotEmpty
                              ? () {
                                  final fullUrl = _buildFileUrl(templateFilePath);
                                  final ext = AppFileDownloader.extractExtension(
                                    templateFilePath,
                                    fallbackExtension: templateName,
                                  );
                                  final isImage = [
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'gif',
                                    'bmp',
                                    'webp'
                                  ].contains(ext);
                                  if (isImage) {
                                    context.push('/image-viewer', extra: {
                                      'fileUrl': fullUrl,
                                      'title': templateName,
                                    });
                                  } else {
                                    context.push('/pdf-viewer', extra: {
                                      'fileUrl': fullUrl,
                                      'title': templateName,
                                    });
                                  }
                                }
                              : null,
                          widgets: templateWidgets,
                          formValues: loadedState!.templateFormValues,
                          formErrors: _formErrors,
                          onChanged: (id, value) {
                            _bloc.add(UpdateTemplateFormValue(id, value));
                            if (_formErrors.contains(id)) {
                              setState(() {
                                _formErrors.remove(id);
                              });
                            }
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

            return Stack(
              children: [
                AbsorbPointer(
                  absorbing: isSubmitting,
                  child: Padding(
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
                            submittingMessage: submittingMessage,
                            onPickup: () => _bloc
                                .add(PickupTransactionEvent(widget.transactionId)),
                            onRelease: () => _bloc
                                .add(ReleaseTransactionEvent(widget.transactionId)),
                            onApprove: () {
                              if (!_validateRequiredFields(
                                  currentStageWidgets, loadedState)) return;
                              final isAssignment =
                                  _checkIsAssignment(data, currentStage, config);
                              if (isAssignment) {
                                if (_assignmentDepartmentId == null ||
                                    _assignmentRoleId == null) {
                                  setState(() {
                                    _assignmentError =
                                        'يرجى اختيار القسم (الدائرة) والوظيفة (Role) لتوجيه المعاملة';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'يرجى اختيار القسم (الدائرة) والوظيفة (Role) لتوجيه المعاملة'),
                                      backgroundColor: AppColors.umber,
                                    ),
                                  );
                                  return;
                                }
                              }
                              final List<Map<String, dynamic>>? assignmentsPayload =
                                  isAssignment &&
                                          _assignmentDepartmentId != null &&
                                          _assignmentRoleId != null
                                      ? [
                                          {
                                            'organization_id': _assignmentOrgId ?? 1,
                                            'department_id': _assignmentDepartmentId,
                                            'role_id': _assignmentRoleId,
                                          }
                                        ]
                                      : null;
                              final rawVersion = data['expected_version'] ??
                                  data['version'] ??
                                  (data['transaction'] is Map
                                      ? data['transaction']['version']
                                      : null);
                              final parsedVersion = rawVersion != null
                                  ? int.tryParse(rawVersion.toString())
                                  : null;

                              _showSignatureDialog(
                                  currentStageWidgets, formId, formName, true,
                                  assignments: assignmentsPayload,
                                  templateIds: templateIds,
                                  loadedTemplates: loadedState?.loadedTemplates ?? [],
                                  templateFormValues:
                                      loadedState?.templateFormValues ?? {},
                                  expectedVersion: parsedVersion);
                            },
                            onReject: () {
                              if (!_validateRequiredFields(
                                  currentStageWidgets, loadedState)) return;
                              final isAssignment =
                                  _checkIsAssignment(data, currentStage, config);
                              if (isAssignment) {
                                if (_assignmentDepartmentId == null ||
                                    _assignmentRoleId == null) {
                                  setState(() {
                                    _assignmentError =
                                        'يرجى اختيار القسم (الدائرة) والوظيفة (Role) لتوجيه المعاملة';
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'يرجى اختيار القسم (الدائرة) والوظيفة (Role) لتوجيه المعاملة'),
                                      backgroundColor: AppColors.umber,
                                    ),
                                  );
                                  return;
                                }
                              }
                              final List<Map<String, dynamic>>? assignmentsPayload =
                                  isAssignment &&
                                          _assignmentDepartmentId != null &&
                                          _assignmentRoleId != null
                                      ? [
                                          {
                                            'organization_id': _assignmentOrgId ?? 1,
                                            'department_id': _assignmentDepartmentId,
                                            'role_id': _assignmentRoleId,
                                          }
                                        ]
                                      : null;

                              final rawVersion = data['expected_version'] ??
                                  data['version'] ??
                                  (data['transaction'] is Map
                                      ? data['transaction']['version']
                                      : null);
                              final parsedVersion = rawVersion != null
                                  ? int.tryParse(rawVersion.toString())
                                  : null;

                              _handleRejectAction(
                                  currentStageWidgets, formId, formName,
                                  assignments: assignmentsPayload,
                                  templateIds: templateIds,
                                  loadedTemplates: loadedState?.loadedTemplates ?? [],
                                  templateFormValues:
                                      loadedState?.templateFormValues ?? {},
                                  expectedVersion: parsedVersion);
                            },
                          ),
                          const SizedBox(height: 24),
                          layoutWidget,
                        ],
                      ),
                    ),
                  ),
                ),

                // Upload Progress Overlay (ONLY when files are being uploaded to the server)
                if (isUploadingFiles)
                  TransactionUploadProgressOverlay(
                    message: submittingMessage,
                    stage: submittingStage,
                    currentFileName: submittingFileName,
                    currentFileIndex: submittingFileIndex,
                    totalFiles: submittingTotalFiles,
                    progress: submittingProgress,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFinalDocumentCard(Map<String, dynamic> finalDoc) {
    final fileUrl = finalDoc['file_url']?.toString() ??
        finalDoc['file_path']?.toString() ??
        '';
    final isAvailable = finalDoc['available'] != false && fileUrl.isNotEmpty;
    final message = finalDoc['message']?.toString() ??
        'لم يتم توليد نسخة pdf من هذا الطلب';

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? AppColors.forest.withOpacity(0.3)
                : AppColors.gold.withOpacity(0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.forestLight.withOpacity(0.1)
                        : AppColors.goldLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAvailable ? LucideIcons.fileCheck : LucideIcons.fileClock,
                    color: isAvailable ? AppColors.forest : AppColors.goldDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'الوثيقة النهائية (الشهادة)',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: AppTextStyles.bold,
                          color: isAvailable
                              ? AppColors.forest
                              : AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAvailable
                            ? 'تم إصدار الشهادة بنجاح. يمكنك عرضها وتحميلها أدناه.'
                            : message,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isAvailable
                              ? AppColors.charcoal
                              : AppColors.charcoal.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.forest.withOpacity(0.1)
                        : AppColors.goldLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isAvailable ? 'متوفرة' : 'غير متوفرة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isAvailable ? AppColors.forest : AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
            if (isAvailable) ...[
              const SizedBox(height: 20),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (fileUrl.isNotEmpty) {
                          final fullUrl = _buildFileUrl(fileUrl);
                          context.push('/pdf-viewer', extra: fullUrl);
                        }
                      },
                      icon: const Icon(LucideIcons.eye, size: 18),
                      label: const Text('عرض الوثيقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.charcoalDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final originalName =
                            finalDoc['original_name']?.toString() ??
                                'certificate.pdf';
                        if (fileUrl.isNotEmpty) {
                          _downloadFile(fileUrl, originalName,
                              documentType: 'الوثيقة النهائية');
                        }
                      },
                      icon: const Icon(LucideIcons.download, size: 18),
                      label: const Text('تحميل الوثيقة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
