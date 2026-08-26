import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_empty_search_state.dart';
import '../../../../core/di/injection.dart';
import '../../../self_cards/domain/entities/self_card_search_item_entity.dart';
import '../../../self_cards/domain/usecases/search_self_cards_usecase.dart';
import '../../domain/entities/dynamic_widget_entity.dart';
import 'employee_picker_widget.dart';

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
    final key = ValueKey(widgetEntity.data['id']?.toString() ??
        widgetEntity.data['name']?.toString() ??
        widgetEntity.widgetType);

    switch (widgetEntity.widgetType) {
      case 'text_field':
        return _TextFieldWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'dropdown':
        return _DropdownWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'file_picker':
        return _FilePickerWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'employee_picker':
        return EmployeePickerWidget(
          key: key,
          widgetEntity: widgetEntity,
          value: value,
          onChanged: onChanged,
          hasError: hasError,
        );
      case 'date_picker':
        return _DatePickerWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'radio_group':
        return _RadioGroupWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'check_list':
        return _CheckListWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);
      case 'employee_picker':
        return _EmployeePickerWidget(
            key: key,
            widgetEntity: widgetEntity,
            value: value,
            onChanged: onChanged,
            hasError: hasError);

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

class _TextFieldWidget extends StatefulWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _TextFieldWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<_TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<_TextFieldWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _TextFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final incoming = widget.value?.toString() ?? '';
    if (incoming != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: incoming,
        selection: TextSelection.collapsed(offset: incoming.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      textInputAction: TextInputAction.next,
      maxLength: widget.widgetEntity.data['max_length'] as int?,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: _label(widget.widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
                  widget.hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: widget.hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: widget.hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: widget.hasError ? Colors.red.shade50 : Colors.white,
      ),
    );
  }
}

class _DropdownWidget extends StatelessWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _DropdownWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

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

class _DatePickerWidget extends StatefulWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _DatePickerWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<_DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<_DatePickerWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant _DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value?.toString() != oldWidget.value?.toString()) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: _label(widget.widgetEntity),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color:
                  widget.hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: widget.hasError ? 2.0 : 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: widget.hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0),
        ),
        filled: true,
        fillColor: widget.hasError ? Colors.red.shade50 : Colors.white,
        suffixIcon: const Icon(Icons.calendar_month_outlined),
      ),
      onTap: () async {
        final minDate = DateTime.tryParse(
                widget.widgetEntity.data['min_date']?.toString() ?? '') ??
            DateTime(1900);
        final maxDate = DateTime.tryParse(
                widget.widgetEntity.data['max_date']?.toString() ?? '') ??
            DateTime.now();

        final picked = await showDatePicker(
          context: context,
          firstDate: minDate,
          lastDate: maxDate,
          initialDate:
              DateTime.now().isAfter(maxDate) ? maxDate : DateTime.now(),
        );

        if (picked != null) {
          final dateStr = picked.toIso8601String().split('T').first;
          _controller.text = dateStr;
          widget.onChanged(dateStr);
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

  const _RadioGroupWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

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

  const _CheckListWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

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
    super.key,
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
  List<dynamic> _localFiles = [];

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant _FilePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_isUploading) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    if (widget.value == null) {
      _localFiles = [];
    } else if (widget.value is List) {
      _localFiles = List.from(widget.value as List);
    } else {
      _localFiles = [widget.value];
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startUploadProgressSimulation() {
    _progressTimer?.cancel();
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.15;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_uploadProgress < 0.95) {
          _uploadProgress += 0.11;
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

    final files = _localFiles;

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
                setState(() {
                  _localFiles = List.from(result.files);
                });
                widget.onChanged(result.files);
                _startUploadProgressSimulation();
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: _uploadProgress,
                                    color: AppColors.forest,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(_uploadProgress * 100).toInt()}%',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.forest,
                                  ),
                                ),
                              ],
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
                              setState(() {
                                _localFiles.remove(file);
                              });
                              widget.onChanged(
                                  _localFiles.isEmpty ? null : _localFiles);
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
                            backgroundColor: AppColors.forest.withOpacity(0.15),
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
    final label = (widget.widgetEntity.data['label']?.toString() ?? '').trim();
    if (label.isNotEmpty) return label;
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

class _EmployeePickerWidget extends StatefulWidget {
  final DynamicWidgetEntity widgetEntity;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool hasError;

  const _EmployeePickerWidget({
    super.key,
    required this.widgetEntity,
    required this.value,
    required this.onChanged,
    this.hasError = false,
  });

  @override
  State<_EmployeePickerWidget> createState() => _EmployeePickerWidgetState();
}

class _EmployeePickerWidgetState extends State<_EmployeePickerWidget> {
  String _displayText = '';
  int? _selectedId;
  String? _pathSelfCard;

  @override
  void initState() {
    super.initState();
    _resolveValue();
  }

  @override
  void didUpdateWidget(covariant _EmployeePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _resolveValue();
    }
  }

  void _resolveValue() {
    final val = widget.value;
    if (val == null) {
      _selectedId = null;
      _displayText = '';
      _pathSelfCard = null;
      return;
    }

    if (val is Map) {
      final idRaw = val['self_card_id'] ?? val['id'];
      _selectedId = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
      _pathSelfCard = val['path_self_card']?.toString() ?? val['pathSelfCard']?.toString();

      final name = val['full_name']?.toString() ?? val['name']?.toString() ?? val['label']?.toString();
      final selfNum = val['self_number']?.toString();

      if (name != null && name.isNotEmpty) {
        _displayText = selfNum != null && selfNum.isNotEmpty ? '$name ($selfNum)' : name;
      } else if (_selectedId != null) {
        _displayText = 'الموظف المحدد (#$_selectedId)';
      } else {
        _displayText = '';
      }
    } else if (val is int) {
      _selectedId = val;
      _displayText = 'الموظف المحدد (#$val)';
    } else if (val is String && val.isNotEmpty) {
      final parsed = int.tryParse(val);
      if (parsed != null) {
        _selectedId = parsed;
        _displayText = 'الموظف المحدد (#$parsed)';
      } else {
        _displayText = val;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedId != null || _displayText.isNotEmpty;

    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: _label(widget.widgetEntity),
          hintText: 'ابحث عن موظف واختياره من البطاقات الذاتية...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.hasError ? Colors.red.shade700 : Colors.grey.shade400,
              width: widget.hasError ? 2.0 : 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: widget.hasError ? Colors.red.shade700 : AppColors.forest,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: widget.hasError ? Colors.red.shade50 : Colors.white,
          prefixIcon: Tooltip(
            message: _pathSelfCard != null && _pathSelfCard!.isNotEmpty
                ? 'ملف البطاقة: $_pathSelfCard'
                : 'اختيار موظف',
            child: const Icon(LucideIcons.search, color: AppColors.forest, size: 20),
          ),
          suffixIcon: hasSelection
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                  tooltip: 'إلغاء التحديد',
                  onPressed: () {
                    setState(() {
                      _selectedId = null;
                      _displayText = '';
                      _pathSelfCard = null;
                    });
                    widget.onChanged(null);
                  },
                )
              : const Icon(LucideIcons.chevronDown, size: 20, color: Colors.grey),
        ),
        child: Text(
          hasSelection ? _displayText : 'ابحث عن موظف واختياره...',
          style: hasSelection
              ? AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalDark,
                )
              : AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade500,
                ),
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showDialog<SelfCardSearchItemEntity>(
      context: context,
      builder: (ctx) => const _EmployeePickerDialog(),
    );

    if (selected != null) {
      setState(() {
        _selectedId = selected.id;
        _displayText = '${selected.displayName} (${selected.selfNumber ?? selected.nationalId ?? "#${selected.id}"})';
        _pathSelfCard = selected.pathSelfCard;
      });

      final valueMap = <String, dynamic>{
        'self_card_id': selected.id,
        if (selected.pathSelfCard != null && selected.pathSelfCard!.isNotEmpty)
          'path_self_card': selected.pathSelfCard,
        'full_name': selected.fullName,
        if (selected.selfNumber != null) 'self_number': selected.selfNumber,
        if (selected.nationalId != null) 'national_id': selected.nationalId,
      };

      widget.onChanged(valueMap);
    }
  }
}

class _EmployeePickerDialog extends StatefulWidget {
  const _EmployeePickerDialog();

  @override
  State<_EmployeePickerDialog> createState() => _EmployeePickerDialogState();
}

class _EmployeePickerDialogState extends State<_EmployeePickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isLoading = true;
  String? _errorMessage;
  List<SelfCardSearchItemEntity> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchEmployees('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchEmployees(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final searchUseCase = getIt<SearchSelfCardsUseCase>();
      final result = await searchUseCase(
        query: query.trim().isEmpty ? null : query.trim(),
        limit: 30,
        activeOnly: true,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (list) {
          setState(() {
            _isLoading = false;
            _items = list;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ غير متوقع: $e';
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _fetchEmployees(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Container(
        width: 600,
        height: 620,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forest.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.userCheck, color: AppColors.forest, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختيار موظف من السجلات الذاتية',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.charcoalDark,
                        ),
                      ),
                      Text(
                        'ابحث بالاسم، الرقم الوطني، أو الرقم الذاتي للموظف',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.charcoal.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Box
            TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الرقم الذاتي أو الرقم الوطني...',
                prefixIcon: const Icon(LucideIcons.search, color: AppColors.forest, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          _fetchEmployees('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.goldLight.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.forest, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List or Loading / Error State
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.forest),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.alertCircle, color: Colors.red, size: 36),
                              const SizedBox(height: 10),
                              Text(
                                _errorMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.red.shade700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _fetchEmployees(_searchController.text),
                                icon: const Icon(LucideIcons.refreshCw, size: 16),
                                label: const Text('إعادة المحاولة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.forest,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _items.isEmpty
                          ? const AppEmptySearchState(
                              title: 'لم يتم العثور على موظفين مطابقين للبحث',
                              description: 'تأكد من صحة الاسم أو الرقم المدخل وحاول مجدداً.',
                              isCard: false,
                              svgWidth: 90,
                              svgHeight: 90,
                              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            )
                          : ListView.separated(
                              itemCount: _items.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.forest.withValues(alpha: 0.12),
                                    child: const Icon(LucideIcons.user, color: AppColors.forest, size: 20),
                                  ),
                                  title: Text(
                                    item.displayName,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.charcoalDark,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.subtitle.isNotEmpty
                                          ? item.subtitle
                                          : (item.educationDegree ?? 'موظف'),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.charcoal.withValues(alpha: 0.65),
                                      ),
                                    ),
                                  ),
                                  trailing: const Icon(
                                    LucideIcons.chevronLeft,
                                    size: 18,
                                    color: AppColors.forest,
                                  ),
                                  onTap: () => Navigator.of(context).pop(item),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
