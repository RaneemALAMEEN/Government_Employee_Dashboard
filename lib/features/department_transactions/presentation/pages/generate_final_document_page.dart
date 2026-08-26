import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/source_documents_entity.dart';
import '../bloc/final_document_generator/final_document_generator_cubit.dart';
import '../bloc/final_document_generator/final_document_generator_state.dart';

class GenerateFinalDocumentPage extends StatelessWidget {
  final int transactionId;

  const GenerateFinalDocumentPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FinalDocumentGeneratorCubit>()
        ..loadSourceDocuments(transactionId),
      child: _GenerateFinalDocumentView(transactionId: transactionId),
    );
  }
}

class _GenerateFinalDocumentView extends StatelessWidget {
  final int transactionId;

  const _GenerateFinalDocumentView({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinalDocumentGeneratorCubit, FinalDocumentGeneratorState>(
      listener: (context, state) {
        if (state.status == GenerationStatus.success) {
          AppSnackBar.show(
            context,
            message: state.result?.message ?? 'تم توليد الوثيقة النهائية بنجاح',
          );
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/department-transaction-details/$transactionId');
          }
        } else if (state.status == GenerationStatus.error &&
            state.errorMessage != null) {
          AppSnackBar.show(
            context,
            message: state.errorMessage!,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Breadcrumb
                      FadeInDown(
                        duration: const Duration(milliseconds: 250),
                        child: AppBackButton(
                          label: 'العودة لتفاصيل المعاملة #$transactionId',
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(
                                  '/department-transaction-details/$transactionId');
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header Card
                      FadeInDown(
                        duration: const Duration(milliseconds: 300),
                        child: _buildHeaderCard(context, state),
                      ),
                      const SizedBox(height: 24),

                      // Main Content Card
                      FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBodyContent(context, state),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              _buildFooterBar(context, state),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(
      BuildContext context, FinalDocumentGeneratorState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.forestLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.filePlus,
              color: AppColors.forest,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'توليد الوثيقة النهائية للمعاملة #$transactionId',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoalDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'دمج المستندات المصدرية',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forest,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'اختر الملفات والمستندات المراد تضمينها بالترتيب المطلوب لإنشاء الوثيقة الرسمية المدمجة المعتمدة مع رمز الاستجابة السريعة (QR).',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.charcoal.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(
      BuildContext context, FinalDocumentGeneratorState state) {
    if (state.status == GenerationStatus.loadingSources) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            CustomSkeletonLoader(width: double.infinity, height: 80),
            SizedBox(height: 16),
            CustomSkeletonLoader(width: double.infinity, height: 80),
            SizedBox(height: 16),
            CustomSkeletonLoader(width: double.infinity, height: 80),
          ],
        ),
      );
    }

    if (state.status == GenerationStatus.error &&
        state.sourceDocuments == null) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circleAlert,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 14),
              Text(
                state.errorMessage ?? 'تعذر جلب ملفات ومستندات المعاملة',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context
                      .read<FinalDocumentGeneratorCubit>()
                      .loadSourceDocuments(transactionId),
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.refreshCw,
                            size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

    final sources = state.sourceDocuments;
    if (sources == null || sources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.fileQuestion,
                  size: 54, color: AppColors.goldDark),
              const SizedBox(height: 14),
              const Text(
                'لا توجد مستندات مصدرية مرفقة بهذه المعاملة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك المتابعة لتوليد الوثيقة النهائية بغلاف رسمي ورمز الاستجابة السريعة (QR) فقط.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.charcoal.withOpacity(0.65),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar (Select all / Clear)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.files,
                      size: 20, color: AppColors.forest),
                  const SizedBox(width: 8),
                  Text(
                    'المستندات والملفات المتاحة (${sources.allDocuments.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        context.read<FinalDocumentGeneratorCubit>().selectAll(),
                    icon: const Icon(LucideIcons.checkCheck, size: 17),
                    label: const Text('تحديد الكل'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.forest,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () => context
                        .read<FinalDocumentGeneratorCubit>()
                        .clearSelection(),
                    icon: const Icon(LucideIcons.circleOff, size: 17),
                    label: const Text('إلغاء التحديد'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.charcoal.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Document Instances section
          if (sources.documentInstances.isNotEmpty) ...[
            _buildSectionHeader(
              icon: LucideIcons.fileCheck2,
              title: 'نماذج ومستندات النظام المولدة (Document Instances)',
              count: sources.documentInstances.length,
            ),
            const SizedBox(height: 12),
            ...sources.documentInstances.map(
              (doc) => _buildDocumentCard(context, doc, state),
            ),
            const SizedBox(height: 24),
          ],

          // Document Signatures section
          if (sources.documentSignatures.isNotEmpty) ...[
            _buildSectionHeader(
              icon: LucideIcons.paperclip,
              title: 'الملفات والمرفقات الموقعة (Document Signatures)',
              count: sources.documentSignatures.length,
            ),
            const SizedBox(height: 12),
            ...sources.documentSignatures.map(
              (doc) => _buildDocumentCard(context, doc, state),
            ),
            const SizedBox(height: 24),
          ],

          // Merging sequence preview
          if (state.selectedOrder.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.listOrdered,
                          size: 20, color: AppColors.forest),
                      const SizedBox(width: 10),
                      Text(
                        'ترتيب الدمج في الوثيقة النهائية (${state.selectedOrder.length} مستندات مختارة):',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: state.selectedOrder.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.forest.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.forest,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              doc.displayName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Move Up
                            if (index > 0)
                              InkWell(
                                onTap: () => context
                                    .read<FinalDocumentGeneratorCubit>()
                                    .moveDocumentUp(doc),
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(LucideIcons.chevronRight,
                                      size: 16, color: AppColors.charcoal),
                                ),
                              ),
                            // Move Down
                            if (index < state.selectedOrder.length - 1)
                              InkWell(
                                onTap: () => context
                                    .read<FinalDocumentGeneratorCubit>()
                                    .moveDocumentDown(doc),
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(LucideIcons.chevronLeft,
                                      size: 16, color: AppColors.charcoal),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info,
                      color: Colors.amber.shade800, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'لم يتم اختيار أي ملفات. سيتم توليد الوثيقة النهائية متضمنة الغلاف الرسمي ورمز QR للتحقق فقط.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.forest),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.forestLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.forest,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    SourceDocumentItemEntity doc,
    FinalDocumentGeneratorState state,
  ) {
    final isSelected = state.isSelected(doc);
    final orderIndex = state.getSelectionIndex(doc);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => context
            .read<FinalDocumentGeneratorCubit>()
            .toggleDocumentSelection(doc),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.forestLight.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.forest
                  : AppColors.charcoal.withOpacity(0.14),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.forest.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Checkbox / Sequence Badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.forest : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forest
                        : AppColors.charcoal.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isSelected
                    ? Text(
                        '$orderIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),

              // File Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: doc.isPdf
                      ? const Color(0xFFFDEEEF)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  doc.isPdf ? LucideIcons.fileText : LucideIcons.image,
                  color: doc.isPdf
                      ? const Color(0xFFC62828)
                      : const Color(0xFF1D4ED8),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // File Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoalDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      doc.isInstance
                          ? 'نموذج نظام مولد (PDF)'
                          : (doc.typeDocName.isNotEmpty && doc.typeDocName != doc.name
                              ? '${doc.typeDocName} • ${doc.isPdf ? "مستند مرفوع (PDF)" : "صورة مرفوعة"}'
                              : (doc.isPdf ? 'مستند مرفوع (PDF)' : 'صورة مرفوعة')),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.charcoal.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),

              // Preview Action Button
              if (doc.fileUrl.isNotEmpty) ...[
                const SizedBox(width: 12),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (doc.isPdf) {
                        context.push('/pdf-viewer', extra: {
                          'fileUrl': doc.fileUrl,
                          'title': doc.displayName,
                          'readOnly': true,
                        });
                      } else {
                        context.push('/image-viewer', extra: {
                          'fileUrl': doc.fileUrl,
                          'title': doc.displayName,
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.goldLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(LucideIcons.eye,
                              size: 16, color: AppColors.charcoalDark),
                          SizedBox(width: 6),
                          Text(
                            'معاينة',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoalDark,
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
      ),
    );
  }

  Widget _buildFooterBar(
      BuildContext context, FinalDocumentGeneratorState state) {
    final isGenerating = state.status == GenerationStatus.generating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.selectedOrder.isEmpty
                ? 'الوثيقة ستتضمن الغلاف الرسمي ورمز QR فقط'
                : 'سيتم دمج ${state.selectedOrder.length} مستندات في الوثيقة النهائية',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal.withOpacity(0.75),
            ),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: isGenerating
                    ? null
                    : () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(
                              '/department-transaction-details/$transactionId');
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.charcoal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  side: BorderSide(
                      color: AppColors.charcoal.withValues(alpha: 0.25)),
                ),
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 14),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isGenerating
                      ? null
                      : () => context
                          .read<FinalDocumentGeneratorCubit>()
                          .generateFinalDocument(transactionId),
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isGenerating
                          ? AppColors.forest.withOpacity(0.6)
                          : AppColors.forest,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forest.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isGenerating) ...[
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'جاري التوليد والدمج...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ] else ...[
                          const Icon(LucideIcons.sparkles,
                              size: 18, color: AppColors.goldLight),
                          const SizedBox(width: 10),
                          const Text(
                            'بدء توليد الوثيقة النهائية',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
