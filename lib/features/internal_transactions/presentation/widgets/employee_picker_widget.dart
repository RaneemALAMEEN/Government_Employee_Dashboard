import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_skeleton_loader.dart';
import '../../domain/entities/dynamic_widget_entity.dart';
import '../../domain/entities/self_card_entity.dart';
import '../bloc/employee_picker/employee_picker_bloc.dart';
import '../bloc/employee_picker/employee_picker_event.dart';
import '../bloc/employee_picker/employee_picker_state.dart';

class EmployeePickerWidget extends StatefulWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const EmployeePickerWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<EmployeePickerWidget> createState() => _EmployeePickerWidgetState();
}

class _EmployeePickerWidgetState extends State<EmployeePickerWidget> {
  late final EmployeePickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<EmployeePickerBloc>();
    final id = _asId(widget.value);
    if (id != null) _bloc.add(EmployeePickerValueHydrated(id));
  }

  @override
  void didUpdateWidget(covariant EmployeePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldId = _asId(oldWidget.value);
    final newId = _asId(widget.value);
    if (oldId == newId) return;
    if (newId == null) {
      _bloc.add(const EmployeePickerSelectionCleared());
    } else if (_bloc.state.selectedCard?.id != newId) {
      _bloc.add(EmployeePickerValueHydrated(newId));
    }
  }

  int? _asId(dynamic value) {
    if (value is int && value > 0) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _openPicker() async {
    _bloc.add(const EmployeePickerOpened());
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider.value(
        value: _bloc,
        child: _EmployeeSearchDialog(
          onSelected: (item) {
            _bloc.add(EmployeePickerSelected(item));
            widget.onChanged(item.id);
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
      ),
    );
  }

  void _clearSelection() {
    _bloc.add(const EmployeePickerSelectionCleared());
    widget.onChanged(null);
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.widgetEntity.data['label']?.toString() ?? '';
    final required = widget.widgetEntity.data['is_required'] == true;
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<EmployeePickerBloc, EmployeePickerState>(
        builder: (context, state) {
          final selected = state.selectedCard;
          final hydrating = selected == null &&
              _asId(widget.value) != null &&
              state.detailsStatus == SelfCardDetailsStatus.loading;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                required ? '$label *' : label,
                textAlign: TextAlign.right,
                style: AppTextStyles.labelLarge.copyWith(
                  color:
                      widget.hasError ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected != null
                    ? _SelectedSelfCard(
                        key: ValueKey(selected.id),
                        card: selected,
                        state: state,
                        onChange: _openPicker,
                        onClear: _clearSelection,
                        onPreview: state.selectedDetails == null
                            ? null
                            : () => _showDetailsPreview(
                                  context,
                                  state.selectedDetails!,
                                ),
                        onRetryDetails: () => _bloc.add(
                          const EmployeePickerRetryDetails(),
                        ),
                      )
                    : hydrating
                        ? const _HydratingSelection()
                        : _EmptyEmployeePicker(
                            hasError: widget.hasError,
                            onTap: _openPicker,
                          ),
              ),
              if (state.detailsStatus == SelfCardDetailsStatus.failure &&
                  selected == null) ...[
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      state.detailsError ?? 'تعذر تحميل البطاقة المختارة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        final id = _asId(widget.value);
                        if (id != null) {
                          _bloc.add(EmployeePickerValueHydrated(id));
                        }
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyEmployeePicker extends StatelessWidget {
  final bool hasError;
  final VoidCallback onTap;

  const _EmptyEmployeePicker({
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: hasError
                ? AppColors.error.withValues(alpha: .05)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : AppColors.border.withValues(alpha: .55),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.chevronDown, color: AppColors.primary),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'اختيار بطاقة ذاتية',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'ابحث بالاسم أو الرقم الوطني أو الرقم الذاتي',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.userSearch, color: AppColors.primary),
            ],
          ),
        ),
      );
}

class _HydratingSelection extends StatelessWidget {
  const _HydratingSelection();

  @override
  Widget build(BuildContext context) => Container(
        height: 92,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: .45)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            Spacer(),
            Text('جاري تحميل البطاقة المختارة...'),
          ],
        ),
      );
}

class _SelectedSelfCard extends StatelessWidget {
  final SelfCardEntity card;
  final EmployeePickerState state;
  final VoidCallback onChange;
  final VoidCallback onClear;
  final VoidCallback? onPreview;
  final VoidCallback onRetryDetails;

  const _SelectedSelfCard({
    super.key,
    required this.card,
    required this.state,
    required this.onChange,
    required this.onClear,
    required this.onPreview,
    required this.onRetryDetails,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'إلغاء الاختيار',
                  onPressed: onClear,
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
                const Spacer(),
                Expanded(
                  flex: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        card.fullName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'الرقم الذاتي: ${_display(card.selfNumber)}  •  '
                        'الرقم الوطني: ${_display(card.nationalId)}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    LucideIcons.contactRound,
                    color: AppColors.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 7,
              children: [
                if (state.detailsStatus == SelfCardDetailsStatus.loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    child: SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                if (state.detailsStatus == SelfCardDetailsStatus.failure)
                  TextButton.icon(
                    onPressed: onRetryDetails,
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('إعادة تحميل التفاصيل'),
                  ),
                if (onPreview != null)
                  TextButton.icon(
                    onPressed: onPreview,
                    icon: const Icon(LucideIcons.eye, size: 16),
                    label: const Text('معاينة البطاقة'),
                  ),
                OutlinedButton.icon(
                  onPressed: onChange,
                  icon: const Icon(LucideIcons.repeat2, size: 16),
                  label: const Text('تغيير الاختيار'),
                ),
              ],
            ),
          ],
        ),
      );
}

class _EmployeeSearchDialog extends StatefulWidget {
  final ValueChanged<SelfCardEntity> onSelected;

  const _EmployeeSearchDialog({required this.onSelected});

  @override
  State<_EmployeeSearchDialog> createState() => _EmployeeSearchDialogState();
}

class _EmployeeSearchDialogState extends State<_EmployeeSearchDialog> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<EmployeePickerBloc>();
    _searchController = TextEditingController(text: bloc.state.query);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter <= 220) {
      context.read<EmployeePickerBloc>().add(const EmployeePickerLoadMore());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 650),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.userSearch,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اختيار البطاقة الذاتية',
                              style: AppTextStyles.titleLarge,
                            ),
                            Text(
                              'ابحث بالاسم أو الرقم الوطني أو الرقم الذاتي',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    textDirection: TextDirection.rtl,
                    onChanged: (value) => context
                        .read<EmployeePickerBloc>()
                        .add(EmployeePickerQueryChanged(value)),
                    decoration: InputDecoration(
                      hintText: 'اكتب حرفين على الأقل للبحث',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon:
                          BlocBuilder<EmployeePickerBloc, EmployeePickerState>(
                        buildWhen: (previous, current) =>
                            previous.query != current.query,
                        builder: (context, state) => state.query.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                tooltip: 'مسح البحث',
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<EmployeePickerBloc>().add(
                                        const EmployeePickerQueryChanged(''),
                                      );
                                },
                                icon: const Icon(LucideIcons.x, size: 18),
                              ),
                      ),
                      filled: true,
                      fillColor: AppColors.lightPrimary.withValues(alpha: .55),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: BlocBuilder<EmployeePickerBloc, EmployeePickerState>(
                      builder: (context, state) => _SearchResults(
                        state: state,
                        controller: _scrollController,
                        onSelected: widget.onSelected,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _SearchResults extends StatelessWidget {
  final EmployeePickerState state;
  final ScrollController controller;
  final ValueChanged<SelfCardEntity> onSelected;

  const _SearchResults({
    required this.state,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (state.query.length == 1) {
      return const _PickerMessage(
        icon: LucideIcons.textCursorInput,
        title: 'أدخل حرفاً إضافياً للبحث',
      );
    }
    if (state.searchInitialLoading) return const _SearchSkeleton();
    if (state.searchStatus == SelfCardSearchStatus.failure) {
      return _PickerMessage(
        icon: LucideIcons.triangleAlert,
        title: 'تعذر تحميل البطاقات الذاتية',
        message: state.searchError,
        onRetry: () => context
            .read<EmployeePickerBloc>()
            .add(const EmployeePickerRetrySearch()),
      );
    }
    if (state.searchStatus == SelfCardSearchStatus.empty) {
      return const _PickerMessage(
        icon: LucideIcons.searchX,
        title: 'لا توجد نتائج مطابقة',
        message: 'جرّب اسماً أو رقماً وطنياً أو رقماً ذاتياً مختلفاً.',
      );
    }
    if (state.items.isEmpty) {
      return const _PickerMessage(
        icon: LucideIcons.userSearch,
        title: 'ابحث عن بطاقة ذاتية',
      );
    }

    return ListView.separated(
      controller: controller,
      itemCount: state.items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          if (state.searchLoadingMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            );
          }
          if (state.loadMoreError != null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => context
                      .read<EmployeePickerBloc>()
                      .add(const EmployeePickerRetrySearch()),
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('تعذر تحميل المزيد - إعادة المحاولة'),
                ),
              ),
            );
          }
          return const SizedBox(height: 8);
        }
        final item = state.items[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelected(item),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: .35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.chevronLeft,
                      color: AppColors.primary, size: 19),
                  const Spacer(),
                  Expanded(
                    flex: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.fullName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'الرقم الذاتي: ${_display(item.selfNumber)}  •  '
                          'الرقم الوطني: ${_display(item.nationalId)}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.primary,
                    child: Text(_initials(item.fullName)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) => ListView.separated(
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, __) => const CustomSkeletonLoader(
          width: double.infinity,
          height: 72,
          borderRadius: 10,
        ),
      );
}

class _PickerMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  const _PickerMessage({
    required this.icon,
    required this.title,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 5),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      );
}

Future<void> _showDetailsPreview(
  BuildContext context,
  SelfCardDetailsEntity details,
) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 680),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.contactRound,
                          color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          details.fullName,
                          style: AppTextStyles.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _DetailValue('الرقم الذاتي', details.selfNumber),
                          _DetailValue('الرقم الوطني', details.nationalId),
                          _DetailValue(
                              'الرقم التأميني', details.insuranceNumber),
                          _DetailValue('اسم الأب', details.fatherName),
                          _DetailValue('اسم الأم', details.motherName),
                          _DetailValue('مكان الولادة', details.birthPlace),
                          _DetailValue('تاريخ الولادة', details.birthDate),
                          _DetailValue('محل القيد', details.registryPlace),
                          _DetailValue('رقم القيد', details.registryNumber),
                          _DetailValue('الجنس', details.gender),
                          _DetailValue('الجنسية', details.nationality),
                          _DetailValue(
                              'اللغة الأجنبية', details.foreignLanguage),
                          _DetailValue(
                              'المؤهل العلمي', details.educationDegree),
                          _DetailValue(
                              'الإقامة الحالية', details.currentResidence),
                          _DetailValue('الدورات التدريبية',
                              '${details.trainingCourses.length} سجل'),
                          _DetailValue('التاريخ الوظيفي',
                              '${details.employmentStatuses.length} سجل'),
                          _DetailValue('الغياب غير الأصولي',
                              '${details.irregularAbsences.length} سجل'),
                          _DetailValue(
                              'الإجازات', '${details.leaves.length} سجل'),
                          _DetailValue(
                              'المكافآت', '${details.rewards.length} سجل'),
                          _DetailValue(
                              'العقوبات', '${details.sanctions.length} سجل'),
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

class _DetailValue extends StatelessWidget {
  final String label;
  final String value;

  const _DetailValue(this.label, this.value);

  @override
  Widget build(BuildContext context) => Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(_display(value), style: AppTextStyles.bodyMedium),
          ],
        ),
      );
}

String _display(String value) => value.trim().isEmpty ? '-' : value;

String _initials(String name) {
  final parts = name.split(' ').where((part) => part.isNotEmpty).take(2);
  return parts.map((part) => part.characters.first).join();
}
