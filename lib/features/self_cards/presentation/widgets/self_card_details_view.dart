import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/self_card_entity.dart';
import '../bloc/self_cards_bloc.dart';
import '../bloc/self_cards_event.dart';
import '../bloc/self_cards_state.dart';
import '../utils/self_card_pdf_generator.dart';
import 'self_card_job_info_card.dart';
import 'self_card_personal_info_card.dart';
import 'self_card_training_courses_table.dart';

class SelfCardDetailsView extends StatefulWidget {
  final SelfCardEntity selfCard;
  final bool showChangeEmployeeButton;
  final VoidCallback? onChangeEmployee;

  const SelfCardDetailsView({
    super.key,
    required this.selfCard,
    this.showChangeEmployeeButton = true,
    this.onChangeEmployee,
  });

  @override
  State<SelfCardDetailsView> createState() => _SelfCardDetailsViewState();
}

class _SelfCardDetailsViewState extends State<SelfCardDetailsView> {
  bool _isStandaloneExporting = false;

  bool _hasSelfCardsBloc(BuildContext context) {
    try {
      return context.read<SelfCardsBloc?>() != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleExportPdf() async {
    if (_hasSelfCardsBloc(context)) {
      context.read<SelfCardsBloc>().add(ExportSelfCardPdfEvent(widget.selfCard));
      return;
    }

    setState(() => _isStandaloneExporting = true);
    try {
      final filePath =
          await SelfCardPdfGenerator.generateAndSave(widget.selfCard);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'تم تصدير البطاقة الذاتية بنجاح إلى: $filePath',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'تعذر تصدير ملف الـ PDF: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStandaloneExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Top Header Card
        _HeroHeaderCard(
          selfCard: widget.selfCard,
          isStandaloneExporting: _isStandaloneExporting,
          onExportPdf: _handleExportPdf,
        ),
        const SizedBox(height: 20),

        // Section 1: Personal Info
        SelfCardPersonalInfoCard(selfCard: widget.selfCard),
        const SizedBox(height: 20),

        // Section 2: Job & Educational Info
        SelfCardJobInfoCard(selfCard: widget.selfCard),
        const SizedBox(height: 20),

        // Section 3: Training Courses
        SelfCardTrainingCoursesTable(
          trainingCourses: widget.selfCard.trainingCourses,
        ),
        const SizedBox(height: 30),
      ],
    );

    if (!_hasSelfCardsBloc(context)) {
      return content;
    }

    return BlocListener<SelfCardsBloc, SelfCardsState>(
      listener: (context, state) {
        if (state.pdfExportSuccessMessage != null) {
          AppSnackBar.show(
            context,
            message: state.pdfExportSuccessMessage!,
          );
          context.read<SelfCardsBloc>().add(const ClearPdfExportStatusEvent());
        } else if (state.pdfExportError != null) {
          AppSnackBar.show(
            context,
            message: state.pdfExportError!,
            isError: true,
          );
          context.read<SelfCardsBloc>().add(const ClearPdfExportStatusEvent());
        }
      },
      child: content,
    );
  }
}

class _HeroHeaderCard extends StatelessWidget {
  final SelfCardEntity selfCard;
  final bool isStandaloneExporting;
  final VoidCallback onExportPdf;

  const _HeroHeaderCard({
    required this.selfCard,
    required this.isStandaloneExporting,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    bool isBlocExporting = false;
    try {
      final state = context.watch<SelfCardsBloc?>()?.state;
      if (state != null) {
        isBlocExporting = state.isExportingPdf;
      }
    } catch (_) {}

    final isExporting = isBlocExporting || isStandaloneExporting;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.forest.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // Avatar Badge
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              LucideIcons.user,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),

          // Name and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        selfCard.fullName,
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: selfCard.isActive
                            ? AppColors.forest.withValues(alpha: 0.12)
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: selfCard.isActive
                              ? AppColors.forest.withValues(alpha: 0.3)
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selfCard.isActive
                                ? LucideIcons.checkCircle2
                                : LucideIcons.alertCircle,
                            size: 14,
                            color: selfCard.isActive
                                ? AppColors.forest
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selfCard.isActive ? 'على رأس عمله' : 'غير نشط',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: selfCard.isActive
                                  ? AppColors.forest
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (selfCard.selfNumber != null &&
                        selfCard.selfNumber!.isNotEmpty)
                      _MetaBadge(
                        icon: LucideIcons.badgeCheck,
                        label: 'الرقم الذاتي: ${selfCard.selfNumber}',
                      ),
                    if (selfCard.nationalId != null &&
                        selfCard.nationalId!.isNotEmpty)
                      _MetaBadge(
                        icon: LucideIcons.creditCard,
                        label: 'الرقم الوطني: ${selfCard.nationalId}',
                      ),
                    if (selfCard.educationDegree != null &&
                        selfCard.educationDegree!.isNotEmpty)
                      _MetaBadge(
                        icon: LucideIcons.graduationCap,
                        label: selfCard.educationDegree!,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          ElevatedButton.icon(
            onPressed: isExporting ? null : onExportPdf,
            icon: isExporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(LucideIcons.fileDown, size: 18),
            label: Text(isExporting ? 'جارٍ التصدير...' : 'تصدير PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 13, color: AppColors.forest),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.charcoalDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
