import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/document_verification_entity.dart';

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
        padding: EdgeInsets.all(compact ? 16 : 20),
        decoration: _cardDecoration(radius: 18),
        child: Column(
          children: [
            if (!compact) ...[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  LucideIcons.fingerprint,
                  color: AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'التحقق من هوية الوثيقة',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: 3),
              Text(
                'امسح QR خارج التطبيق، ثم أدخل رمز التفاصيل',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 13),
              const _VerificationSteps(),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(maxWidth: 680),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.timer,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'طابق الهوية، ثم استخدم الرمز خلال 5 دقائق.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تحقق من وثيقة أخرى',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            if (compact) const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SizedBox(
                height: 66,
                child: TextField(
                  controller: controller,
                  enabled: !loading,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onVerify(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall.copyWith(
                    letterSpacing: 7,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'رمز التفاصيل',
                    hintText: 'الرمز المكوّن من 6 أرقام',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                      borderSide: BorderSide(
                        color: AppColors.border.withValues(alpha: .65),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: loading ? null : onVerify,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(230, 56),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  icon: loading
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.surface,
                          ),
                        )
                      : const Icon(LucideIcons.badgeCheck, size: 18),
                  label: Text(
                    loading ? 'جارٍ التحقق...' : 'عرض تفاصيل الوثيقة',
                  ),
                ),
                if (onReset != null)
                  TextButton.icon(
                    onPressed: loading ? null : onReset,
                    icon: const Icon(LucideIcons.rotateCcw, size: 17),
                    label: const Text('فحص وثيقة أخرى'),
                  ),
              ],
            ),
          ],
        ),
      );
}

class _VerificationSteps extends StatelessWidget {
  const _VerificationSteps();

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: const Row(
          children: [
            Expanded(child: _StepItem(number: 1, label: 'امسح QR')),
            _StepConnector(),
            Expanded(child: _StepItem(number: 2, label: 'انسخ رمز التفاصيل')),
            _StepConnector(),
            Expanded(child: _StepItem(number: 3, label: 'أدخل الرمز هنا')),
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
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      );
}

class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 1,
        margin: const EdgeInsets.only(bottom: 26),
        color: AppColors.border.withValues(alpha: .6),
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

  static Widget _skeleton({required double width}) => Container(
        width: width,
        height: 20,
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(8),
        ),
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

  const VerificationResult({super.key, required this.data});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: .22),
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.badgeCheck, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم العثور على بيانات الوثيقة في النظام',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'تم ربط رمز التحقق بمعاملة مسجلة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (_, constraints) {
              final first = Column(
                children: [
                  _TransactionCard(
                    transaction: data.transaction,
                    history: data.transactionHistory,
                  ),
                  const SizedBox(height: 14),
                  _PersonCard(title: 'صاحب المعاملة', person: data.applicant),
                ],
              );
              final second = Column(
                children: [
                  _SignersCard(signers: data.signers),
                  const SizedBox(height: 14),
                  _FinalDocumentCard(document: data.finalDocument),
                ],
              );
              if (constraints.maxWidth < 850) {
                return Column(
                  children: [first, const SizedBox(height: 14), second],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 14),
                  Expanded(child: second),
                ],
              );
            },
          ),
        ],
      );
}

class _TransactionCard extends StatelessWidget {
  final VerifiedTransactionEntity transaction;
  final TransactionHistoryEntity history;

  const _TransactionCard({required this.transaction, required this.history});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'ملخص المعاملة',
        icon: LucideIcons.fileCheck2,
        children: [
          if (history.idProcess.isNotEmpty)
            _InfoRow(label: 'الرقم المرجعي', value: history.idProcess),
          _InfoRow(
              label: 'الحالة',
              value: transactionStatusText(transaction.status)),
          if (transaction.requestDate.isNotEmpty)
            _InfoRow(label: 'تاريخ الطلب', value: transaction.requestDate),
          if (transaction.completedAt.isNotEmpty)
            _InfoRow(label: 'تاريخ الإكمال', value: transaction.completedAt),
          if (transaction.rejectedAt.isNotEmpty)
            _InfoRow(label: 'تاريخ الرفض', value: transaction.rejectedAt),
        ],
      );
}

class _PersonCard extends StatelessWidget {
  final String title;
  final PersonIdentityEntity person;

  const _PersonCard({required this.title, required this.person});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: title,
        icon: LucideIcons.userRound,
        children: [
          if (person.fullName.isNotEmpty)
            _InfoRow(label: 'الاسم', value: person.fullName),
          if (person.fatherName.isNotEmpty)
            _InfoRow(label: 'اسم الأب', value: person.fatherName),
          if (person.motherName.isNotEmpty)
            _InfoRow(label: 'اسم الأم', value: person.motherName),
          if (person.nationalId.isNotEmpty)
            _NationalIdRow(value: person.nationalId),
        ],
      );
}

class _SignersCard extends StatelessWidget {
  final List<SignerEntity> signers;

  const _SignersCard({required this.signers});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'الموقّعون على الوثيقة',
        icon: LucideIcons.penLine,
        children: signers.isEmpty
            ? [
                Text(
                  'لا توجد توقيعات مسجلة على الوثيقة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ]
            : signers
                .map(
                  (signer) => Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: .30),
                      ),
                    ),
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'ترتيب التوقيع',
                          value: signer.signatureOrder.toString(),
                        ),
                        if (signer.fullName.isNotEmpty)
                          _InfoRow(label: 'الاسم', value: signer.fullName),
                        if (signer.fatherName.isNotEmpty)
                          _InfoRow(label: 'اسم الأب', value: signer.fatherName),
                        if (signer.motherName.isNotEmpty)
                          _InfoRow(label: 'اسم الأم', value: signer.motherName),
                        if (signer.nationalId.isNotEmpty)
                          _NationalIdRow(value: signer.nationalId),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
      );
}

class _FinalDocumentCard extends StatelessWidget {
  final FinalDocumentEntity document;

  const _FinalDocumentCard({required this.document});

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(document.fileUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        AppSnackBar.show(context, message: 'تعذر فتح ملف PDF', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: 'الوثيقة النهائية',
        icon: LucideIcons.fileText,
        children: [
          Text(
            document.available && document.fileUrl.isNotEmpty
                ? 'الوثيقة النهائية متاحة'
                : 'لا يتوفر ملف نهائي لهذه المعاملة حالياً',
            style: AppTextStyles.bodyMedium,
          ),
          if (document.available && document.fileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _open(context),
              icon: const Icon(LucideIcons.externalLink, size: 17),
              label: const Text('عرض ملف PDF'),
            ),
          ],
        ],
      );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112,
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: SelectableText(value, style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      );
}

class _NationalIdRow extends StatefulWidget {
  final String value;

  const _NationalIdRow({required this.value});

  @override
  State<_NationalIdRow> createState() => _NationalIdRowState();
}

class _NationalIdRowState extends State<_NationalIdRow> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SizedBox(
            width: 112,
            child: Text('الرقم الوطني'),
          ),
          Expanded(
            child: SelectableText(
              _visible ? widget.value : maskNationalId(widget.value),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Tooltip(
            message: _visible ? 'إخفاء الرقم' : 'إظهار الرقم كاملاً',
            child: IconButton(
              onPressed: () => setState(() => _visible = !_visible),
              icon: Icon(
                _visible ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 17,
              ),
            ),
          ),
        ],
      );
}

String maskNationalId(String value) {
  if (value.length <= 4) return '*' * value.length;
  final hiddenLength = value.length - 5;
  return '${value.substring(0, 3)}${'*' * hiddenLength}${value.substring(value.length - 2)}';
}

String transactionStatusText(String status) {
  switch (status.trim().toLowerCase()) {
    case 'completed':
      return 'مكتملة';
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

BoxDecoration _cardDecoration({double radius = 15}) => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border.withValues(alpha: .34)),
      boxShadow: [
        BoxShadow(
          color: AppColors.textPrimary.withValues(alpha: .04),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
