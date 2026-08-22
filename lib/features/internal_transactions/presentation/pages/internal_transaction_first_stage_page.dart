import 'dart:io';
import 'dart:typed_data';

import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../../../shared/utils/app_file_url.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';

import '../../domain/entities/internal_transaction_first_stage_entity.dart';
import '../../domain/entities/internal_transaction_entity.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_bloc.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_event.dart';
import '../bloc/internal_transaction_first_stage/internal_transaction_first_stage_state.dart';

class InternalTransactionFirstStagePage extends StatelessWidget {
  final int transactionId;
  final InternalTransactionEntity? transaction;

  const InternalTransactionFirstStagePage({
    super.key,
    required this.transactionId,
    this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.goldLight,
      child: BlocBuilder<InternalTransactionFirstStageBloc,
          InternalTransactionFirstStageState>(
        builder: (context, state) {
          if (state.loading) {
            return const _LoadingSkeleton();
          }

          if (state.errorMessage != null) {
            return AppErrorWidget(
              title: 'تعذر تحميل تفاصيل المعاملة',
              message: 'حدث خطأ أثناء جلب البيانات، حاول مرة أخرى',
              onRetry: () => context
                  .read<InternalTransactionFirstStageBloc>()
                  .add(LoadInternalTransactionFirstStage(transactionId)),
            );
          }

          final details = state.details;
          if (details == null) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          return _DetailsContent(
            details: details,
            transaction: transaction,
          );
        },
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 950;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/internal-transactions');
                }
              },
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
                      color: AppColors.charcoal.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const CustomSkeletonLoader(width: double.infinity, height: 110),
            const SizedBox(height: 24),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: const [
                        CustomSkeletonLoader(
                            width: double.infinity, height: 140),
                        SizedBox(height: 20),
                        CustomSkeletonLoader(
                            width: double.infinity, height: 260),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 3,
                    child: CustomSkeletonLoader(
                        width: double.infinity, height: 420),
                  ),
                ],
              )
            else
              Column(
                children: const [
                  CustomSkeletonLoader(width: double.infinity, height: 140),
                  SizedBox(height: 20),
                  CustomSkeletonLoader(width: double.infinity, height: 260),
                  SizedBox(height: 20),
                  CustomSkeletonLoader(width: double.infinity, height: 420),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;
  final InternalTransactionEntity? transaction;

  const _DetailsContent({
    required this.details,
    this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    final stageName = _stageName(details, transaction);
    final statusData = _resolveStatusData(details, transaction);
    final txIdProcess = transaction?.idProcess.trim() ?? '';
    final detailsIdProcess = details.idProcess?.trim() ?? '';
    final displayId = txIdProcess.isNotEmpty
        ? txIdProcess
        : (detailsIdProcess.isNotEmpty
            ? detailsIdProcess
            : '#${details.transactionId}');

    final textWidgets = content.widgets
        .where((item) => item.widgetType != 'file_picker')
        .where((item) => !_isEmptyValue(item.value))
        .toList(growable: false);
    final fileWidgets = content.widgets
        .where((item) => item.widgetType == 'file_picker')
        .toList(growable: false);
    final enteredFingerprints =
        textWidgets.map((item) => _fingerprint(item.label, item.value)).toSet();
    final templateValues = _additionalTemplateValues(
      content.templates,
      enteredFingerprints,
    );
    final generatedDocuments = content.templates
        .where((template) => template.generatedPdfPath.trim().isNotEmpty)
        .toList(growable: false);

    final isWide = MediaQuery.of(context).size.width > 950;

    final rightContentList = <Widget>[
      _TransactionInfoCard(
        details: details,
        statusData: statusData,
        displayId: displayId,
      ),
      const SizedBox(height: 20),
      if (content.rejectionReason.trim().isNotEmpty) ...[
        _RejectionReasonCard(reason: content.rejectionReason.trim()),
        const SizedBox(height: 20),
      ],
      if (content.note.trim().isNotEmpty) ...[
        _NoteCard(note: content.note.trim()),
        const SizedBox(height: 20),
      ],
      if (generatedDocuments.isNotEmpty) ...[
        ...generatedDocuments.asMap().entries.map((entry) {
          final index = entry.key;
          final template = entry.value;
          final title = generatedDocuments.length > 1
              ? 'الوثيقة الرسمية (النموذج المولد ${index + 1})'
              : 'الوثيقة الرسمية (النموذج المولد)';
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _FinalDocumentCard(
              title: title,
              filePath: template.generatedPdfPath,
            ),
          );
        }),
      ],
      if (textWidgets.isNotEmpty) ...[
        _DataSectionCard(
          title: content.formName.trim().isNotEmpty
              ? content.formName.trim()
              : 'البيانات المدخلة',
          widgets: textWidgets,
        ),
        const SizedBox(height: 20),
      ],
      if (templateValues.isNotEmpty) ...[
        _TemplateValuesCard(values: templateValues),
        const SizedBox(height: 20),
      ],
      if (fileWidgets.isNotEmpty) ...[
        _FilesSectionCard(widgets: fileWidgets),
        const SizedBox(height: 20),
      ],
    ];

    final leftContent = _WorkflowTimelineCard(details: details);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 36),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/internal-transactions');
                }
              },
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
                      color: AppColors.charcoal.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _HeaderWidget(
              details: details,
              stageName: stageName,
              statusData: statusData,
              displayId: displayId,
            ),
            const SizedBox(height: 24),

            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rightContentList,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: leftContent,
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...rightContentList,
                  const SizedBox(height: 20),
                  leftContent,
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusData {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final IconData icon;

  const _StatusData({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.icon,
  });
}

_StatusData _resolveStatusData(
  InternalTransactionFirstStageEntity details,
  InternalTransactionEntity? transaction,
) {
  final detailsStatus = details.status?.trim() ?? '';
  final txStatus = transaction?.status.trim() ?? '';
  final rawStatus =
      (detailsStatus.isNotEmpty ? detailsStatus : txStatus).toLowerCase();

  if (rawStatus.isNotEmpty) {
    switch (rawStatus) {
      case 'submitted':
        return const _StatusData(
          label: 'مقدمة',
          textColor: AppColors.forest,
          backgroundColor: Color(0xFFEAF3F0),
          icon: LucideIcons.send,
        );
      case 'in_progress':
      case 'running':
        return _StatusData(
          label: 'قيد المعالجة',
          textColor: AppColors.goldDark,
          backgroundColor: AppColors.goldLight.withValues(alpha: 0.45),
          icon: LucideIcons.clock3,
        );
      case 'completed':
        return const _StatusData(
          label: 'منجزة',
          textColor: AppColors.forest,
          backgroundColor: Color(0xFFE8F5E9),
          icon: LucideIcons.circleCheck,
        );
      case 'rejected':
        return const _StatusData(
          label: 'مرفوضة',
          textColor: AppColors.umber,
          backgroundColor: Color(0xFFFFEBEE),
          icon: LucideIcons.circleX,
        );
      case 'cancelled':
        return const _StatusData(
          label: 'ملغاة',
          textColor: AppColors.umber,
          backgroundColor: Color(0xFFF8EDEF),
          icon: LucideIcons.ban,
        );
      default:
        return _StatusData(
          label: rawStatus,
          textColor: const Color(0xFF5A738E),
          backgroundColor: const Color(0xFFEDF2F7),
          icon: LucideIcons.info,
        );
    }
  }

  // Fallback to decision if status is not provided
  final decision = details.content.decision.trim().toLowerCase();
  if (decision == 'approve') {
    return const _StatusData(
      label: 'تمت الموافقة',
      textColor: AppColors.forest,
      backgroundColor: Color(0xFFE8F5E9),
      icon: LucideIcons.circleCheck,
    );
  } else if (decision == 'reject') {
    return const _StatusData(
      label: 'مرفوضة',
      textColor: AppColors.umber,
      backgroundColor: Color(0xFFFFEBEE),
      icon: LucideIcons.circleX,
    );
  } else if (decision == 'return') {
    return const _StatusData(
      label: 'أعيدت للتعديل',
      textColor: Colors.orange,
      backgroundColor: Color(0xFFFFF3E0),
      icon: LucideIcons.rotateCcw,
    );
  }

  return _StatusData(
    label: 'قيد المعالجة',
    textColor: AppColors.goldDark,
    backgroundColor: AppColors.goldLight.withValues(alpha: 0.45),
    icon: LucideIcons.clock3,
  );
}

class _HeaderWidget extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;
  final String stageName;
  final _StatusData statusData;
  final String displayId;

  const _HeaderWidget({
    required this.details,
    required this.stageName,
    required this.statusData,
    required this.displayId,
  });

  @override
  Widget build(BuildContext context) {
    final formattedId = displayId.startsWith('#') ? displayId : '#$displayId';

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            textDirection: TextDirection.rtl,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                stageName,
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 26,
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.forest,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusData.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusData.label,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: AppTextStyles.medium,
                    color: statusData.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formattedId,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: AppTextStyles.medium,
              color: AppColors.charcoal.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionInfoCard extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;
  final _StatusData statusData;
  final String displayId;

  const _TransactionInfoCard({
    required this.details,
    required this.statusData,
    required this.displayId,
  });

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    final formattedId = displayId.startsWith('#') ? displayId : '#$displayId';

    final infoItems = <_InfoItem>[
      _InfoItem(
        icon: LucideIcons.hash,
        label: 'رقم المعاملة',
        value: formattedId,
        color: AppColors.forest,
      ),
      _InfoItem(
        icon: LucideIcons.calendarCheck,
        label: 'تاريخ الإنجاز',
        value: _formatDate(content.completedAt),
        color: Colors.blue.shade600,
      ),
      _InfoItem(
        icon: LucideIcons.workflow,
        label: 'المرحلة',
        value: _stageName(details),
        color: AppColors.charcoalDark,
      ),
      _InfoItem(
        icon: statusData.icon,
        label: 'الحالة',
        value: statusData.label,
        color: statusData.textColor,
      ),
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.clipboardList,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'معلومات المعاملة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 16.0;
                final isTwoCol = constraints.maxWidth >= 450;
                final itemWidth = isTwoCol
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;

                return Wrap(
                  spacing: gap,
                  runSpacing: 16,
                  children: infoItems.map((item) {
                    return SizedBox(
                      width: itemWidth,
                      child: _buildInfoRow(item),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 16, color: item.color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.charcoal.withValues(alpha: 0.55),
                  fontWeight: AppTextStyles.medium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _RejectionReasonCard extends StatelessWidget {
  final String reason;

  const _RejectionReasonCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.messageCircleX,
                color: Colors.red.shade700,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سبب الرفض',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: Colors.red.shade800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
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
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.forestLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.forest.withOpacity(0.2)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.forestLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.messageSquareText,
                color: AppColors.forest,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات المعاملة',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: AppTextStyles.bold,
                      color: AppColors.forest,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.charcoalDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalDocumentCard extends StatelessWidget {
  final String title;
  final String filePath;

  const _FinalDocumentCard({
    required this.title,
    required this.filePath,
  });

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final absoluteUrl = buildAbsoluteFileUrl(filePath);
      if (absoluteUrl.isEmpty) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل الوثيقة...')),
      );

      final dio = getIt<Dio>();
      final response = await dio.get<List<int>>(
        absoluteUrl,
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
        documentType: title,
        originalFilename: title,
        contentType: contentType,
        bytes: bytes,
        fallbackExtension: 'pdf',
      );

      final file = File(savePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        AppSnackBar.show(
          context,
          title: 'تم التحميل بنجاح',
          message: 'تم حفظ الوثيقة بنجاح في:\n$savePath',
          isError: false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          title: 'فشل التحميل',
          message: 'تعذر تحميل الوثيقة وحفظها على الجهاز',
          isError: true,
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final absoluteUrl = buildAbsoluteFileUrl(filePath);

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.fileCheck,
                    color: AppColors.forest,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: AppTextStyles.bold,
                    color: AppColors.forest,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'تم إصدار الوثيقة الرسمية للمعاملة بنجاح. يمكنك عرضها وتحميلها أدناه.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (absoluteUrl.isNotEmpty) {
                          context.push('/pdf-viewer', extra: {
                            'fileUrl': absoluteUrl,
                            'title': title,
                            'readOnly': true,
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.eye,
                                color: AppColors.charcoal, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'عرض الوثيقة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _downloadFile(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(LucideIcons.download,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'تحميل الوثيقة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _DataSectionCard extends StatelessWidget {
  final String title;
  final List<FirstStageWidgetEntity> widgets;

  const _DataSectionCard({
    required this.title,
    required this.widgets,
  });

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.listChecks,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final twoColumns = constraints.maxWidth >= 600;
                final width = twoColumns
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: widgets
                      .map(
                        (item) => SizedBox(
                          width: width,
                          child: _ReadOnlyField(
                            label: _readableLabel(item.label),
                            value: _formatValue(item.value),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateValuesCard extends StatelessWidget {
  final List<MapEntry<String, dynamic>> values;

  const _TemplateValuesCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.fileCheck2,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'بيانات النموذج الرسمي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final twoColumns = constraints.maxWidth >= 600;
                final width = twoColumns
                    ? (constraints.maxWidth - gap) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: values
                      .map(
                        (entry) => SizedBox(
                          width: width,
                          child: _ReadOnlyField(
                            label: _templateLabel(entry.key),
                            value: _formatValue(entry.value),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilesSectionCard extends StatelessWidget {
  final List<FirstStageWidgetEntity> widgets;

  const _FilesSectionCard({required this.widgets});

  @override
  Widget build(BuildContext context) {
    final files = <_DisplayFile>[];
    for (final widget in widgets) {
      final values = widget.value is List ? widget.value as List : const [];
      for (final raw in values.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final url = map['url']?.toString() ?? '';
        if (url.trim().isEmpty) continue;
        files.add(_DisplayFile(
          label: _readableLabel(widget.label),
          url: url,
          mimeType: map['mime_type']?.toString() ?? '',
        ));
      }
    }

    if (files.isEmpty) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.paperclip,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الملفات المرفقة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: files
                  .map(
                    (file) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FileCard(file: file),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayFile {
  final String label;
  final String url;
  final String mimeType;

  const _DisplayFile({
    required this.label,
    required this.url,
    required this.mimeType,
  });

  bool get isPdf =>
      mimeType.toLowerCase().contains('pdf') ||
      url.split('?').first.toLowerCase().endsWith('.pdf');
}

class _FileCard extends StatefulWidget {
  final _DisplayFile file;

  const _FileCard({required this.file});

  @override
  State<_FileCard> createState() => _FileCardState();
}

class _FileCardState extends State<_FileCard> {
  bool _hovered = false;
  bool _downloading = false;

  String get _absoluteUrl => buildAbsoluteFileUrl(widget.file.url);

  void _open() {
    if (_absoluteUrl.isEmpty) return;
    context.push(
      widget.file.isPdf ? '/pdf-viewer' : '/image-viewer',
      extra: {
        'fileUrl': _absoluteUrl,
        'title': widget.file.label,
        if (widget.file.isPdf) 'readOnly': true,
      },
    );
  }

  Future<void> _download() async {
    if (_downloading || _absoluteUrl.isEmpty) return;
    setState(() => _downloading = true);
    try {
      final dio = getIt<Dio>();
      final response = await dio.get<List<int>>(
        _absoluteUrl,
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
        documentType: widget.file.label,
        originalFilename: widget.file.label,
        contentType: contentType,
        bytes: bytes,
        fallbackExtension: widget.file.isPdf ? 'pdf' : null,
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
    } catch (error) {
      if (mounted) {
        AppSnackBar.show(
          context,
          title: 'فشل التحميل',
          message: 'تعذر تحميل الملف وحفظه على الجهاز',
          isError: true,
        );
      }
    } finally {

      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.goldLight.withOpacity(0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hovered
                ? AppColors.forest.withOpacity(0.3)
                : AppColors.gold.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.file.isPdf
                    ? const Color(0xFFFDEEEF)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.file.isPdf ? LucideIcons.fileText : LucideIcons.image,
                color: widget.file.isPdf
                    ? const Color(0xFFC62828)
                    : const Color(0xFF1D4ED8),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.file.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.file.isPdf ? 'مستند PDF' : 'صورة مرفقة',
                    style: TextStyle(
                      color: AppColors.charcoal.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // View Action
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _open,
                borderRadius: BorderRadius.circular(6),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(LucideIcons.eye,
                          size: 15, color: AppColors.charcoalDark),
                      SizedBox(width: 6),
                      Text(
                        'عرض',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Download Action
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _downloading ? null : _download,
                borderRadius: BorderRadius.circular(6),
                child: Ink(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_downloading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(LucideIcons.download,
                            size: 15, color: Colors.white),
                      const SizedBox(width: 6),
                      const Text(
                        'تحميل',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowTimelineCard extends StatelessWidget {
  final InternalTransactionFirstStageEntity details;

  const _WorkflowTimelineCard({required this.details});

  @override
  Widget build(BuildContext context) {
    final content = details.content;
    final stageName = _stageName(details);
    final isRejected = content.decision.trim().toLowerCase() == 'reject';

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'مسار سير العمل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.forest,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: First Stage (Completed/Rejected)
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isRejected
                            ? Colors.red.shade100
                            : AppColors.forestLight.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isRejected ? AppColors.error : AppColors.forest,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isRejected ? LucideIcons.x : LucideIcons.check,
                        size: 16,
                        color:
                            isRejected ? AppColors.error : AppColors.forest,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 54,
                      color: const Color(0xFFE0E0E0),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        stageName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRejected ? 'تم الرفض' : 'تم الإكمال والاعتماد',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isRejected ? AppColors.error : AppColors.forest,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (content.completedAt.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(content.completedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.charcoal.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Step 2: Next entity / completion
            Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isRejected
                        ? Colors.grey.shade100
                        : AppColors.forestLight.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isRejected
                          ? Colors.grey.shade400
                          : AppColors.forest,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isRejected
                        ? LucideIcons.circleMinus
                        : LucideIcons.circleCheck,
                    size: 16,
                    color: isRejected
                        ? Colors.grey.shade500
                        : AppColors.forest,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      const Text(
                        'الجهة المختصة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isRejected
                            ? 'معاملة متوقفة'
                            : 'منجزة في سجل المعاملات',
                        style: TextStyle(
                          fontSize: 12,
                          color: isRejected
                              ? Colors.grey.shade600
                              : AppColors.forest,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _ReadOnlyField extends StatefulWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  State<_ReadOnlyField> createState() => _ReadOnlyFieldState();
}

class _ReadOnlyFieldState extends State<_ReadOnlyField> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 68),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.goldLight.withOpacity(0.7)
              : AppColors.goldLight.withOpacity(0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? AppColors.forest.withOpacity(0.3)
                : AppColors.gold.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: AppColors.charcoal.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.charcoalDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _templateLabels = <String, String>{
  'manager-name': 'اسم المدير',
  'manager_name': 'اسم المدير',
  'employee': 'اسم الموظف',
  'employee-name': 'اسم الموظف',
  'job': 'الوظيفة',
  'department': 'القسم',
};

String _stageName(
  InternalTransactionFirstStageEntity details, [
  InternalTransactionEntity? transaction,
]) {
  final contentName = details.content.stageName.trim();
  if (contentName.isNotEmpty) return contentName;
  final stageName = details.stageName.trim();
  if (stageName.isNotEmpty) return stageName;
  final txStage = transaction?.stageName.trim() ?? '';
  if (txStage.isNotEmpty) return txStage;
  return 'المرحلة الأولى';
}

String _formatDate(String raw) {
  final parsed = DateTime.tryParse(raw)?.toLocal();
  if (parsed == null) return 'غير متوفر';
  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

String _templateLabel(String key) =>
    _templateLabels[key.trim().toLowerCase()] ?? _readableLabel(key);

String _readableLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'بيان';
  final spaced = trimmed
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (spaced.isEmpty) return 'بيان';
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

List<MapEntry<String, dynamic>> _additionalTemplateValues(
  List<FirstStageTemplateEntity> templates,
  Set<String> enteredFingerprints,
) {
  final result = <MapEntry<String, dynamic>>[];
  final seen = <String>{...enteredFingerprints};
  const ignoredKeys = {
    'generated_pdf_path',
    'generated_pdf_url',
    'id_document_instance',
    'id_template',
    'id_document_template',
  };
  for (final template in templates) {
    for (final entry in template.value.entries) {
      if (ignoredKeys.contains(entry.key.toLowerCase())) continue;
      if (_isEmptyValue(entry.value)) continue;
      final label = _templateLabel(entry.key);
      final fingerprint = _fingerprint(label, entry.value);
      if (seen.add(fingerprint)) result.add(entry);
    }
  }
  return result;
}

String _fingerprint(String label, dynamic value) =>
    '${_normalize(label)}|${_normalize(_formatValue(value))}';

String _normalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[\s_-]+'), ' ')
    .replaceAll(RegExp(r'[^\w\u0600-\u06ff ]'), '');

bool _isEmptyValue(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

String _formatValue(dynamic value) {
  if (value == null) return 'غير متوفر';
  if (value is bool) return value ? 'نعم' : 'لا';
  if (value is List) return value.map(_formatValue).join('، ');
  if (value is Map) {
    return value.values.map(_formatValue).join('، ');
  }
  final text = value.toString().trim();
  return text.isEmpty ? 'غير متوفر' : text;
}
