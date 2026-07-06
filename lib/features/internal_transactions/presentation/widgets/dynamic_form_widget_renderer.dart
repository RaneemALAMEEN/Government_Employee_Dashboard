import '../../../../shared/theme/app_text_styles.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../domain/entities/dynamic_widget_entity.dart';

class DynamicFormWidgetRenderer extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const DynamicFormWidgetRenderer({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (widgetEntity.widgetType) {
      case 'text_field':
        return _TextFieldWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      case 'dropdown':
        return _DropdownWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      case 'file_picker':
        return _FilePickerWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      case 'date_picker':
        return _DatePickerWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      case 'radio_group':
        return _RadioGroupWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      case 'check_list':
        return _CheckListWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged);
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.goldLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Widget غير مدعوم: ${widgetEntity.widgetType}',
              textAlign: TextAlign.right),
        );
    }
  }
}

String _label(DynamicWidgetEntity e) {
  final label = e.data['label']?.toString() ?? '';
  return e.data['is_required'] == true ? '$label *' : label;
}

class _TextFieldWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _TextFieldWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString(),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      maxLength: widgetEntity.data['max_length'] as int?,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _DropdownWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _DropdownWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value as String?,
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: const OutlineInputBorder(),
      ),
      items: widgetEntity.options
          .map((option) => DropdownMenuItem<String>(
                value: option.key,
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(option.value)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DatePickerWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _DatePickerWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value?.toString() ?? ''),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      onTap: () async {
        final minDate = DateTime.tryParse(
                widgetEntity.data['min_date']?.toString() ?? '') ??
            DateTime(1900);
        final maxDate = DateTime.tryParse(
                widgetEntity.data['max_date']?.toString() ?? '') ??
            DateTime.now();

        final picked = await showDatePicker(
          context: context,
          firstDate: minDate,
          lastDate: maxDate,
          initialDate:
              DateTime.now().isAfter(maxDate) ? maxDate : DateTime.now(),
        );

        if (picked != null) {
          onChanged(picked.toIso8601String().split('T').first);
        }
      },
    );
  }
}

class _RadioGroupWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _RadioGroupWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: const OutlineInputBorder(),
      ),
      child: Column(
        children: widgetEntity.options
            .map((option) => RadioListTile<String>(
                  value: option.key,
                  groupValue: value as String?,
                  onChanged: onChanged,
                  title: Text(option.value, textAlign: TextAlign.right),
                ))
            .toList(),
      ),
    );
  }
}

class _CheckListWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _CheckListWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = value is List ? List<String>.from(value) : <String>[];

    return InputDecorator(
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: const OutlineInputBorder(),
      ),
      child: Column(
        children: widgetEntity.options.map((option) {
          final checked = selected.contains(option.key);

          return CheckboxListTile(
            value: checked,
            onChanged: (isChecked) {
              final updated = [...selected];

              if (isChecked == true) {
                updated.add(option.key);
              } else {
                updated.remove(option.key);
              }

              onChanged(updated);
            },
            title: Text(option.value, textAlign: TextAlign.right),
          );
        }).toList(),
      ),
    );
  }
}

class _FilePickerWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _FilePickerWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final allowMultiple = widgetEntity.data['allow_multiple'] == true;
    final allowedExtensions = (widgetEntity.data['allowed_extensions'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        ['pdf', 'png', 'jpg'];

    final files = value is List ? value : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: allowMultiple,
              type: FileType.custom,
              allowedExtensions: allowedExtensions,
              withData: false,
            );

            if (result != null) {
              onChanged(result.files);
            }
          },
          icon: const Icon(Icons.upload_file),
          label: Text(
            files.isEmpty
                ? _label(widgetEntity)
                : allowMultiple
                    ? 'تم اختيار ${files.length} ملفات'
                    : _fileDisplayName(files.first),
          ),
        ),
        if (files.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...files.map(
            (file) => Text(
              _fileDisplayName(file),
              textAlign: TextAlign.right,
              style:
                  AppTextStyles.labelLarge.copyWith(color: AppColors.goldDark),
            ),
          ),
        ],
      ],
    );
  }

  String _fileDisplayName(dynamic file) {
    if (file is PlatformFile) return file.name;

    if (file is Map) {
      return file['original_name']?.toString() ??
          file['name']?.toString() ??
          file['path']?.toString() ??
          file['url']?.toString() ??
          'ملف مرفق';
    }

    return file?.toString() ?? 'ملف مرفق';
  }
}
