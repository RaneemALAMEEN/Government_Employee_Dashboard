import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/my_transaction_entity.dart';
import '../bloc/my_transactions_bloc.dart';
import '../bloc/my_transactions_event.dart';
import '../bloc/my_transactions_state.dart';
import '../widgets/secure_signature_dialog.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;

  const TransactionDetailsPage({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0C1917),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 40,
          right: 40,
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _openSignatureDialog(BuildContext context, String txnNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return SecureSignatureDialog(
          transactionNumber: txnNumber,
          onSuccess: () {
            // Dispatch Sign event to BLoC
            context.read<MyTransactionsBloc>().add(SignTransaction(txnNumber));
            _showSuccessSnackBar('تم توقيع المعاملة $txnNumber بنجاح وإنجازها');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTransactionsBloc, MyTransactionsState>(
      builder: (context, state) {
        if (state is MyTransactionsLoading || state is MyTransactionsInitial) {
          return const Scaffold(
            backgroundColor: AppColors.goldLight,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.forest),
            ),
          );
        }

        if (state is MyTransactionsFailure) {
          return Scaffold(
            backgroundColor: AppColors.goldLight,
            body: Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.charcoalDark),
              ),
            ),
          );
        }

        if (state is MyTransactionsLoaded) {
          // Find the transaction by ID/Number
          final txn = state.allTransactions.firstWhere(
            (t) => t.number == widget.transactionId,
            orElse: () => MyTransactionEntity(
              number: widget.transactionId,
              type: 'إجازة خاصة بلا أجر',
              applicant: 'أحمد خالد المحمود',
              department: 'التعليم الثانوي',
              date: '2026-04-01',
              priority: 'عالية',
              status: 'بانتظار الاستلام',
              canSign: true,
            ),
          );

          return Scaffold(
            backgroundColor: AppColors.goldLight,
            body: Padding(
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header Details Area
                    _buildHeader(context, txn),
                    const SizedBox(height: 24),

                    // Main Layout Grid
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 950;

                          final rightContentList = [
                            // Card 1: Employee Card
                            _buildEmployeeCard(txn),
                            const SizedBox(height: 20),

                            // Card 2: Request details
                            _buildRequestDetailsCard(txn),
                            const SizedBox(height: 20),

                            // Card 3: Attachments
                            _buildAttachmentsCard(),
                            const SizedBox(height: 20),

                            // Card 4: Previous Notes
                            _buildPreviousNotesCard(),
                          ];

                          final leftContent = _buildWorkflowTimeline(txn);

                          return isWide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Right scrollable content cards
                                    Expanded(
                                      flex: 7,
                                      child: SingleChildScrollView(
                                        padding:
                                            const EdgeInsets.only(bottom: 32),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: rightContentList,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    // Left fixed timeline
                                    Expanded(
                                      flex: 3,
                                      child: SingleChildScrollView(
                                        padding:
                                            const EdgeInsets.only(bottom: 32),
                                        child: leftContent,
                                      ),
                                    ),
                                  ],
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ...rightContentList,
                                      const SizedBox(height: 20),
                                      leftContent,
                                    ],
                                  ),
                                );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context, MyTransactionEntity txn) {
    Color badgeBg;
    Color badgeFg;

    switch (txn.status) {
      case 'بانتظار الاستلام':
        badgeBg = Colors.blue.shade50;
        badgeFg = Colors.blue.shade700;
        break;
      case 'قيد التنفيذ':
        badgeBg = Colors.orange.shade50;
        badgeFg = Colors.orange.shade700;
        break;
      case 'منجزة':
        badgeBg = AppColors.forestLight.withOpacity(0.12);
        badgeFg = AppColors.forest;
        break;
      default: // تم الرفض
        badgeBg = AppColors.umber.withOpacity(0.08);
        badgeFg = AppColors.umber;
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
            // Title + badges + reference
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  textDirection: TextDirection.rtl,
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      txn.number == 'TXN-2024-441'
                          ? 'إجازة خاصة بلا أجر'
                          : txn.type,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppColors.forest,
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        txn.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: badgeFg,
                        ),
                      ),
                    ),
                    if (txn.priority == 'عالية') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.umber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'مستعجل',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.umber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  txn.number,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.charcoal.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Actions Buttons (Header Left)
            _buildActionButtons(context, txn),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MyTransactionEntity txn) {
    if (txn.status == 'بانتظار الاستلام') {
      return ElevatedButton(
        onPressed: () {
          // Dispatch pickup event
          context.read<MyTransactionsBloc>().add(PickupTransaction(txn.number));
          // Success toast
          _showSuccessSnackBar(
              'تم استلام المعاملة ${txn.number} بنجاح — أصبحت الآن قيد التنفيذ');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Text(
          'استلام المعاملة',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    } else if (txn.status == 'قيد التنفيذ') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // E-signature approval button
          ElevatedButton.icon(
            onPressed: () => _openSignatureDialog(context, txn.number),
            icon: const Icon(LucideIcons.shieldCheck, size: 16),
            label: const Text('موافقة وتوقيع إلكتروني'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5649),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // Reject button
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<MyTransactionsBloc>()
                  .add(RejectTransaction(txn.number));
              _showSuccessSnackBar('تم رفض المعاملة ${txn.number}');
            },
            icon: const Icon(LucideIcons.xCircle, size: 16),
            label: const Text('رفض'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B1D2A),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
          const SizedBox(width: 8),

          // Cancel pickup button
          OutlinedButton(
            onPressed: () {
              context
                  .read<MyTransactionsBloc>()
                  .add(CancelPickupTransaction(txn.number));
              _showSuccessSnackBar(
                  'تم إلغاء استلام المعاملة ${txn.number} وإرجاعها لحالة الانتظار');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.charcoal,
              side: BorderSide(color: AppColors.gold.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إلغاء استلام المعاملة'),
          ),
        ],
      );
    }

    return const SizedBox
        .shrink(); // Hide actions if finalized (Completed or Rejected)
  }

  Widget _buildEmployeeCard(MyTransactionEntity txn) {
    final name =
        txn.number == 'TXN-2024-441' ? 'أحمد خالد المحمود' : txn.applicant;
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 50),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'مدرس مادة الرياضيات • ثانوية الباسل للمتفوقين',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Attributes row
                  Wrap(
                    textDirection: TextDirection.rtl,
                    spacing: 24,
                    runSpacing: 8,
                    children: [
                      _buildInfoTag('الرقم الذاتي', '984512'),
                      _buildInfoTag('الخدمة', '8 سنوات'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),
            // Avatar Placeholder with sliders icon
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.sliders,
                color: AppColors.forest,
                size: 20,
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

  Widget _buildRequestDetailsCard(MyTransactionEntity txn) {
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
            // Title: Request subject
            const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(LucideIcons.fileText, color: AppColors.forest, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'موضوع الطلب: إجازة خاصة بلا أجر',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detail lines
            _buildDetailGridItem('المدة المطلوبة', 'سنة دراسية كاملة'),
            const SizedBox(height: 12),
            _buildDetailGridItem('الفترة', '01/09/2026 إلى 31/08/2027'),
            const SizedBox(height: 12),

            // Reason paragraph
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'السبب المذكور:',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.charcoal.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'السفر بقصد العمل لتأمين متطلبات المعيشة. مرفق عقد العمل الخارجي.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.charcoalDark,
                      height: 1.45,
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

  Widget _buildDetailGridItem(String label, String value) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.charcoal.withOpacity(0.65),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoalDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsCard() {
    final docs = [
      {'name': 'وثيقة_قائم_على_رأس_العمل.pdf', 'size': 'MB 1.2'},
      {'name': 'صورة_الهوية_الشخصية.pdf', 'size': 'KB 800'},
      {'name': 'عقد_عمل_مرفق.pdf', 'size': 'MB 2.5'},
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 150),
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
            // Title
            const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(LucideIcons.paperclip, color: AppColors.forest, size: 20),
                SizedBox(width: 8),
                Text(
                  'المرفقات والوثائق',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Files layout list
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;

              final children = docs
                  .map(
                      (doc) => _buildAttachmentItem(doc['name']!, doc['size']!))
                  .toList();

              return isWide
                  ? Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: children
                          .map((w) => SizedBox(
                                width: (constraints.maxWidth - 12) / 2,
                                child: w,
                              ))
                          .toList(),
                    )
                  : Column(
                      children: children
                          .map((w) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: w,
                              ))
                          .toList(),
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(String filename, String size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // PDF icon red
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEEEF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              LucideIcons.fileText,
              color: Color(0xFFC62828),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // File name & size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.charcoal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          // View icon
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.eye, size: 16),
            color: AppColors.charcoal.withOpacity(0.6),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
          // Download icon
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 16),
            color: AppColors.charcoal.withOpacity(0.6),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousNotesCard() {
    final notes = [
      {
        'title': 'دائرة المناهج',
        'date': '04 نيسان 2026',
        'text':
            'لا مانع من منح الإجازة. يتوفر لدينا مدرس بديل لتغطية نصاب مادة الرياضيات في ثانوية الباسل للمتفوقين.',
        'color': AppColors.forestLight,
      },
      {
        'title': 'الشؤون الإدارية',
        'date': '03 نيسان 2026',
        'text':
            'الطلب مستوف للشروط القانونية وتجاوزت خدمة المدرس المدة المطلوبة لطلب الإجازة بلا أجر.',
        'color': AppColors.goldDark,
      }
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 200),
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
            // Title
            const Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(LucideIcons.messageSquare,
                    color: AppColors.forest, size: 20),
                SizedBox(width: 8),
                Text(
                  'ملاحظات الدوائر السابقة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes list
            ...notes.map((note) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    right: BorderSide(
                      color: note['color'] as Color,
                      width: 4,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: note['color'] as Color,
                          ),
                        ),
                        Text(
                          note['date'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.charcoal.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note['text'] as String,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.charcoalDark,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            // Add note text box
            const Text(
              'إضافة ملاحظة',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoalDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              textAlign: TextAlign.right,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظتك هنا...',
                hintStyle: TextStyle(
                  color: AppColors.charcoal.withOpacity(0.4),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFFFAF9F5),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.gold.withOpacity(0.25)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.forest),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowTimeline(MyTransactionEntity txn) {
    final steps = [
      {
        'title': 'تسجيل الديوان',
        'operator': 'محمد خالد',
        'time': '10:00 ص',
        'details': 'تم التسجيل برقم 458/ص',
        'state': 'checked',
      },
      {
        'title': 'الشؤون الإدارية والمناهج',
        'operator': 'سميرة زيدان',
        'time': '11:30 ص',
        'details': 'تم التدقيق وإبداء الرأي',
        'state': 'checked',
      },
      {
        'title': 'رئيس دائرة التعليم الثانوي',
        'operator': txn.status == 'بانتظار الاستلام'
            ? 'بانتظار توقيعك واتخاذ القرار'
            : (txn.status == 'قيد التنفيذ'
                ? 'جاري اتخاذ القرار والتوقيع'
                : (txn.status == 'منجزة'
                    ? 'تم التوقيع والموافقة'
                    : 'تم الرفض')),
        'time': '',
        'details': '',
        'state': txn.status == 'بانتظار الاستلام'
            ? 'active'
            : (txn.status == 'قيد التنفيذ'
                ? 'active_edit'
                : (txn.status == 'منجزة' ? 'checked' : 'rejected')),
      },
      {
        'title': 'مساعد مدير التربية',
        'operator': 'للاطلاع والتوقيع',
        'time': '',
        'details': '',
        'state': 'pending_4',
      },
      {
        'title': 'مدير التربية (القرار النهائي)',
        'operator': 'للاعتماد والتوجيه لإصدار القرار',
        'time': '',
        'details': '',
        'state': 'pending_flag',
      },
    ];

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: const Duration(milliseconds: 250),
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

            // Timeline builder
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isLast = index == steps.length - 1;

                return Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and line column
                    Column(
                      children: [
                        _buildTimelineNode(step['state'] as String),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            color: const Color(0xFFE0E0E0),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Step details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Expanded(
                                child: Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: step['state'] == 'checked'
                                        ? AppColors.charcoalDark
                                        : (step['state'] == 'active' ||
                                                step['state'] == 'active_edit'
                                            ? AppColors.forest
                                            : AppColors.charcoal
                                                .withOpacity(0.6)),
                                  ),
                                ),
                              ),
                              if ((step['time'] as String).isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  step['time'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.charcoal.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['operator'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: step['state'] == 'active' ||
                                      step['state'] == 'active_edit'
                                  ? AppColors.forestLight
                                  : AppColors.charcoal.withOpacity(0.6),
                              fontWeight: step['state'] == 'active' ||
                                      step['state'] == 'active_edit'
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                            ),
                          ),
                          if ((step['details'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                step['details'] as String,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.charcoal.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineNode(String state) {
    if (state == 'checked') {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFE8F5E9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.check,
          color: Color(0xFF2E7D32),
          size: 14,
        ),
      );
    } else if (state == 'active_edit') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.forest, width: 2),
        ),
        child: const Icon(
          LucideIcons.edit2,
          color: AppColors.forest,
          size: 11,
        ),
      );
    } else if (state == 'active') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.gold, width: 2),
        ),
        child: const Center(
          child: SizedBox(
            width: 8,
            height: 8,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.forest,
            ),
          ),
        ),
      );
    } else if (state == 'rejected') {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          LucideIcons.x,
          color: Color(0xFFC62828),
          size: 14,
        ),
      );
    } else if (state == 'pending_4') {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        ),
        child: const Center(
          child: Text(
            '4',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9E9E9E),
            ),
          ),
        ),
      );
    } else {
      // pending_flag
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        ),
        child: const Icon(
          LucideIcons.flag,
          color: Color(0xFF9E9E9E),
          size: 11,
        ),
      );
    }
  }
}
