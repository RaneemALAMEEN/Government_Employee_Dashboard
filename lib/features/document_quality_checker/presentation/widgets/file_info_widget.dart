import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/file_info.dart';

/// Displays metadata about the uploaded file with action buttons.
class FileInfoWidget extends StatelessWidget {
  final UploadedFileInfo fileInfo;
  final VoidCallback onNewFile;
  final VoidCallback onReanalyze;
  final VoidCallback onDelete;

  const FileInfoWidget({
    super.key,
    required this.fileInfo,
    required this.onNewFile,
    required this.onReanalyze,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withOpacity(0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File name + badge
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: fileInfo.isPdf
                          ? AppColors.umber.withOpacity(0.10)
                          : AppColors.forest.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      fileInfo.typeLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: AppTextStyles.semiBold,
                        color: fileInfo.isPdf ? AppColors.umber : AppColors.forest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fileInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Metadata rows
            _MetaRow(icon: LucideIcons.fileType, label: 'النوع', value: '.${fileInfo.extension}'),
            const SizedBox(height: 6),
            _MetaRow(icon: LucideIcons.hardDrive, label: 'الحجم', value: fileInfo.formattedSize),
            const SizedBox(height: 6),
            _MetaRow(icon: LucideIcons.calendar, label: 'تاريخ الرفع', value: fileInfo.formattedDate),

            const SizedBox(height: 16),

            // Action buttons
            Directionality(
              textDirection: TextDirection.rtl,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ActionButton(
                    icon: LucideIcons.uploadCloud,
                    label: 'رفع ملف جديد',
                    onTap: onNewFile,
                    isPrimary: true,
                  ),
                  _ActionButton(
                    icon: LucideIcons.refreshCw,
                    label: 'إعادة التحليل',
                    onTap: onReanalyze,
                  ),
                  _ActionButton(
                    icon: LucideIcons.trash2,
                    label: 'حذف الملف',
                    onTap: onDelete,
                    isDanger: true,
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

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.goldDark),
          const SizedBox(width: 6),
          Text(
            '$label:',
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.charcoal),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: AppTextStyles.semiBold,
              color: AppColors.charcoalDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isDanger;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    if (isPrimary) {
      bg = AppColors.forest;
      fg = AppColors.white;
    } else if (isDanger) {
      bg = AppColors.umber.withOpacity(0.08);
      fg = AppColors.umber;
    } else {
      bg = AppColors.goldLight;
      fg = AppColors.charcoalDark;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: AppTextStyles.semiBold,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
