import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_confirmation_dialog.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../domain/entities/appointment_entities.dart';
import '../bloc/appointments_bloc.dart';
import '../widgets/appointment_dialogs.dart';
import '../widgets/appointment_widgets.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String _selectedTab = 'available';

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
              AppSnackBar.show(
                context,
                message: message,
                isError: state.actionError != null,
                title: state.actionError != null
                    ? 'تعذر إتمام العملية'
                    : 'تمت العملية بنجاح',
              );
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
                            onBook: () => _book(context, state.availableSlots)),
                        const SizedBox(height: 22),
                        AppointmentFilterTabs(
                            value: _selectedTab,
                            onChanged: (value) {
                              setState(() => _selectedTab = value);
                              if (value == 'available') {
                                context
                                    .read<AppointmentsBloc>()
                                    .add(const LoadAvailableAppointmentSlots());
                              } else {
                                context
                                    .read<AppointmentsBloc>()
                                    .add(LoadAppointments(value));
                              }
                            }),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          child: _selectedTab == 'available'
                              ? _AvailableSlotsTab(
                                  key: const ValueKey('available'),
                                  state: state,
                                  onAdd: () => _slotForm(context),
                                )
                              : state.loading
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
      AppSnackBar.show(
        context,
        message: 'أضف فترة جديدة أولاً لتتمكن من حجز موعد للمراجع.',
        title: 'لا توجد مواعيد متاحة حالياً',
        backgroundColor: AppColors.goldDark,
        icon: LucideIcons.info,
      );
      return;
    }
    final input = await showEmployeeBookingDialog(context, slots);
    if (input != null && context.mounted) {
      context.read<AppointmentsBloc>().add(BookEmployeeAppointment(input));
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBook;
  const _Header({required this.onBook});
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
      return AppointmentEmptyState(filter: state.filter);
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

class _AvailableSlotsTab extends StatelessWidget {
  final AppointmentsState state;
  final VoidCallback onAdd;
  const _AvailableSlotsTab({
    super.key,
    required this.state,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(builder: (_, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المواعيد المتاحة للحجز',
                  style: AppTextStyles.titleLarge),
              const SizedBox(height: 4),
              Text(
                'إدارة الفترات التي يمكن للمراجعين الحجز ضمنها',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          );
          final button = FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(LucideIcons.plus, size: 17),
            label: const Text('إضافة موعد'),
          );
          return constraints.maxWidth < 600
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [title, const SizedBox(height: 14), button],
                )
              : Row(children: [Expanded(child: title), button]);
        }),
        const SizedBox(height: 18),
        if (state.availableLoading && state.availableSlots.isEmpty)
          const AppointmentSkeleton()
        else if (state.availableError != null && state.availableSlots.isEmpty)
          SizedBox(
            height: 330,
            child: AppErrorWidget(
              message: state.availableError!,
              onRetry: () => context
                  .read<AppointmentsBloc>()
                  .add(const LoadAvailableAppointmentSlots()),
            ),
          )
        else if (state.availableSlots.isEmpty)
          AppointmentAvailableEmptyState(onAdd: onAdd)
        else
          LayoutBuilder(builder: (_, constraints) {
            final actualColumns = constraints.maxWidth >= 1050
                ? 3
                : (constraints.maxWidth >= 650 ? 2 : 1);
            const gap = 14.0;
            final width = (constraints.maxWidth - gap * (actualColumns - 1)) /
                actualColumns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: state.availableSlots
                  .map((slot) => SizedBox(
                        width: width,
                        child: AppointmentSlotCard(
                          slot: slot,
                          onEdit: () => _edit(context, slot),
                          onDelete: () => _delete(context, slot),
                          onActiveChanged: (active) => _toggle(
                            context,
                            slot,
                            active,
                          ),
                        ),
                      ))
                  .toList(),
            );
          }),
      ],
    );
  }

  Future<void> _edit(BuildContext context, AppointmentSlot slot) async {
    final input = await showAppointmentSlotDialog(context, slot: slot);
    if (input != null && context.mounted) {
      context
          .read<AppointmentsBloc>()
          .add(UpdateAppointmentSlot(slot.id, input));
    }
  }

  Future<void> _delete(BuildContext context, AppointmentSlot slot) async {
    await showAppConfirmationDialog(
      context,
      title: 'حذف الموعد نهائياً؟',
      message: 'هذا الإجراء مختلف عن الإيقاف المؤقت، وسيتم حذف الموعد '
          'وإشعار أصحاب الحجوزات المرتبطة به.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      icon: LucideIcons.trash2,
      isDestructive: true,
      onConfirm: () async =>
          context.read<AppointmentsBloc>().add(DeleteAppointmentSlot(slot.id)),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    AppointmentSlot slot,
    bool active,
  ) async {
    final now = DateTime.now();
    final date = DateTime.tryParse(slot.appointmentDate);
    final isPast =
        date != null && date.isBefore(DateTime(now.year, now.month, now.day));
    if (isPast) return;

    await showAppConfirmationDialog(
      context,
      title: active ? 'إعادة تفعيل الموعد؟' : 'إيقاف هذا الموعد مؤقتاً؟',
      message: active
          ? 'سيصبح هذا الموعد متاحاً للحجز من جديد.'
          : 'لن يتم حذف الموعد أو الحجوزات المرتبطة به، ولكن لن يكون '
              'متاحاً لحجوزات جديدة حتى تتم إعادة تفعيله.',
      confirmText: active ? 'تفعيل' : 'إيقاف مؤقت',
      cancelText: 'إلغاء',
      icon: active ? Icons.check_circle_outline : Icons.pause_circle_outline,
      onConfirm: () async {
        context.read<AppointmentsBloc>().add(UpdateAppointmentSlot(
              slot.id,
              AppointmentSlotInput(
                appointmentDate: slot.appointmentDate,
                startTime: slot.startTime,
                endTime: slot.endTime,
                capacity: slot.capacity,
                isActive: active,
              ),
              successMessage: active
                  ? 'تم تفعيل الموعد وإتاحته للحجز'
                  : 'تم إيقاف الموعد مؤقتاً',
            ));
      },
    );
  }
}
