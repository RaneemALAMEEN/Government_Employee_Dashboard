import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/appointment_entities.dart';

class AppointmentFilterTabs extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const AppointmentFilterTabs(
      {super.key, required this.value, required this.onChanged});

  static const tabs = {
    'pending': 'بانتظار الموافقة',
    'approved': 'الموافق عليها',
    'past': 'السابقة',
  };

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tabs.entries.map((entry) {
          final selected = entry.key == value;
          return ChoiceChip(
            label: Text(entry.value),
            selected: selected,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? AppTextStyles.bold : AppTextStyles.medium,
            ),
            side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFFE1E5E3)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          );
        }).toList(),
      );
}

class AppointmentStatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const AppointmentStatusBadge(
      {super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'approved' => AppColors.forest,
      'pending' => const Color(0xFF9A6B16),
      'rejected' => AppColors.error,
      'postponed' => const Color(0xFF6B5C9A),
      'cancelled' => AppColors.textSecondary,
      _ => AppColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(30)),
      child: Text(label.isEmpty ? status : label,
          style: AppTextStyles.labelLarge
              .copyWith(color: color, fontWeight: AppTextStyles.bold)),
    );
  }
}

class AppointmentBookingCard extends StatefulWidget {
  final AppointmentSlot slot;
  final AppointmentBooking booking;
  final VoidCallback onDetails;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final ValueChanged<bool>? onAttendance;
  final VoidCallback? onDelete;
  const AppointmentBookingCard({
    super.key,
    required this.slot,
    required this.booking,
    required this.onDetails,
    this.onApprove,
    this.onReject,
    this.onAttendance,
    this.onDelete,
  });
  @override
  State<AppointmentBookingCard> createState() => _AppointmentBookingCardState();
}

class _AppointmentBookingCardState extends State<AppointmentBookingCard> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, hovered ? -2 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: hovered
                  ? AppColors.primary.withValues(alpha: .35)
                  : const Color(0xFFE7E9E5)),
          boxShadow: hovered
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 18,
                      offset: const Offset(0, 7))
                ]
              : null,
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            CircleAvatar(
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: AppColors.primary,
                child: Text(
                    booking.firstName.isEmpty ? '؟' : booking.firstName[0])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(booking.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium),
                  Text('الرقم الوطني: ${booking.nationalId}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ])),
            AppointmentStatusBadge(
                status: booking.status, label: booking.statusLabel),
          ]),
          const SizedBox(height: 15),
          Wrap(spacing: 18, runSpacing: 8, children: [
            _Info(
                icon: LucideIcons.calendarDays,
                text: widget.slot.appointmentDate),
            _Info(
                icon: LucideIcons.clock3,
                text:
                    '${_time(widget.slot.startTime)} - ${_time(widget.slot.endTime)}'),
            if (booking.queueOrder != null)
              _Info(
                  icon: LucideIcons.hash, text: 'الدور ${booking.queueOrder}'),
            _Info(icon: LucideIcons.messageSquareText, text: booking.reason),
          ]),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEF0EE)),
          const SizedBox(height: 14),
          Wrap(spacing: 9, runSpacing: 9, children: [
            OutlinedButton.icon(
                onPressed: widget.onDetails,
                icon: const Icon(LucideIcons.eye, size: 17),
                label: const Text('التفاصيل'),
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size(105, 42),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)))),
            if (widget.onReject != null)
              OutlinedButton.icon(
                  onPressed: widget.onReject,
                  icon: const Icon(LucideIcons.x, size: 17),
                  label: const Text('رفض'),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size(95, 42),
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                          color: AppColors.error.withValues(alpha: .45)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)))),
            if (widget.onApprove != null)
              FilledButton.icon(
                  onPressed: widget.onApprove,
                  icon: const Icon(LucideIcons.check, size: 17),
                  label: const Text('موافقة'),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size(105, 42),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)))),
            if (widget.onAttendance != null)
              PopupMenuButton<bool>(
                onSelected: widget.onAttendance,
                itemBuilder: (_) => const [
                  PopupMenuItem(value: true, child: Text('حضر')),
                  PopupMenuItem(value: false, child: Text('لم يحضر'))
                ],
                child: const _MenuAction(
                    icon: LucideIcons.userCheck, label: 'تسجيل الحضور'),
              ),
            if (widget.onDelete != null)
              IconButton(
                  onPressed: widget.onDelete,
                  tooltip: 'حذف الحجز',
                  color: AppColors.error,
                  icon: const Icon(LucideIcons.trash2, size: 19)),
          ]),
        ]),
      ),
    );
  }
}

String _time(String value) => value.length >= 5 ? value.substring(0, 5) : value;

class _Info extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Info({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall))
      ]);
}

class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuAction({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD9DEDB)),
          borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 17),
        const SizedBox(width: 7),
        Text(label)
      ]));
}

class AppointmentEmptyState extends StatelessWidget {
  final String filter;
  const AppointmentEmptyState({super.key, required this.filter});
  @override
  Widget build(BuildContext context) {
    final text = switch (filter) {
      'pending' => 'لا توجد طلبات بانتظار الموافقة',
      'approved' => 'لا توجد حجوزات مؤكدة حالياً',
      _ => 'لا توجد حجوزات سابقة'
    };
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 70),
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE7E9E5))),
        child: Column(children: [
          const Icon(LucideIcons.calendarX2,
              size: 44, color: AppColors.goldDark),
          const SizedBox(height: 14),
          Text(text, style: AppTextStyles.titleMedium)
        ]));
  }
}

class AppointmentSkeleton extends StatelessWidget {
  const AppointmentSkeleton({super.key});
  @override
  Widget build(BuildContext context) => Column(
      children: List.generate(
          5,
          (_) => const CustomSkeletonLoader(
              width: double.infinity,
              height: 170,
              borderRadius: 18,
              margin: EdgeInsets.only(bottom: 12))));
}
