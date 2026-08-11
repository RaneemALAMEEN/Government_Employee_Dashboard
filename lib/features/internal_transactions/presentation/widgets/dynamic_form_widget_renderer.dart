import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/entities/dynamic_widget_entity.dart';

class DynamicFormWidgetRenderer extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const DynamicFormWidgetRenderer({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (widgetEntity.widgetType) {
      case 'text_field':
        return _TextFieldWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      case 'dropdown':
        return _DropdownWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      case 'file_picker':
        return _FilePickerWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      case 'date_picker':
        return _DatePickerWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      case 'radio_group':
        return _RadioGroupWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      case 'check_list':
        return _CheckListWidget(
            widgetEntity: widgetEntity, value: value, onChanged: onChanged, hasError: hasError);
      default:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasError ? Colors.red.shade50 : Colors.white,
            border: Border.all(
                color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
                width: hasError ? 2.0 : 1.2),
            borderRadius: BorderRadius.circular(8),
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
  final bool hasError;

  const _TextFieldWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged,
      this.hasError = false});

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
      ),
    );
  }
}

class _DropdownWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _DropdownWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged,
      this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value as String?,
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
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
  final bool hasError;

  const _DatePickerWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged,
      this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value?.toString() ?? ''),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
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
  final bool hasError;

  const _RadioGroupWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged,
      this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
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
      ),
    );
  }
}

class _CheckListWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _CheckListWidget(
      {required this.widgetEntity,
      required this.value,
      required this.onChanged,
      this.hasError = false});

  @override
  Widget build(BuildContext context) {
    final selected = value is List ? List<String>.from(value) : <String>[];

    return InputDecorator(
      decoration: InputDecoration(
        labelText: _label(widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: hasError ? Colors.red.shade50 : Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
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
      ),
    );
  }
}

class _FilePickerWidget extends StatefulWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _FilePickerWidget({
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<_FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<_FilePickerWidget> {
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  Timer? _progressTimer;

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startUploadProgressSimulation(dynamic selectedFiles) {
    _progressTimer?.cancel();
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.15;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 120), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_uploadProgress < 0.95) {
          _uploadProgress += 0.12;
        } else {
          _uploadProgress = 1.0;
          _isUploading = false;
          timer.cancel();
        }
      });
    });
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final allowMultiple = widget.widgetEntity.data['allow_multiple'] == true;
    final allowedExtensions =
        (widget.widgetEntity.data['allowed_extensions'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            ['pdf', 'png', 'jpg', 'jpeg'];

    final files = widget.value is List ? widget.value as List : const [];

    return Container(
      decoration: BoxDecoration(
        color: widget.hasError ? Colors.red.shade50 : Colors.transparent,
        border: widget.hasError
            ? Border.all(color: Colors.red.shade700, width: 1.5)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: widget.hasError ? const EdgeInsets.all(8) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              side: BorderSide(
                color: widget.hasError
                    ? Colors.red.shade700
                    : AppColors.gold.withOpacity(0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                allowMultiple: allowMultiple,
                type: FileType.custom,
                allowedExtensions: allowedExtensions,
                withData: false,
              );

              if (result != null && result.files.isNotEmpty) {
                widget.onChanged(result.files);
                _startUploadProgressSimulation(result.files);
              }
            },
            icon: const Icon(LucideIcons.uploadCloud, color: AppColors.forest),
            label: Text(
              files.isEmpty
                  ? _label(widget.widgetEntity)
                  : allowMultiple
                      ? 'اخترت ${files.length} ملفات — اضغط للتبديل'
                      : 'تغيير الملف المرفق',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalDark,
              ),
            ),
          ),
          if (files.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...files.map((file) {
              final name = _fileDisplayName(file);
              final ext = name.split('.').last.toLowerCase();
              final isImage =
                  ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
              final sizeBytes = file is PlatformFile ? file.size : 0;
              final sizeText = _formatSize(sizeBytes);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isUploading
                          ? AppColors.forest.withOpacity(0.5)
                          : AppColors.gold.withOpacity(0.25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isImage
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFFDEEEF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isImage
                                  ? LucideIcons.image
                                  : LucideIcons.fileText,
                              color: isImage
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFFC62828),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.charcoalDark,
                                  ),
                                ),
                                if (sizeText.isNotEmpty)
                                  Text(
                                    sizeText,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color:
                                          AppColors.charcoal.withOpacity(0.6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_isUploading)
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.forest,
                              ),
                            )
                          else
                            const Icon(
                              LucideIcons.checkCircle2,
                              color: AppColors.forest,
                              size: 18,
                            ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2,
                                size: 16, color: Colors.red),
                            tooltip: 'حذف الملف',
                            onPressed: () {
                              final updated = [...files];
                              updated.remove(file);
                              widget.onChanged(updated);
                            },
                          ),
                        ],
                      ),
                      if (_isUploading) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            minHeight: 6,
                            backgroundColor:
                                AppColors.forest.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.forest),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
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
