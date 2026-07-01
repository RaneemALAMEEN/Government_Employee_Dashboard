import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/models/file_info.dart';

/// Large drop-zone for uploading images / PDFs.
class UploadWidget extends StatefulWidget {
  final ValueChanged<UploadedFileInfo> onFileSelected;

  const UploadWidget({super.key, required this.onFileSelected});

  @override
  State<UploadWidget> createState() => _UploadWidgetState();
}

class _UploadWidgetState extends State<UploadWidget> {
  bool _isDragging = false;
  String? _errorMessage;

  static const _allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  // ── Browse ───────────────────────────────────────────────────
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExtensions,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final ext = file.extension?.toLowerCase() ?? '';

      if (!_allowedExtensions.contains(ext)) {
        setState(() => _errorMessage = 'نوع الملف غير مدعوم');
        return;
      }

      setState(() => _errorMessage = null);

      widget.onFileSelected(UploadedFileInfo(
        name: file.name,
        extension: ext,
        sizeInBytes: file.size,
        uploadedAt: DateTime.now(),
        bytes: file.bytes ?? Uint8List(0),
      ));
    }
  }

  // ── Drag & Drop ──────────────────────────────────────────────
  void _onDragEntered(DropEventDetails details) {
    setState(() => _isDragging = true);
  }

  void _onDragExited(DropEventDetails details) {
    setState(() => _isDragging = false);
  }

  void _onDragDone(DropDoneDetails details) async {
    setState(() => _isDragging = false);

    if (details.files.isEmpty) return;

    final xFile = details.files.first;
    final name = xFile.name;
    final ext = name.split('.').last.toLowerCase();

    if (!_allowedExtensions.contains(ext)) {
      setState(() => _errorMessage = 'Unsupported File Type');
      return;
    }

    setState(() => _errorMessage = null);

    final bytes = await xFile.readAsBytes();

    widget.onFileSelected(UploadedFileInfo(
      name: name,
      extension: ext,
      sizeInBytes: bytes.length,
      uploadedAt: DateTime.now(),
      bytes: bytes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: DropTarget(
        onDragEntered: _onDragEntered,
        onDragExited: _onDragExited,
        onDragDone: _onDragDone,
        child: GestureDetector(
          onTap: _pickFile,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: _isDragging
                    ? AppColors.forest.withOpacity(0.06)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDragging
                      ? AppColors.forest
                      : _errorMessage != null
                          ? AppColors.umber
                          : AppColors.gold.withOpacity(0.30),
                  width: _isDragging ? 2 : 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _isDragging
                          ? AppColors.forest.withOpacity(0.12)
                          : AppColors.forestLight.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.uploadCloud,
                      size: 40,
                      color: _isDragging ? AppColors.forest : AppColors.forestLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'اسحب الملف هنا أو اضغط للاختيار',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _isDragging ? AppColors.forest : AppColors.charcoalDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'JPG, JPEG, PNG, PDF',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.goldDark,
                      letterSpacing: 1,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.umber.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        textDirection: TextDirection.ltr,
                        children: [
                          const Icon(LucideIcons.alertTriangle,
                              size: 16, color: AppColors.umber),
                          const SizedBox(width: 8),
                          Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.umber,
                              fontWeight: AppTextStyles.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
