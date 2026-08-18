import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/utils/app_file_url.dart';
import '../../domain/entities/appointment_entities.dart';
import 'appointment_image_preview.dart';
import 'appointment_widgets.dart';

String _shortTime(String value) =>
    value.length >= 5 ? value.substring(0, 5) : value;

String _arabicDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

Future<T?> _showAppointmentDialog<T>(
  BuildContext context,
  WidgetBuilder builder,
) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'إغلاق',
    barrierColor: Colors.black.withValues(alpha: .28),
    transitionDuration: const Duration(milliseconds: 210),
    pageBuilder: (context, _, __) => builder(context),
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(begin: .97, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
}

Future<AppointmentSlotInput?> showAppointmentSlotDialog(
  BuildContext context, {
  AppointmentSlot? slot,
}) =>
    _showAppointmentDialog(context, (_) => _SlotDialog(slot: slot));

class _SlotDialog extends StatefulWidget {
  final AppointmentSlot? slot;
  const _SlotDialog({this.slot});

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _dateValue = widget.slot?.appointmentDate ?? '';
  late final _date = TextEditingController(
    text: _dateValue.isEmpty ? '' : _arabicDate(_dateValue),
  );
  late final _start = TextEditingController(
    text: widget.slot == null ? '' : _shortTime(widget.slot!.startTime),
  );
  late final _end = TextEditingController(
    text: widget.slot == null ? '' : _shortTime(widget.slot!.endTime),
  );
  late final _capacity = TextEditingController(
    text: widget.slot?.capacity.toString() ?? '',
  );
  late bool _active = widget.slot?.isActive ?? true;

  @override
  void dispose() {
    _date.dispose();
    _start.dispose();
    _end.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateValue) ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    _dateValue = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    setState(() => _date.text = _arabicDate(_dateValue));
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final parts = controller.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? TimeOfDay.now().hour,
            minute: int.tryParse(parts[1]) ?? TimeOfDay.now().minute,
          )
        : TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(
        () => controller.text = '${picked.hour.toString().padLeft(2, '0')}:'
            '${picked.minute.toString().padLeft(2, '0')}');
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      AppointmentSlotInput(
        appointmentDate: _dateValue,
        startTime: _start.text,
        endTime: _end.text,
        capacity: int.parse(_capacity.text),
        isActive: widget.slot == null ? null : _active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
        title: widget.slot == null ? 'إضافة موعد' : 'تعديل الموعد',
        subtitle: widget.slot == null
            ? 'حدد التاريخ والوقت والسعة المتاحة للحجز'
            : 'حدّث بيانات الفترة المتاحة للحجز',
        maxWidth: 570,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.slot != null) ...[
                const _Notice(
                  text: 'سيؤدي تعديل تاريخ أو وقت هذا الموعد إلى تأجيل '
                      'الحجوزات المرتبطة به وإشعار أصحابها.',
                ),
                const SizedBox(height: 16),
              ],
              AppointmentFormField(
                label: 'التاريخ',
                controller: _date,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: LucideIcons.calendarDays,
                hintText: 'اختر تاريخ الموعد',
                validator: (_) => _dateValue.isEmpty ? 'التاريخ مطلوب' : null,
              ),
              const SizedBox(height: 14),
              _ResponsiveFieldRow(
                children: [
                  AppointmentFormField(
                    label: 'وقت البداية',
                    controller: _start,
                    readOnly: true,
                    onTap: () => _pickTime(_start),
                    suffixIcon: LucideIcons.clock3,
                    hintText: '00:00',
                    validator: (value) => value == null || value.isEmpty
                        ? 'وقت البداية مطلوب'
                        : null,
                  ),
                  AppointmentFormField(
                    label: 'وقت النهاية',
                    controller: _end,
                    readOnly: true,
                    onTap: () => _pickTime(_end),
                    suffixIcon: LucideIcons.clock4,
                    hintText: '00:00',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'وقت النهاية مطلوب';
                      }
                      if (_start.text.isNotEmpty &&
                          value.compareTo(_start.text) <= 0) {
                        return 'يجب أن يكون بعد البداية';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppointmentFormField(
                label: 'السعة المتاحة',
                controller: _capacity,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffixIcon: LucideIcons.users,
                hintText: 'عدد المراجعين',
                validator: (value) => (int.tryParse(value ?? '') ?? 0) < 1
                    ? 'أدخل عدداً أكبر من صفر'
                    : null,
              ),
              if (widget.slot != null) ...[
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  activeTrackColor: AppColors.primary,
                  onChanged: (value) => setState(() => _active = value),
                  title: const Text('الموعد نشط'),
                  subtitle: const Text('يمكن للمراجعين اختيار هذه الفترة'),
                ),
              ],
              const SizedBox(height: 22),
              _DialogActions(
                onSubmit: _submit,
                submitText:
                    widget.slot == null ? 'إضافة الموعد' : 'حفظ التعديل',
              ),
            ],
          ),
        ),
      );
}

Future<Map<String, String>?> showAppointmentDecisionDialog(
  BuildContext context,
  AppointmentSlot slot,
  AppointmentBooking booking,
  String decision,
) =>
    _showAppointmentDialog(
      context,
      (_) => _DecisionDialog(
        slot: slot,
        booking: booking,
        decision: decision,
      ),
    );

class _DecisionDialog extends StatefulWidget {
  final AppointmentSlot slot;
  final AppointmentBooking booking;
  final String decision;
  const _DecisionDialog({
    required this.slot,
    required this.booking,
    required this.decision,
  });

  @override
  State<_DecisionDialog> createState() => _DecisionDialogState();
}

class _DecisionDialogState extends State<_DecisionDialog> {
  final _note = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approved = widget.decision == 'approved';
    return _DialogFrame(
      title: approved ? 'الموافقة على الحجز' : 'رفض الحجز',
      subtitle: 'راجع الطلب وأضف ملاحظة واضحة للمراجع',
      maxWidth: 520,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BookingSummary(slot: widget.slot, booking: widget.booking),
            const SizedBox(height: 18),
            AppointmentFormField(
              label: 'ملاحظة القرار',
              controller: _note,
              maxLines: 3,
              hintText: 'اكتب محتوى الإشعار الذي سيصل إلى المراجع...',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'الملاحظة مطلوبة'
                  : null,
            ),
            const SizedBox(height: 22),
            _DialogActions(
              submitText: approved ? 'تأكيد الموافقة' : 'تأكيد الرفض',
              destructive: !approved,
              onSubmit: () {
                if (!_formKey.currentState!.validate()) return;
                Navigator.pop(context, {
                  'decision': widget.decision,
                  'note': _note.text.trim(),
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showAppointmentDetailsDialog(
  BuildContext context,
  AppointmentSlot slot,
  AppointmentBooking booking,
) =>
    _showAppointmentDialog<void>(
      context,
      (_) => _DialogFrame(
        title: 'تفاصيل الحجز',
        subtitle: booking.fullName,
        trailing: AppointmentStatusBadge(
          status: booking.status,
          label: booking.statusLabel,
        ),
        maxWidth: 650,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (booking.identityImagePath?.isNotEmpty == true) ...[
              AppointmentImagePreview(
                imageProvider: NetworkImage(
                  buildAbsoluteFileUrl(booking.identityImagePath!),
                ),
              ),
              const SizedBox(height: 20),
            ],
            _DetailsSection(
              title: 'بيانات المراجع',
              icon: LucideIcons.userRound,
              values: {
                'الاسم الكامل': booking.fullName,
                'الرقم الوطني': booking.nationalId,
                'رقم الهاتف': booking.phoneNumber,
                'اسم الأم': booking.motherName,
              },
            ),
            const SizedBox(height: 18),
            _DetailsSection(
              title: 'تفاصيل الموعد',
              icon: LucideIcons.calendarDays,
              values: {
                'التاريخ': _arabicDate(slot.appointmentDate),
                'الوقت':
                    '${_shortTime(slot.startTime)} - ${_shortTime(slot.endTime)}',
                'سبب الزيارة': booking.reason,
              },
            ),
            if (booking.decisionNote?.isNotEmpty == true) ...[
              const SizedBox(height: 18),
              _DetailsSection(
                title: 'القرار',
                icon: LucideIcons.messageSquareText,
                values: {'ملاحظة القرار': booking.decisionNote!},
              ),
            ],
          ],
        ),
      ),
    );

Future<AppointmentBookingInput?> showEmployeeBookingDialog(
  BuildContext context,
  List<AppointmentSlot> slots,
) =>
    _showAppointmentDialog(
      context,
      (_) => _BookingDialog(slots: slots),
    );

class _BookingDialog extends StatefulWidget {
  final List<AppointmentSlot> slots;
  const _BookingDialog({required this.slots});

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = List.generate(7, (_) => TextEditingController());
  int? _slotId;
  String? _imagePath;
  String? _imageError;

  static const _labels = [
    'الاسم',
    'الكنية',
    'اسم الأب',
    'اسم الأم',
    'الرقم الوطني',
    'رقم الهاتف',
    'سبب الموعد',
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateField(int index, String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'هذا الحقل مطلوب';
    if (index == 4 && !RegExp(r'^\d{1,11}$').hasMatch(text)) {
      return 'أدخل أرقاماً فقط، بحد أقصى 11 رقماً';
    }
    if (index == 5 && !RegExp(r'^09\d{8}$').hasMatch(text)) {
      return 'رقم الهاتف يجب أن يكون 10 خانات ويبدأ بـ 09';
    }
    return null;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() {
        _imagePath = path;
        _imageError = null;
      });
    }
  }

  void _submit() {
    final valid = _formKey.currentState!.validate();
    if (_imagePath == null) setState(() => _imageError = 'صورة الهوية مطلوبة');
    if (!valid || _imagePath == null) return;
    Navigator.pop(
      context,
      AppointmentBookingInput(
        appointmentId: _slotId!,
        firstName: _controllers[0].text.trim(),
        lastName: _controllers[1].text.trim(),
        fatherName: _controllers[2].text.trim(),
        motherName: _controllers[3].text.trim(),
        nationalId: _controllers[4].text.trim(),
        phoneNumber: _controllers[5].text.trim(),
        reason: _controllers[6].text.trim(),
        identityImagePath: _imagePath!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _DialogFrame(
        title: 'حجز موعد',
        subtitle: 'أدخل بيانات المراجع وحدد الفترة المناسبة',
        maxWidth: 790,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SlotSelector(
                slots: widget.slots,
                value: _slotId,
                onChanged: (value) => setState(() => _slotId = value),
              ),
              const SizedBox(height: 18),
              _ResponsiveFieldRow(children: [
                _bookingField(0),
                _bookingField(1),
              ]),
              const SizedBox(height: 14),
              _ResponsiveFieldRow(children: [
                _bookingField(2),
                _bookingField(3),
              ]),
              const SizedBox(height: 14),
              _ResponsiveFieldRow(children: [
                _bookingField(4, limit: 11),
                _bookingField(5, limit: 10),
              ]),
              const SizedBox(height: 14),
              _bookingField(
                6,
                maxLines: 3,
                hintText: 'اكتب سبب المراجعة باختصار...',
              ),
              const SizedBox(height: 16),
              _IdentityUpload(
                path: _imagePath,
                error: _imageError,
                onPick: _pickImage,
                onRemove: () => setState(() {
                  _imagePath = null;
                  _imageError = null;
                }),
              ),
              const SizedBox(height: 22),
              _DialogActions(
                submitText: 'إرسال طلب الحجز',
                onSubmit: _submit,
              ),
            ],
          ),
        ),
      );

  Widget _bookingField(
    int index, {
    int? limit,
    int maxLines = 1,
    String? hintText,
  }) {
    return AppointmentFormField(
      label: _labels[index],
      controller: _controllers[index],
      keyboardType: limit == null ? null : TextInputType.number,
      inputFormatters: limit == null
          ? null
          : [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(limit),
            ],
      characterLimit: limit,
      maxLines: maxLines,
      hintText: hintText,
      validator: (value) => _validateField(index, value),
    );
  }
}

class AppointmentFormField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? characterLimit;
  final String? Function(String?)? validator;

  const AppointmentFormField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.characterLimit,
    this.validator,
  });

  @override
  State<AppointmentFormField> createState() => _AppointmentFormFieldState();
}

class _AppointmentFormFieldState extends State<AppointmentFormField> {
  final _focus = FocusNode();
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _focus.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant AppointmentFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.readOnly
            ? SystemMouseCursors.click
            : SystemMouseCursors.text,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: AppTextStyles.semiBold,
              ),
            ),
            const SizedBox(height: 7),
            TextFormField(
              controller: widget.controller,
              focusNode: _focus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.maxLines,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.hintText,
                counterText: '',
                filled: true,
                fillColor: _focus.hasFocus
                    ? Colors.white
                    : _hovered
                        ? const Color(0xFFFBFCFB)
                        : const Color(0xFFF8F9F7),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 13,
                ),
                suffixIcon: widget.suffixIcon == null
                    ? null
                    : Icon(widget.suffixIcon, size: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hovered
                        ? AppColors.primary.withValues(alpha: .35)
                        : const Color(0xFFDDE2DF),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.4),
                ),
              ),
            ),
            if (widget.characterLimit != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 3),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          widget.controller.text.length == widget.characterLimit
                              ? AppColors.primary
                              : AppColors.textSecondary.withValues(alpha: .72),
                      fontWeight:
                          widget.controller.text.length == widget.characterLimit
                              ? AppTextStyles.semiBold
                              : AppTextStyles.regular,
                    ),
                    child: Text(
                      '${widget.controller.text.length}/${widget.characterLimit}',
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _ResponsiveFieldRow extends StatelessWidget {
  final List<Widget> children;
  const _ResponsiveFieldRow({required this.children});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          if (constraints.maxWidth < 520) {
            return Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Expanded(child: children[i]),
                if (i < children.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        },
      );
}

class _SlotSelector extends StatelessWidget {
  final List<AppointmentSlot> slots;
  final int? value;
  final ValueChanged<int?> onChanged;
  const _SlotSelector({
    required this.slots,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _Notice(
        text: 'عذراً، لا توجد مواعيد متاحة حالياً.',
        icon: LucideIcons.calendarX2,
      );
    }
    return FormField<int>(
      initialValue: value,
      validator: (selected) => selected == null ? 'اختر موعداً' : null,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الفترة المتاحة',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
          const SizedBox(height: 7),
          DropdownButtonFormField<int>(
            initialValue: value,
            isExpanded: true,
            borderRadius: BorderRadius.circular(14),
            icon: const Icon(LucideIcons.chevronDown, size: 18),
            decoration: InputDecoration(
              prefixIcon: const Icon(LucideIcons.calendarClock, size: 19),
              hintText: 'اختر الفترة المناسبة',
              errorText: field.errorText,
              filled: true,
              fillColor: const Color(0xFFF8F9F7),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFDDE2DF)),
              ),
            ),
            items: slots
                .map((slot) => DropdownMenuItem(
                      value: slot.id,
                      child: Text(
                        '${_arabicDate(slot.appointmentDate)}  •  '
                        '${_shortTime(slot.startTime)} - '
                        '${_shortTime(slot.endTime)}  •  '
                        'المتبقي ${slot.remainingSeats}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (selected) {
              field.didChange(selected);
              onChanged(selected);
            },
          ),
        ],
      ),
    );
  }
}

class _IdentityUpload extends StatelessWidget {
  final String? path;
  final String? error;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  const _IdentityUpload({
    required this.path,
    required this.error,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: error == null ? const Color(0xFFDDE2DF) : AppColors.error,
          ),
        ),
        child: path == null
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.lightPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.imageUp,
                      color: AppColors.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text('إرفاق صورة الهوية',
                      style: AppTextStyles.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    'اختر ملف صورة من جهازك',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 5),
                    Text(error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(LucideIcons.upload, size: 17),
                    label: const Text('اختيار صورة'),
                  ),
                ],
              )
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(path!),
                      width: 62,
                      height: 62,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 62,
                        height: 62,
                        color: AppColors.lightPrimary,
                        child: const Icon(LucideIcons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('تم إرفاق صورة الهوية',
                            style: AppTextStyles.titleSmall),
                        const SizedBox(height: 3),
                        Text(
                          path!.split(Platform.pathSeparator).last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onPick, child: const Text('تغيير')),
                  IconButton(
                    onPressed: onRemove,
                    tooltip: 'إزالة الصورة',
                    color: AppColors.error,
                    icon: const Icon(LucideIcons.trash2, size: 18),
                  ),
                ],
              ),
      );
}

class _BookingSummary extends StatelessWidget {
  final AppointmentSlot slot;
  final AppointmentBooking booking;
  const _BookingSummary({required this.slot, required this.booking});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E6E3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.lightPrimary,
              foregroundColor: AppColors.primary,
              child:
                  Text(booking.firstName.isEmpty ? '؟' : booking.firstName[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.fullName, style: AppTextStyles.titleSmall),
                  const SizedBox(height: 3),
                  Text(
                    '${_arabicDate(slot.appointmentDate)} • '
                    '${_shortTime(slot.startTime)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _DetailsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, String> values;
  const _DetailsSection({
    required this.title,
    required this.icon,
    required this.values,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7EAE8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.titleSmall),
            ]),
            const SizedBox(height: 13),
            ...values.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 112,
                        child: Text(
                          entry.key,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.trim().isEmpty ? '—' : entry.value,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      );
}

class _Notice extends StatelessWidget {
  final String text;
  final IconData icon;
  const _Notice({
    required this.text,
    this.icon = LucideIcons.info,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.goldLight.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: .35)),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: AppColors.goldDark),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ]),
      );
}

class _DialogFrame extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final double maxWidth;
  const _DialogFrame({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * .84;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
          child: Material(
            color: AppColors.surface,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 19, 18, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.headlineMedium),
                            if (subtitle != null) ...[
                              const SizedBox(height: 3),
                              Text(
                                subtitle!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        trailing!,
                        const SizedBox(width: 8),
                      ],
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'إغلاق',
                        icon: const Icon(LucideIcons.x, size: 20),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEF0EE)),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final VoidCallback onSubmit;
  final String submitText;
  final bool destructive;
  const _DialogActions({
    required this.onSubmit,
    required this.submitText,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(112, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(150, 46),
              backgroundColor: destructive ? AppColors.error : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(submitText),
          ),
        ],
      );
}
