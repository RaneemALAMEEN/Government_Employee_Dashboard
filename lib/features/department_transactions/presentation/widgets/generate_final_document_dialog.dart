import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/source_documents_entity.dart';
import '../bloc/final_document_generator/final_document_generator_cubit.dart';
import '../bloc/final_document_generator/final_document_generator_state.dart';

class GenerateFinalDocumentDialog extends StatelessWidget {
  final int transactionId;

  const GenerateFinalDocumentDialog({
    super.key,
    required this.transactionId,
  });

  static Future<bool?> show(BuildContext context, {required int transactionId}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BlocProvider(
        create: (_) => getIt<FinalDocumentGeneratorCubit>()
          ..loadSourceDocuments(transactionId),
        child: GenerateFinalDocumentDialog(transactionId: transactionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinalDocumentGeneratorCubit, FinalDocumentGeneratorState>(
      listener: (context, state) {
        if (state.status == GenerationStatus.success) {
          AppSnackBar.show(
            context,
            message: state.result?.message ?? 'تم توليد الوثيقة النهائية بنجاح',
          );
          Navigator.of(context).pop(true);
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
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: 820,
              constraints: const BoxConstraints(maxHeight: 780),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, state),
                  const Divider(height: 1, color: Color(0xFFEBEBEB)),
                  Expanded(
                    child: _buildBody(context, state),
                  ),
                  const Divider(height: 1, color: Color(0xFFEBEBEB)),
                  _buildFooter(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, FinalDocumentGeneratorState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.forestLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              LucideIcons.filePlus,
              color: AppColors.forest,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'توليد الوثيقة النهائية للمعاملة #$transactionId',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'اختر الملفات والمستندات المراد دمجها بالترتيب المطلوب لإنشاء الوثيقة الرسمية',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.charcoal.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: state.status == GenerationStatus.generating
                ? null
                : () => Navigator.of(context).pop(false),
            icon: const Icon(LucideIcons.x, size: 20),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, FinalDocumentGeneratorState state) {
    if (state.status == GenerationStatus.loadingSources) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CustomSkeletonLoader(width: double.infinity, height: 70),
            SizedBox(height: 14),
            CustomSkeletonLoader(width: double.infinity, height: 70),
            SizedBox(height: 14),
            CustomSkeletonLoader(width: double.infinity, height: 70),
          ],
        ),
      );
    }

    if (state.status == GenerationStatus.error &&
        state.sourceDocuments == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.circleAlert,
                  size: 44, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'تعذر جلب ملفات المعاملة',
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context
                      .read<FinalDocumentGeneratorCubit>()
                      .loadSourceDocuments(transactionId),
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.fileQuestion,
                  size: 48, color: AppColors.goldDark),
              const SizedBox(height: 12),
              const Text(
                'لا توجد مستندات مصدرية مرفقة بهذه المعاملة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'يمكنك المتابعة لتوليد الوثيقة النهائية بغلاف ورمز الاستجابة السريعة (QR) فقط.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.charcoal.withOpacity(0.65),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action bar (Select all / Clear / Info)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المستندات المتاحة (${sources.allDocuments.length})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalDark,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        context.read<FinalDocumentGeneratorCubit>().selectAll(),
                    icon: const Icon(LucideIcons.checkCheck, size: 16),
                    label: const Text('تحديد الكل'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.forest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context
                        .read<FinalDocumentGeneratorCubit>()
                        .clearSelection(),
                    icon: const Icon(LucideIcons.circleOff, size: 16),
                    label: const Text('إلغاء التحديد'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.charcoal.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Document Instances section
          if (sources.documentInstances.isNotEmpty) ...[
            _buildSectionTitle(
              icon: LucideIcons.fileCheck2,
              title: 'نماذج ومستندات النظام المولدة (Document Instances)',
              count: sources.documentInstances.length,
            ),
            const SizedBox(height: 10),
            ...sources.documentInstances.map(
              (doc) => _buildDocumentItem(context, doc, state),
            ),
            const SizedBox(height: 20),
          ],

          // Document Signatures section
          if (sources.documentSignatures.isNotEmpty) ...[
            _buildSectionTitle(
              icon: LucideIcons.paperclip,
              title: 'الملفات والمرفقات الموقعة (Document Signatures)',
              count: sources.documentSignatures.length,
            ),
            const SizedBox(height: 10),
            ...sources.documentSignatures.map(
              (doc) => _buildDocumentItem(context, doc, state),
            ),
            const SizedBox(height: 20),
          ],

          // Selected Order Sequence preview
          if (state.selectedOrder.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.listOrdered,
                          size: 18, color: AppColors.forest),
                      const SizedBox(width: 8),
                      Text(
                        'ترتيب الدمج في الوثيقة النهائية (${state.selectedOrder.length} ملفات مختارة):',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.selectedOrder.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doc = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.forest.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.forest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              doc.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoalDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Move Up
                            if (index > 0)
                              InkWell(
                                onTap: () => context
                                    .read<FinalDocumentGeneratorCubit>()
                                    .moveDocumentUp(doc),
                                child: const Icon(LucideIcons.chevronRight,
                                    size: 14, color: AppColors.charcoal),
                              ),
                            // Move Down
                            if (index < state.selectedOrder.length - 1)
                              InkWell(
                                onTap: () => context
                                    .read<FinalDocumentGeneratorCubit>()
                                    .moveDocumentDown(doc),
                                child: const Icon(LucideIcons.chevronLeft,
                                    size: 14, color: AppColors.charcoal),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: Colors.amber.shade800, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'لم يتم اختيار أي ملفات. سيتم توليد الوثيقة النهائية متضمنة الغلاف الرسمي ورمز QR للتحقق فقط.',
                      style: TextStyle(
                        fontSize: 13,
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

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.forest),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.charcoalDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.forestLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
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

  Widget _buildDocumentItem(
    BuildContext context,
    SourceDocumentItemEntity doc,
    FinalDocumentGeneratorState state,
  ) {
    final isSelected = state.isSelected(doc);
    final orderIndex = state.getSelectionIndex(doc);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context
            .read<FinalDocumentGeneratorCubit>()
            .toggleDocumentSelection(doc),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.forestLight.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.forest
                  : AppColors.charcoal.withOpacity(0.12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox / Sequence Badge
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.forest : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // File Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: doc.isPdf
                      ? const Color(0xFFFDEEEF)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  doc.isPdf ? LucideIcons.fileText : LucideIcons.image,
                  color: doc.isPdf
                      ? const Color(0xFFC62828)
                      : const Color(0xFF1D4ED8),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // File Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoalDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.isInstance
                          ? 'نموذج نظام مولد (PDF)'
                          : (doc.typeDocName.isNotEmpty && doc.typeDocName != doc.name
                              ? '${doc.typeDocName} • ${doc.isPdf ? "مستند مرفوع (PDF)" : "صورة مرفوعة"}'
                              : (doc.isPdf ? 'مستند مرفوع (PDF)' : 'صورة مرفوعة')),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.charcoal.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),

              // Preview button
              if (doc.fileUrl.isNotEmpty) ...[
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(LucideIcons.eye, size: 17),
                  tooltip: 'معاينة المستند',
                  color: AppColors.forest,
                  onPressed: () {
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, FinalDocumentGeneratorState state) {
    final isGenerating = state.status == GenerationStatus.generating;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            state.selectedOrder.isEmpty
                ? 'الوثيقة ستتضمن الغلاف ورمز QR فقط'
                : 'سيتم دمج ${state.selectedOrder.length} مستندات في الوثيقة النهائية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal.withOpacity(0.7),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: isGenerating
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(color: AppColors.charcoal),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isGenerating
                      ? null
                      : () => context
                          .read<FinalDocumentGeneratorCubit>()
                          .generateFinalDocument(transactionId),
                  borderRadius: BorderRadius.circular(8),
                  child: Ink(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isGenerating
                          ? AppColors.forest.withOpacity(0.6)
                          : AppColors.forest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isGenerating) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'جاري التوليد والدمج...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          const Icon(LucideIcons.sparkles,
                              size: 17, color: AppColors.goldLight),
                          const SizedBox(width: 8),
                          const Text(
                            'بدء توليد الوثيقة النهائية',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
