import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_downloader.dart';
import '../../../../shared/utils/app_file_url.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../../department_transactions/domain/usecases/delete_final_document.dart';
import '../../../department_transactions/presentation/widgets/generate_final_document_dialog.dart';
import '../../../my_transactions/presentation/pages/pdf_viewer_page.dart';
import '../../domain/entities/document_verification_entity.dart';
import 'transaction_history_renderer.dart';

class VerificationPageHeader extends StatelessWidget {
  const VerificationPageHeader({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فحص الوثائق', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 4),
          Text(
            'تحقق من بيانات الوثيقة باستخدام رمز التفاصيل المؤقت',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
}

class VerificationInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final bool compact;
  final VoidCallback onVerify;
  final VoidCallback? onReset;

  const VerificationInputCard({
    super.key,
    required this.controller,
    required this.loading,
    this.compact = false,
    required this.onVerify,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFECE7DE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.fingerprint,
                color: Color(0xFF003F35),
                size: 28,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'التحقق من هوية الوثيقة',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalDark,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'امسح QR خارج التطبيق، ثم أدخل رمز التفاصيل',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            const _VerificationSteps(),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxWidth: 640),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFECE7DE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'طابق الهوية، ثم استخدم الرمز خلال 5 دقائق.',
                    style: TextStyle(
                      color: Color(0xFF003F35),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    LucideIcons.timer,
                    size: 16,
                    color: Color(0xFF003F35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(maxWidth: 640),
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCD6CA)),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: 'رمز التفاصيل',
                  hintStyle: TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 14,
                  ),
                  counterText: '',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: (_) => onVerify(),
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: loading ? null : onVerify,
                borderRadius: BorderRadius.circular(24),
                child: Ink(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003F35),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              LucideIcons.circleCheck,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'عرض تفاصيل الوثيقة',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _VerificationSteps extends StatelessWidget {
  const _VerificationSteps();

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StepItem(
              number: 1,
              label: 'امسح QR',
            ),
            _StepConnector(),
            _StepItem(
              number: 2,
              label: 'انسخ رمز التفاصيل',
            ),
            _StepConnector(),
            _StepItem(
              number: 3,
              label: 'أدخل الرمز هنا',
            ),
          ],
        ),
      );
}

class _StepItem extends StatelessWidget {
  final int number;
  final String label;

  const _StepItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF003F35),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.charcoalDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) => Container(
        width: 60,
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 24),
        color: const Color(0xFFDCD6CA),
      );
}


class VerificationSkeleton extends StatelessWidget {
  const VerificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 260,
        decoration: _cardDecoration(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeleton(width: 260),
            const SizedBox(height: 16),
            _skeleton(width: double.infinity),
            const SizedBox(height: 10),
            _skeleton(width: 430),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _skeleton(width: double.infinity)),
                  const SizedBox(width: 14),
                  Expanded(child: _skeleton(width: double.infinity)),
                ],
              ),
            ),
          ],
        ),
      );

  static Widget _skeleton({required double width}) => CustomSkeletonLoader(
        width: width,
        height: 20,
        borderRadius: 8,
      );
}

class VerificationErrorCard extends StatelessWidget {
  final bool isNetworkError;
  final bool isExpired;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const VerificationErrorCard({
    super.key,
    required this.isNetworkError,
    required this.isExpired,
    required this.onRetry,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Icon(LucideIcons.circleAlert,
                color: AppColors.error, size: 42),
            const SizedBox(height: 12),
            Text(
              isNetworkError
                  ? 'تعذر الاتصال بالخادم'
                  : isExpired
                      ? 'انتهت صلاحية رمز التفاصيل'
                      : 'تعذر التحقق من الوثيقة',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 5),
            Text(
              isNetworkError
                  ? 'تحقق من اتصال الإنترنت ثم حاول مجدداً'
                  : isExpired
                      ? 'انتهت صلاحية رمز التفاصيل، امسح رمز QR مرة أخرى للحصول على رمز جديد.'
                      : 'تأكد من رمز التفاصيل وحاول مرة أخرى',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(LucideIcons.refreshCw, size: 17),
                  label: const Text('إعادة المحاولة'),
                ),
                TextButton(
                  onPressed: onReset,
                  child: const Text('فحص وثيقة أخرى'),
                ),
              ],
            ),
          ],
        ),
      );
}

class VerificationResult extends StatelessWidget {
  final DocumentVerificationEntity data;
  final int? transactionId;
  final VoidCallback? onDocumentGenerated;

  const VerificationResult({
    super.key,
    required this.data,
    this.transactionId,
    this.onDocumentGenerated,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 950;

    final rightContentList = [
      _PersonCard(person: data.applicant),
      const SizedBox(height: 20),
      _TransactionCard(
        transaction: data.transaction,
        history: data.transactionHistory,
      ),
      const SizedBox(height: 20),
      _FinalDocumentCard(
        document: data.finalDocument,
        transactionId: transactionId ?? data.transaction.id,
        onDocumentGenerated: onDocumentGenerated,
      ),
      if (data.signers.isNotEmpty) ...[
        const SizedBox(height: 20),
        _SignersCard(signers: data.signers),
      ],
      const SizedBox(height: 20),
      TransactionHistoryTimeline(history: data.transactionHistory),
    ];

    final leftTimeline = _VerificationWorkflowTimeline(
      history: data.transactionHistory,
      transaction: data.transaction,
      finalDocument: data.finalDocument,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.forest.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.forest.withOpacity(0.25),
              ),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.badgeCheck,
                    color: AppColors.forest,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'تم العثور على بيانات المعاملة في النظام بنجاح',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.forest,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'جميع البيانات والتوقيعات والمرفقات مسجلة ومطابقة في السجل الرقمي.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal.withOpacity(0.7),
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
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rightContentList,
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 320,
                child: leftTimeline,
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...rightContentList,
              const SizedBox(height: 20),
              leftTimeline,
            ],
          ),
      ],
    );
  }
}

class _PersonCard extends StatefulWidget {
  final PersonIdentityEntity person;

  const _PersonCard({required this.person});

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  bool _showId = false;

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final fullName = [person.firstName, person.fatherName, person.lastName]
        .where((n) => n.isNotEmpty)
        .join(' ');
    final nationalId = person.nationalId.isNotEmpty ? person.nationalId : '-';

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    fullName.isNotEmpty ? fullName : 'صاحب المعاملة',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مواطن مقدّم للطلب',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    textDirection: TextDirection.rtl,
                    spacing: 24,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الرقم الوطني: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoal.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            _showId ? nationalId : maskNationalId(nationalId),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => setState(() => _showId = !_showId),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                _showId ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 14,
                                color: AppColors.charcoal.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (person.fatherName.isNotEmpty)
                        _buildInfoTag('اسم الأب', person.fatherName),
                      if (person.motherName.isNotEmpty)
                        _buildInfoTag('اسم الأم', person.motherName),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.user,
                color: AppColors.forest,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.charcoal.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoalDark,
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final VerifiedTransactionEntity transaction;
  final TransactionHistoryEntity history;

  const _TransactionCard({
    required this.transaction,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final txNumber = history.idProcess.isNotEmpty
        ? history.idProcess
        : transaction.id.toString();

    final statusText = transactionStatusText(transaction.status);
    final isCompleted = transaction.status.toLowerCase() == 'completed';
    final isRejected = transaction.status.toLowerCase() == 'rejected';

    Color statusColor;
    IconData statusIcon;
    if (isCompleted) {
      statusColor = AppColors.forest;
      statusIcon = LucideIcons.circleCheck;
    } else if (isRejected) {
      statusColor = AppColors.error;
      statusIcon = LucideIcons.circleX;
    } else {
      statusColor = Colors.orange.shade700;
      statusIcon = LucideIcons.clock;
    }

    String priorityLabel;
    Color priorityColor;
    IconData priorityIcon;
    final priority = history.priority;
    if (priority == 1) {
      priorityLabel = 'عالية';
      priorityColor = Colors.red.shade700;
      priorityIcon = LucideIcons.chevronsUp;
    } else if (priority == 2) {
      priorityLabel = 'عادية';
      priorityColor = AppColors.forest;
      priorityIcon = LucideIcons.minus;
    } else {
      priorityLabel = 'متوسطة';
      priorityColor = Colors.blue.shade600;
      priorityIcon = LucideIcons.chevronDown;
    }

    final infoItems = <_InfoItem>[
      _InfoItem(
        icon: LucideIcons.hash,
        label: 'الرقم المرجعي',
        value: txNumber,
        color: AppColors.forest,
      ),
      if (transaction.requestDate.isNotEmpty)
        _InfoItem(
          icon: LucideIcons.calendarPlus,
          label: 'تاريخ الطلب',
          value: transaction.requestDate,
          color: Colors.blue.shade600,
        ),
      if (transaction.completedAt.isNotEmpty)
        _InfoItem(
          icon: LucideIcons.calendarCheck,
          label: 'تاريخ الإكمال',
          value: transaction.completedAt,
          color: AppColors.forest,
        ),
      if (transaction.rejectedAt.isNotEmpty)
        _InfoItem(
          icon: LucideIcons.calendarX,
          label: 'تاريخ الرفض',
          value: transaction.rejectedAt,
          color: AppColors.error,
        ),
      if (priority != null)
        _InfoItem(
          icon: priorityIcon,
          label: 'الأولوية',
          value: priorityLabel,
          color: priorityColor,
        ),
      _InfoItem(
        icon: statusIcon,
        label: 'الحالة',
        value: statusText,
        color: statusColor,
      ),
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 80),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.08),
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
                final isNarrow = constraints.maxWidth < 400;
                if (isNarrow) {
                  return Column(
                    children: infoItems
                        .map((item) => _buildInfoRow(item))
                        .toList(),
                  );
                }
                final rows = <Widget>[];
                for (var i = 0; i < infoItems.length; i += 2) {
                  final left = infoItems[i];
                  final right =
                      i + 1 < infoItems.length ? infoItems[i + 1] : null;
                  rows.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(child: _buildInfoRow(left)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: right != null
                                ? _buildInfoRow(right)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(children: rows);
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(item.icon, size: 16, color: item.color),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.charcoal.withOpacity(0.55),
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

class _SignersCard extends StatefulWidget {
  final List<SignerEntity> signers;

  const _SignersCard({required this.signers});

  @override
  State<_SignersCard> createState() => _SignersCardState();
}

class _SignersCardState extends State<_SignersCard> {
  final Set<int> _revealedSigners = {};

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 110),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.penLine,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الموقّعون على الوثيقة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.signers.length} توقيع',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.forest,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ...widget.signers.asMap().entries.map((entry) {
              final idx = entry.key;
              final signer = entry.value;
              final isRevealed = _revealedSigners.contains(idx);
              final nationalId = signer.nationalId.isNotEmpty
                  ? (isRevealed
                      ? signer.nationalId
                      : maskNationalId(signer.nationalId))
                  : '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.25),
                  ),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${signer.signatureOrder > 0 ? signer.signatureOrder : idx + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            signer.fullName.isNotEmpty
                                ? signer.fullName
                                : 'موقّع معتمد',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            textDirection: TextDirection.rtl,
                            spacing: 16,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'الرقم الوطني: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          AppColors.charcoal.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    nationalId,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.charcoalDark,
                                    ),
                                  ),
                                  if (signer.nationalId.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isRevealed) {
                                            _revealedSigners.remove(idx);
                                          } else {
                                            _revealedSigners.add(idx);
                                          }
                                        });
                                      },
                                      child: Icon(
                                        isRevealed
                                            ? LucideIcons.eyeOff
                                            : LucideIcons.eye,
                                        size: 13,
                                        color:
                                            AppColors.charcoal.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (signer.fatherName.isNotEmpty)
                                Text(
                                  'الأب: ${signer.fatherName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.charcoal.withOpacity(0.7),
                                  ),
                                ),
                              if (signer.motherName.isNotEmpty)
                                Text(
                                  'الأم: ${signer.motherName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.charcoal.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.forest.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.check,
                        color: AppColors.forest,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FinalDocumentCard extends StatelessWidget {
  final FinalDocumentEntity document;
  final int? transactionId;
  final VoidCallback? onDocumentGenerated;

  const _FinalDocumentCard({
    required this.document,
    this.transactionId,
    this.onDocumentGenerated,
  });

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(document.fileUrl);
    if (uri == null || !uri.hasScheme) {
      AppSnackBar.show(context, message: 'تعذر فتح ملف PDF', isError: true);
      return;
    }
    context.push('/pdf-viewer', extra: {
      'fileUrl': document.fileUrl,
      'title': 'الوثيقة النهائية',
      'readOnly': true,
    });
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      final absoluteUrl = buildAbsoluteFileUrl(document.fileUrl);
      if (absoluteUrl.isEmpty) return;

      AppSnackBar.show(context, message: 'جاري تحميل الوثيقة...');

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
        throw Exception('فشل في تنزيل الملف');
      }

      final contentType = response.headers.value('content-type');
      final savePath = await AppFileDownloader.getSavePath(
        documentType: 'الوثيقة_النهائية',
        originalFilename: 'الوثيقة_النهائية',
        contentType: contentType,
        bytes: bytes,
        fallbackExtension: 'pdf',
      );

      final file = File(savePath);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'تم تحميل الوثيقة بنجاح\n$savePath',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: 'تعذر تحميل الوثيقة',
          isError: true,
        );
      }
    }
  }

  Future<void> _generate(BuildContext context) async {
    final tId = transactionId;
    if (tId == null || tId == 0) return;
    final generated = await context.push<bool>(
      '/department-transaction-details/$tId/generate-final-document',
    );
    if (generated == true) {
      onDocumentGenerated?.call();
    }
  }

  Future<void> _delete(BuildContext context) async {
    final tId = transactionId;
    if (tId == null || tId == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.trash2,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'حذف الوثيقة النهائية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في حذف الوثيقة النهائية لهذه المعاملة؟\nسيتم مسح سجل الوثيقة وإلغاء ملف الـ PDF من الخادم نهائياً.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.charcoal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              style: TextButton.styleFrom(
                minimumSize: const Size(60, 38),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: AppColors.charcoal.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              icon: const Icon(LucideIcons.trash2, size: 15),
              label: const Text('تأكيد الحذف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 38),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    AppSnackBar.show(context, message: 'جاري حذف الوثيقة النهائية...');

    final useCase = getIt<DeleteFinalDocumentUseCase>();
    final result = await useCase(tId);

    if (!context.mounted) return;

    result.fold(
      (failure) {
        AppSnackBar.show(
          context,
          title: 'فشل في حذف الوثيقة',
          message: failure.message,
          isError: true,
        );
      },
      (successMessage) {
        AppSnackBar.show(
          context,
          title: 'تم الحذف بنجاح',
          message: successMessage,
          isError: false,
        );
        onDocumentGenerated?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = document.available && document.fileUrl.isNotEmpty;

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isAvailable ? LucideIcons.fileCheck2 : LucideIcons.filePlus,
                    color: AppColors.forest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'الوثيقة النهائية الرسمية',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: AppTextStyles.semiBold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const Spacer(),
                if (isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.forest.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.checkCheck,
                            size: 13, color: AppColors.forest),
                        SizedBox(width: 5),
                        Text(
                          'معتمدة ومصدرة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.forest,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            if (isAvailable) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        LucideIcons.fileText,
                        color: Colors.red.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          const Text(
                            'المستند الرسمي المعتمد للتنزيل والطباعة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.charcoalDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'تم دمج وتوقيع جميع المرفقات والشهادات بنجاح.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.charcoal.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                textDirection: TextDirection.rtl,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _open(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          children: const [
                            Icon(LucideIcons.eye,
                                size: 16, color: AppColors.charcoal),
                            SizedBox(width: 8),
                            Text(
                              'عرض الوثيقة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _downloadFile(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          children: const [
                            Icon(LucideIcons.download,
                                size: 16, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'تحميل الوثيقة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (transactionId != null && transactionId != 0) ...[
                    OutlinedButton.icon(
                      onPressed: () => _generate(context),
                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                      label: const Text('إعادة التوليد / تعديل المرفقات'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.charcoalDark,
                        side: BorderSide(
                            color: AppColors.gold.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _delete(context),
                      icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFDC2626)),
                      label: const Text('حذف الوثيقة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.sparkles,
                        color: AppColors.goldDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          const Text(
                            'لم يتم إصدار الوثيقة النهائية لهذه المعاملة بعد',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalDark,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'يمكنك إحضار مستندات المعاملة واختيار المرفقات المطلوبة لتوليد الوثيقة النهائية المدمجة.',
                            style: TextStyle(
                              color: AppColors.charcoal.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (transactionId != null && transactionId != 0) ...[
                      const SizedBox(width: 14),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _generate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Ink(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              textDirection: TextDirection.rtl,
                              children: const [
                                Icon(LucideIcons.filePlus,
                                    size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'توليد الوثيقة النهائية',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _VerificationWorkflowTimeline extends StatelessWidget {
  final TransactionHistoryEntity history;
  final VerifiedTransactionEntity transaction;
  final FinalDocumentEntity finalDocument;

  const _VerificationWorkflowTimeline({
    required this.history,
    required this.transaction,
    required this.finalDocument,
  });

  @override
  Widget build(BuildContext context) {
    final stages = history.data.stages;
    final isCompleted = transaction.status.toLowerCase() == 'completed';
    final isRejected = transaction.status.toLowerCase() == 'rejected';

    final steps = <Map<String, dynamic>>[];

    for (final stage in stages) {
      final name = stage.displayName;
      final completedAt = stage.completedAt != null
          ? formatHistoryDate(stage.completedAt)
          : '';
      final decision = stage.decision;
      final isStageRejected = decision == 'reject' || decision == 'rejected';

      steps.add({
        'title': name,
        'operator': stage.completedBy != null ? 'الموظف المختص' : 'الجهة المختصة',
        'time': completedAt,
        'details': stage.note ?? stage.rejectionReason ?? '',
        'state': isStageRejected ? 'rejected' : 'checked',
      });
    }

    if (finalDocument.available && finalDocument.fileUrl.isNotEmpty) {
      steps.add({
        'title': 'إصدار الوثيقة النهائية',
        'operator': 'الوثيقة معتمدة ومصدرة',
        'time': transaction.completedAt.isNotEmpty ? transaction.completedAt : '',
        'details': '',
        'state': 'checked',
      });
    } else if (isCompleted) {
      steps.add({
        'title': 'اكتمال المعاملة',
        'operator': 'تم إنجاز كافة المراحل',
        'time': transaction.completedAt,
        'details': '',
        'state': 'checked',
      });
    } else if (isRejected) {
      steps.add({
        'title': 'رفض المعاملة',
        'operator': 'تم رفض الطلب',
        'time': transaction.rejectedAt,
        'details': '',
        'state': 'rejected',
      });
    } else {
      steps.add({
        'title': 'الجهة المختصة',
        'operator': 'للاطلاع والتوجيه',
        'time': '',
        'details': '',
        'state': 'pending_flag',
      });
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مسار سير العمل',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
            const SizedBox(height: 24),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;
                return _buildTimelineStep(step, isLast);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, bool isLast) {
    Color iconBg;
    Color iconFg;
    IconData icon;

    switch (step['state']) {
      case 'checked':
        iconBg = AppColors.forest;
        iconFg = Colors.white;
        icon = LucideIcons.check;
        break;
      case 'rejected':
        iconBg = AppColors.error;
        iconFg = Colors.white;
        icon = LucideIcons.x;
        break;
      case 'active':
      case 'active_edit':
        iconBg = AppColors.gold;
        iconFg = AppColors.charcoalDark;
        icon = LucideIcons.clock;
        break;
      default:
        iconBg = AppColors.charcoal.withOpacity(0.1);
        iconFg = AppColors.charcoal.withOpacity(0.4);
        icon = LucideIcons.circleDot;
    }

    return IntrinsicHeight(
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconFg),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    step['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step['operator'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.charcoal.withOpacity(0.6),
                    ),
                  ),
                  if ((step['time'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      step['time']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.charcoal.withOpacity(0.45),
                      ),
                    ),
                  ],
                  if ((step['details'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        step['details']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.charcoal.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
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

String maskNationalId(String value) {
  if (value.length <= 4) return '*' * value.length;
  final hiddenLength = value.length - 5;
  return '${value.substring(0, 3)}${'*' * hiddenLength}${value.substring(value.length - 2)}';
}

String transactionStatusText(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
      return 'منجزة';
    case 'pending':
      return 'قيد المعالجة';
    case 'in_progress':
      return 'قيد التنفيذ';
    case 'rejected':
      return 'مرفوضة';
    case 'cancelled':
      return 'ملغاة';
    default:
      return status.trim().isEmpty ? 'غير محددة' : status.replaceAll('_', ' ');
  }
}

BoxDecoration _cardDecoration({double radius = 12}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
