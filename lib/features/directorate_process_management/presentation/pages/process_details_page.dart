import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/process_details_entity.dart';
import '../bloc/process_details_bloc.dart';
import '../bloc/process_details_event.dart';
import '../bloc/process_details_state.dart';

class ProcessDetailsPage extends StatelessWidget {
  final int processId;

  const ProcessDetailsPage({super.key, required this.processId});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: AppColors.background,
          child: BlocBuilder<ProcessDetailsBloc, ProcessDetailsState>(
            builder: (context, state) => CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 14),
                  sliver: SliverToBoxAdapter(child: _BackButton()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                  sliver: SliverToBoxAdapter(
                    child: _body(context, state),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _body(BuildContext context, ProcessDetailsState state) {
    if (state is ProcessDetailsInitial || state is ProcessDetailsLoading) {
      return const _DetailsSkeleton();
    }
    if (state is ProcessDetailsError) {
      return _MessageState(
        icon: LucideIcons.triangleAlert,
        title: 'تعذر جلب تفاصيل العملية',
        message: state.message,
        isError: true,
        onRetry: () => context
            .read<ProcessDetailsBloc>()
            .add(LoadProcessDetails(processId: processId)),
      );
    }
    if (state is ProcessDetailsLoaded) {
      if (state.details.isEmpty) {
        return const _MessageState(
          icon: LucideIcons.inbox,
          title: 'لا توجد تفاصيل متاحة لهذه العملية',
        );
      }
      return _DetailsContent(details: state.details);
    }
    return const _MessageState(
      icon: LucideIcons.inbox,
      title: 'لا توجد تفاصيل متاحة لهذه العملية',
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: context.canPop() ? () => context.pop() : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.arrowRight,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'العودة إلى القوالب',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _DetailsContent extends StatelessWidget {
  final ProcessDetailsEntity details;

  const _DetailsContent({required this.details});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProcessHero(process: details.process),
          const SizedBox(height: 18),
          _ProcessInformation(process: details.process),
          const SizedBox(height: 22),
          Row(
            children: [
              const Icon(
                LucideIcons.workflow,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'مراحل العملية',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              _CountBadge(count: details.stages.length),
            ],
          ),
          const SizedBox(height: 14),
          if (details.stages.isEmpty)
            const _InlineEmpty(message: 'لا توجد مراحل مرتبطة بهذه العملية')
          else
            ...details.stages.asMap().entries.map(
                  (entry) => _StageTimelineItem(
                    index: entry.key,
                    stage: entry.value,
                    isLast: entry.key == details.stages.length - 1,
                  ),
                ),
          const SizedBox(height: 22),
          _ValidationCard(validation: details.validation),
        ],
      );
}

class _ProcessHero extends StatelessWidget {
  final ProcessInfoEntity process;

  const _ProcessHero({required this.process});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final compact = constraints.maxWidth < 720;
            final title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  process.name,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.surface,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'تعريف سير المعاملة ومراحلها',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.surface.withValues(alpha: .78),
                  ),
                ),
              ],
            );
            final chips = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HeroChip(text: _deploymentLabel(process.status)),
                _HeroChip(text: _approvalLabel(process.approvalStatus)),
                _HeroChip(text: process.isActive ? 'فعالة' : 'غير فعالة'),
              ],
            );
            return compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [title, const SizedBox(height: 18), chips],
                  )
                : Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 24),
                      chips,
                    ],
                  );
          },
        ),
      );
}

class _HeroChip extends StatelessWidget {
  final String text;

  const _HeroChip({required this.text});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.surface.withValues(alpha: .24),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _ProcessInformation extends StatelessWidget {
  final ProcessInfoEntity process;

  const _ProcessInformation({required this.process});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Info('الاسم', process.name, LucideIcons.fileText),
      _Info('تاريخ البداية', _formatDate(process.startDate),
          LucideIcons.calendar),
      _Info('تاريخ النهاية', _formatDate(process.endDate),
          LucideIcons.calendarClock),
      _Info('حالة النشر', _deploymentLabel(process.status),
          LucideIcons.uploadCloud),
      _Info('حالة الاعتماد', _approvalLabel(process.approvalStatus),
          LucideIcons.badgeCheck),
      _Info('حالة العملية', process.isActive ? 'فعالة' : 'غير فعالة',
          LucideIcons.activity),
    ];
    return _SectionCard(
      title: 'معلومات العملية',
      icon: LucideIcons.info,
      child: LayoutBuilder(
        builder: (_, constraints) {
          final columns = constraints.maxWidth >= 1050
              ? 4
              : constraints.maxWidth >= 620
                  ? 2
                  : 1;
          final width = (constraints.maxWidth - (columns - 1) * 9) / columns;
          return Wrap(
            spacing: 9,
            runSpacing: 9,
            children: items
                .map((item) =>
                    SizedBox(width: width, child: _InfoTile(item: item)))
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _StageTimelineItem extends StatelessWidget {
  final int index;
  final ProcessStageEntity stage;
  final bool isLast;

  const _StageTimelineItem({
    required this.index,
    required this.stage,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isLast)
            Positioned(
              right: 12.5,
              top: 47,
              bottom: -10,
              child: Container(
                width: 1,
                color: AppColors.border.withValues(alpha: .28),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 26,
                child: Padding(
                  padding: const EdgeInsets.only(top: 21),
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: _StageCard(stage: stage),
                ),
              ),
            ],
          ),
        ],
      );
}

class _StageCard extends StatelessWidget {
  final ProcessStageEntity stage;

  const _StageCard({required this.stage});

  @override
  Widget build(BuildContext context) => _SectionCard(
        title: _stageDisplayName(stage),
        icon: _isServiceTask(stage) ? LucideIcons.bot : LucideIcons.gitBranch,
        padding: 15,
        contentGap: 11,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SoftChip(label: _stageTypeLabel(stage.type)),
                if (stage.authType.trim().isNotEmpty)
                  _SoftChip(label: _authTypeLabel(stage.authType)),
                if (stage.config.requiresDigitalSignature)
                  const _SoftChip(label: 'تتطلب توقيعاً رقمياً'),
              ],
            ),
            _CompactResponsibility(stage: stage),
            if (_isServiceTask(stage)) ...[
              const SizedBox(height: 11),
              _AutomationPanel(stage: stage),
            ] else if (stage.config.widgets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'الحقول المطلوبة',
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(width: 8),
                  _FieldsCountBadge(count: stage.config.widgets.length),
                  if (stage.config.formName.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        stage.config.formName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 7),
              _FieldsGrid(widgets: stage.config.widgets),
            ],
          ],
        ),
      );
}

class _CompactResponsibility extends StatelessWidget {
  final ProcessStageEntity stage;

  const _CompactResponsibility({required this.stage});

  @override
  Widget build(BuildContext context) {
    if (stage.assignments.isEmpty) {
      final label = _responsibilityLabel(stage.authType);
      if (label == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 9),
        child: _ResponsibilityLine(title: 'المسؤول: $label'),
      );
    }
    final items = stage.assignments
        .where((assignment) => assignment.role.name.trim().isNotEmpty)
        .toList(growable: false);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary.withValues(alpha: .26),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: AppColors.border.withValues(alpha: .18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items.map((assignment) {
            final role = assignment.role;
            final location = [
              role.organization.name.trim(),
              role.department.name.trim(),
            ].where((value) => value.isNotEmpty).join(' – ');
            return _ResponsibilityLine(
              title: 'المسؤول: ${role.name.trim()}',
              subtitle: location,
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _ResponsibilityLine extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ResponsibilityLine({required this.title, this.subtitle = ''});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              LucideIcons.userRoundCog,
              color: AppColors.primary,
              size: 15,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
}

class _FieldsGrid extends StatelessWidget {
  final List<ProcessFormWidgetEntity> widgets;

  const _FieldsGrid({required this.widgets});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) {
          final columns = constraints.maxWidth >= 1050
              ? 3
              : constraints.maxWidth >= 650
                  ? 2
                  : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widgets
                .map(
                  (widget) => SizedBox(
                    width: width,
                    child: _FieldPreview(field: widget),
                  ),
                )
                .toList(growable: false),
          );
        },
      );
}

class _FieldPreview extends StatelessWidget {
  final ProcessFormWidgetEntity field;

  const _FieldPreview({required this.field});

  @override
  Widget build(BuildContext context) {
    final type = field.widgetType.toLowerCase();
    final supported = const {
      'text_field',
      'dropdown',
      'check_list',
      'date_picker',
      'file_picker',
    }.contains(type);
    final data = field.data;
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withValues(alpha: .32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: .24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(
                  _fieldIcon(type),
                  color: AppColors.primary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label.trim().isEmpty ? 'حقل بدون عنوان' : data.label,
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      supported
                          ? '${_widgetTypeLabel(type)} • ${data.isRequired ? 'مطلوب' : 'اختياري'}'
                          : 'حقل غير مدعوم',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: supported
                            ? AppColors.textSecondary
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!supported)
            Text(
              'هذا الحقل غير متاح للمعاينة حالياً',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            _FieldDetails(type: type, data: data),
        ],
      ),
    );
  }
}

class _FieldDetails extends StatelessWidget {
  final String type;
  final ProcessWidgetDataEntity data;

  const _FieldDetails({required this.type, required this.data});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'dropdown':
        return _OptionsPreview(options: data.options, checklist: false);
      case 'check_list':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (data.minSelections != null || data.maxSelections != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _selectionRange(data.minSelections, data.maxSelections),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            _OptionsPreview(options: data.options, checklist: true),
          ],
        );
      case 'date_picker':
        return _Lines(
          values: [
            if (data.minDate != null) 'من ${_formatDate(data.minDate)}',
            if (data.maxDate != null) 'إلى ${_formatDate(data.maxDate)}',
          ],
          emptyText: 'تاريخ قابل للاختيار ضمن النموذج',
        );
      case 'file_picker':
        return _Lines(
          values: [
            if (data.allowedExtensions.isNotEmpty)
              'الأنواع المسموحة: ${data.allowedExtensions.map((value) => value.toUpperCase()).join('، ')}',
            if (data.maxSizeMb != null)
              'الحجم الأقصى: ${_number(data.maxSizeMb!)} MB',
            data.allowMultiple ? 'يسمح بعدة ملفات' : 'ملف واحد فقط',
          ],
        );
      default:
        return _Lines(
          values: [_textLengthLabel(data)],
          emptyText: 'نص',
        );
    }
  }
}

class _OptionsPreview extends StatelessWidget {
  final List<ProcessOptionEntity> options;
  final bool checklist;

  const _OptionsPreview({required this.options, required this.checklist});

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Text(
        'لم تُحدد خيارات للعرض',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: options
          .map(
            (option) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: .28),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (checklist) ...[
                    const Icon(
                      LucideIcons.square,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(option.displayLabel, style: AppTextStyles.labelLarge),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _Lines extends StatelessWidget {
  final List<String> values;
  final String? emptyText;

  const _Lines({required this.values, this.emptyText});

  @override
  Widget build(BuildContext context) {
    final visible = values.where((value) => value.trim().isNotEmpty).toList();
    if (visible.isEmpty) {
      return Text(
        emptyText ?? 'لا توجد تفاصيل إضافية',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: visible
          .map(
            (value) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _AutomationPanel extends StatelessWidget {
  final ProcessStageEntity stage;

  const _AutomationPanel({required this.stage});

  @override
  Widget build(BuildContext context) {
    final config = stage.config;
    final fallbackAction = _knownActionLabel(stage.code);
    final generatesPdf = fallbackAction == 'توليد PDF' ||
        config.actions.any(
          (action) => _knownActionLabel(action.code) == 'توليد PDF',
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: .16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.bot, color: AppColors.primary, size: 21),
              SizedBox(width: 9),
              Text('مهمة آلية', style: AppTextStyles.titleSmall),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            generatesPdf
                ? 'يتم إنشاء المستند النهائي تلقائياً'
                : 'إجراء آلي ينفذه النظام تلقائياً',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (config.actions.isNotEmpty && !generatesPdf) ...[
            const SizedBox(height: 10),
            ...config.actions.map(
              (action) => Text(
                'الإجراء: ${_actionLabel(action)}',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
          if (config.actions.isEmpty && fallbackAction != null) ...[
            const SizedBox(height: 10),
            Text(
              'الإجراء: $fallbackAction',
              style: AppTextStyles.bodyMedium,
            ),
          ],
          if (config.templates.any(
            (template) => template.name.trim().isNotEmpty,
          )) ...[
            const SizedBox(height: 8),
            ...config.templates
                .where((template) => template.name.trim().isNotEmpty)
                .map(
                  (template) => Text(
                    'قالب المستند: ${template.name}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _ValidationCard extends StatelessWidget {
  final ProcessValidationEntity validation;

  const _ValidationCard({required this.validation});

  @override
  Widget build(BuildContext context) {
    final color = validation.isValid ? AppColors.primary : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                validation.isValid
                    ? LucideIcons.circleCheck
                    : LucideIcons.triangleAlert,
                color: color,
                size: 23,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  validation.isValid
                      ? 'العملية سليمة وجاهزة للاستخدام'
                      : 'توجد مشاكل في إعداد العملية',
                  style: AppTextStyles.titleMedium.copyWith(color: color),
                ),
              ),
            ],
          ),
          if (!validation.isValid && validation.errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...validation.errors.map(
              (error) => Container(
                margin: const EdgeInsets.only(top: 7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.circleAlert,
                        color: AppColors.error, size: 17),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _validationErrorLabel(error),
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final double padding;
  final double contentGap;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.padding = 20,
    this.contentGap = 18,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: .035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: AppTextStyles.titleMedium)),
              ],
            ),
            SizedBox(height: contentGap),
            child,
          ],
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final _Info item;

  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary.withValues(alpha: .38),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _available(item.value),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Info {
  final String label;
  final String value;
  final IconData icon;

  const _Info(this.label, this.value, this.icon);
}

class _SoftChip extends StatelessWidget {
  final String label;

  const _SoftChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: .24)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _FieldsCountBadge extends StatelessWidget {
  final int count;

  const _FieldsCountBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$count ${count == 1 ? 'حقل' : 'حقول'}',
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _InlineEmpty extends StatelessWidget {
  final String message;

  const _InlineEmpty({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: .22)),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final bool isError;
  final VoidCallback? onRetry;

  const _MessageState({
    required this.icon,
    required this.title,
    this.message,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 420),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: .3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: isError ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.titleMedium),
            if (message?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 7),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw, size: 17),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      );
}

class _DetailsSkeleton extends StatefulWidget {
  const _DetailsSkeleton();

  @override
  State<_DetailsSkeleton> createState() => _DetailsSkeletonState();
}

class _DetailsSkeletonState extends State<_DetailsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Opacity(
          opacity: .55 + (_controller.value * .35),
          child: child,
        ),
        child: Column(
          children: [
            _box(130),
            const SizedBox(height: 18),
            _box(250),
            const SizedBox(height: 18),
            _box(300),
            const SizedBox(height: 16),
            _box(220),
          ],
        ),
      );

  Widget _box(double height) => Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: .25)),
        ),
      );
}

String _available(String value) => value.trim().isEmpty ? 'غير متوفر' : value;

String _formatDate(DateTime? value) {
  if (value == null) return 'غير محدد';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String _deploymentLabel(String value) {
  switch (value.toUpperCase()) {
    case 'DEPLOYED':
      return 'منشورة';
    case 'DRAFT':
      return 'مسودة';
    default:
      return _available(value);
  }
}

String _approvalLabel(String value) {
  switch (value.toUpperCase()) {
    case 'APPROVED':
      return 'معتمدة';
    case 'PENDING':
      return 'قيد المراجعة';
    case 'REJECTED':
      return 'مرفوضة';
    default:
      return _available(value);
  }
}

String _stageTypeLabel(String value) {
  switch (value.toUpperCase()) {
    case 'USER_TASK':
      return 'مهمة مستخدم';
    case 'SERVICE_TASK':
      return 'مهمة نظام';
    case 'AUTH':
      return 'مرحلة تسجيل دخول';
    case 'APPROVAL':
      return 'اعتماد';
    case 'REVIEW':
      return 'مراجعة';
    default:
      return _available(value);
  }
}

String _authTypeLabel(String value) {
  switch (value.toUpperCase()) {
    case 'AUTH':
      return 'تتطلب تسجيل دخول';
    case 'NOAUTH':
      return 'لا تتطلب تسجيل دخول';
    case 'CITIZEN':
      return 'وصول المواطن';
    case 'EMPLOYEE':
      return 'موظف';
    case 'ADMIN':
      return 'مدير نظام';
    default:
      return _available(value);
  }
}

bool _isServiceTask(ProcessStageEntity stage) =>
    stage.type.toUpperCase() == 'SERVICE_TASK';

String _stageDisplayName(ProcessStageEntity stage) {
  final name = stage.name.trim();
  final knownAction = _knownActionLabel(name) ?? _knownActionLabel(stage.code);
  if (knownAction == 'توليد PDF') return 'توليد ملف PDF';
  if (knownAction != null) return knownAction;
  if (name.isEmpty) return _isServiceTask(stage) ? 'مهمة آلية' : 'مرحلة معالجة';

  final looksTechnical =
      RegExp(r'^Activity_', caseSensitive: false).hasMatch(name) ||
          RegExp(r'^[A-Z0-9_]+$').hasMatch(name);
  if (looksTechnical) {
    return _isServiceTask(stage) ? 'مهمة آلية' : 'مرحلة معالجة';
  }
  return name;
}

String? _responsibilityLabel(String value) {
  switch (value.toUpperCase()) {
    case 'CITIZEN':
      return 'مواطن';
    case 'EMPLOYEE':
      return 'موظف';
    case 'ADMIN':
      return 'مدير نظام';
    default:
      return null;
  }
}

String _widgetTypeLabel(String value) {
  switch (value) {
    case 'text_field':
      return 'نص';
    case 'dropdown':
      return 'قائمة اختيار';
    case 'check_list':
      return 'اختيارات متعددة';
    case 'date_picker':
      return 'تاريخ';
    case 'file_picker':
      return 'رفع ملف';
    default:
      return 'حقل غير مدعوم';
  }
}

IconData _fieldIcon(String value) {
  switch (value) {
    case 'dropdown':
      return LucideIcons.listFilter;
    case 'check_list':
      return LucideIcons.listChecks;
    case 'date_picker':
      return LucideIcons.calendarDays;
    case 'file_picker':
      return LucideIcons.paperclip;
    case 'text_field':
      return LucideIcons.textCursorInput;
    default:
      return LucideIcons.circleHelp;
  }
}

String _selectionRange(int? min, int? max) {
  if (min != null && max != null) return 'اختر من $min إلى $max';
  if (min != null) return 'اختر $min على الأقل';
  return 'اختر حتى $max';
}

String _textLengthLabel(ProcessWidgetDataEntity data) {
  final min = data.minLength;
  final max = data.maxLength;
  if (min == null && max == null) return '';
  final inputType = data.inputType.toLowerCase();
  final label = data.label.toLowerCase();
  final unit = inputType.contains('number') ||
          inputType.contains('phone') ||
          inputType.contains('tel') ||
          label.contains('هاتف') ||
          label.contains('رقم')
      ? 'أرقام'
      : 'أحرف';
  if (min != null && max != null && min == max) return '$min $unit';
  if (min != null && max != null) return 'من $min إلى $max $unit';
  if (min != null) return 'من $min $unit';
  return 'حتى $max $unit';
}

String _number(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';

String _actionLabel(ProcessActionEntity action) {
  final value = action.code.trim().isNotEmpty ? action.code : action.name;
  return _knownActionLabel(value) ?? 'إجراء آلي';
}

String? _knownActionLabel(String value) {
  switch (value.toUpperCase()) {
    case 'GENERATE_PDF':
      return 'توليد PDF';
    case 'SEND_NOTIFICATION':
      return 'إرسال إشعار';
    case 'SEND_EMAIL':
      return 'إرسال بريد إلكتروني';
    default:
      return null;
  }
}

String _validationErrorLabel(String error) {
  final value = error.toLowerCase();
  if (value.contains('form_id') || value.contains('form id')) {
    return 'لم يتم ربط النموذج المطلوب بالمرحلة';
  }
  if (value.contains('widget') || value.contains('field')) {
    return 'يوجد حقل غير مكتمل الإعداد في إحدى المراحل';
  }
  if (value.contains('assignment') || value.contains('role')) {
    return 'لم يتم تحديد الجهة أو الدور المسؤول عن إحدى المراحل';
  }
  if (value.contains('template')) {
    return 'لم يتم تحديد قالب المستند المطلوب';
  }
  return error;
}
