import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_confirmation_dialog.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/appointment_entities.dart';
import '../bloc/appointments_bloc.dart';
import '../widgets/appointment_dialogs.dart';
import '../widgets/appointment_widgets.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: BlocConsumer<AppointmentsBloc, AppointmentsState>(
          listenWhen: (a, b) =>
              a.successMessage != b.successMessage ||
              a.actionError != b.actionError,
          listener: (context, state) {
            final message = state.actionError ?? state.successMessage;
            if (message != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(message)));
              context
                  .read<AppointmentsBloc>()
                  .add(const ClearAppointmentAction());
            }
          },
          builder: (context, state) => Stack(children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1220),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(
                          onAdd: () => _slotForm(context),
                          onBook: () => _book(context, state.availableSlots),
                        ),
                        const SizedBox(height: 22),
                        AppointmentFilterTabs(
                            value: state.filter,
                            onChanged: (value) => context
                                .read<AppointmentsBloc>()
                                .add(LoadAppointments(value))),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: state.loading
                              ? const AppointmentSkeleton(
                                  key: ValueKey('loading'))
                              : state.error != null && state.slots.isEmpty
                                  ? SizedBox(
                                      height: 360,
                                      child: AppErrorWidget(
                                          message: state.error!,
                                          onRetry: () => context
                                              .read<AppointmentsBloc>()
                                              .add(LoadAppointments(
                                                  state.filter))))
                                  : _AppointmentList(
                                      key: ValueKey(state.filter),
                                      state: state),
                        ),
                      ]),
                ),
              ),
            ),
            if (state.refreshing)
              const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                      minHeight: 2, color: AppColors.primary)),
          ]),
        ),
      );

  Future<void> _slotForm(BuildContext context, [AppointmentSlot? slot]) async {
    final input = await showAppointmentSlotDialog(context, slot: slot);
    if (input == null || !context.mounted) return;
    context.read<AppointmentsBloc>().add(slot == null
        ? CreateAppointmentSlot(input)
        : UpdateAppointmentSlot(slot.id, input));
  }

  Future<void> _book(BuildContext context, List<AppointmentSlot> slots) async {
    if (slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد مواعيد متاحة حالياً')));
      return;
    }
    final input = await showEmployeeBookingDialog(context, slots);
    if (input != null && context.mounted) {
      context.read<AppointmentsBloc>().add(BookEmployeeAppointment(input));
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onBook;
  const _Header({required this.onAdd, required this.onBook});
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (_, constraints) {
        final compact = constraints.maxWidth < 720;
        final text =
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('إدارة المواعيد',
              style: AppTextStyles.displayMedium.copyWith(fontSize: 28)),
          const SizedBox(height: 5),
          Text('تنظيم مواعيد المراجعين وإدارة طلبات الحجز',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary))
        ]);
        final actions = Wrap(spacing: 10, runSpacing: 8, children: [
          OutlinedButton.icon(
              onPressed: onBook,
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(130, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: const Icon(LucideIcons.calendarCheck, size: 18),
              label: const Text('حجز موعد')),
          FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                  minimumSize: const Size(130, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('إضافة موعد'))
        ]);
        return compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [text, const SizedBox(height: 16), actions])
            : Row(children: [Expanded(child: text), actions]);
      });
}

class _AppointmentList extends StatelessWidget {
  final AppointmentsState state;
  const _AppointmentList({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    final entries = <(AppointmentSlot, AppointmentBooking)>[];
    for (final slot in state.slots) {
      for (final booking in slot.bookings) {
        entries.add((slot, booking));
      }
    }
    if (entries.isEmpty) {
      return Column(
        children: [
          AppointmentEmptyState(filter: state.filter),
          if (state.slots.isNotEmpty) ...[
            const SizedBox(height: 18),
            _SlotManagement(slots: state.slots),
          ],
        ],
      );
    }
    return Column(children: [
      for (var i = 0; i < entries.length; i++) ...[
        AppointmentBookingCard(
          slot: entries[i].$1,
          booking: entries[i].$2,
          onDetails: () => showAppointmentDetailsDialog(
              context, entries[i].$1, entries[i].$2),
          onApprove: state.filter == 'pending'
              ? () =>
                  _decision(context, entries[i].$1, entries[i].$2, 'approved')
              : null,
          onReject: state.filter == 'pending'
              ? () =>
                  _decision(context, entries[i].$1, entries[i].$2, 'rejected')
              : null,
          onAttendance: _canAttend(entries[i].$1, entries[i].$2)
              ? (value) => context
                  .read<AppointmentsBloc>()
                  .add(UpdateAppointmentAttendance(entries[i].$2.id, value))
              : null,
          onDelete: state.filter == 'past'
              ? () => _deleteBooking(context, entries[i].$2.id)
              : null,
        ),
        if (i != entries.length - 1) const SizedBox(height: 12),
      ],
      const SizedBox(height: 18),
      _SlotManagement(slots: state.slots),
    ]);
  }

  bool _canAttend(AppointmentSlot slot, AppointmentBooking booking) =>
      ['approved', 'postponed'].contains(booking.status) &&
      (DateTime.tryParse(slot.appointmentDate)?.isAfter(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)) ==
          false);

  Future<void> _decision(BuildContext context, AppointmentSlot slot,
      AppointmentBooking booking, String decision) async {
    final result =
        await showAppointmentDecisionDialog(context, slot, booking, decision);
    if (result != null && context.mounted) {
      context.read<AppointmentsBloc>().add(DecideAppointmentBooking(
          booking.id, result['decision']!, result['note']!));
    }
  }

  Future<void> _deleteBooking(BuildContext context, int id) async {
    await showAppConfirmationDialog(context,
        title: 'حذف الحجز السابق',
        message: 'هل تريد حذف هذا الحجز المنتهي؟',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        icon: LucideIcons.trash2,
        isDestructive: true,
        onConfirm: () async => context
            .read<AppointmentsBloc>()
            .add(DeletePastAppointmentBooking(id)));
  }
}

class _SlotManagement extends StatelessWidget {
  final List<AppointmentSlot> slots;
  const _SlotManagement({required this.slots});
  @override
  Widget build(BuildContext context) => ExpansionTile(
      title: const Text('إدارة فترات المواعيد'),
      children: slots
          .map((slot) => ListTile(
              title: Text(
                  '${slot.appointmentDate} • ${slot.startTime.substring(0, 5)} - ${slot.endTime.substring(0, 5)}'),
              subtitle: Text(
                  'السعة ${slot.capacity} • المتبقي ${slot.remainingSeats}'),
              trailing: Wrap(children: [
                IconButton(
                    tooltip: 'تعديل',
                    onPressed: () async {
                      final input =
                          await showAppointmentSlotDialog(context, slot: slot);
                      if (input != null && context.mounted) {
                        context
                            .read<AppointmentsBloc>()
                            .add(UpdateAppointmentSlot(slot.id, input));
                      }
                    },
                    icon: const Icon(LucideIcons.pencil, size: 18)),
                IconButton(
                    tooltip: 'حذف',
                    color: AppColors.error,
                    onPressed: () => showAppConfirmationDialog(context,
                        title: 'حذف الموعد',
                        message:
                            'هل تريد حذف هذا الموعد؟ سيتم إشعار أصحاب الحجوزات المرتبطة به.',
                        confirmText: 'حذف',
                        cancelText: 'إلغاء',
                        icon: LucideIcons.trash2,
                        isDestructive: true,
                        onConfirm: () async => context
                            .read<AppointmentsBloc>()
                            .add(DeleteAppointmentSlot(slot.id))),
                    icon: const Icon(LucideIcons.trash2, size: 18))
              ])))
          .toList());
}
