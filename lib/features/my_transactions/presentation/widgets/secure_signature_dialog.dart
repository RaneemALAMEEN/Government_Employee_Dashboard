import '../../../../shared/theme/app_text_styles.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:file_picker/file_picker.dart';
import 'package:pinput/pinput.dart';
import '../../../../shared/theme/app_colors.dart';

class SecureSignatureDialog extends StatefulWidget {
  final String transactionNumber;

  const SecureSignatureDialog({
    super.key,
    required this.transactionNumber,
  });

  @override
  State<SecureSignatureDialog> createState() => _SecureSignatureDialogState();
}

class _SecureSignatureDialogState extends State<SecureSignatureDialog> {
  bool _isSearching = true;
  bool _hasError = false;
  bool _isSigning = false;
  String? _keysDirectoryPath;

  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _startSearchTimer();
  }

  void _startSearchTimer() {
    _searchTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _searchTimer != null) {
        setState(() {
          _isSearching = false;
        });
        // Focus on pin input after detecting
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _searchTimer != null) {
            _pinFocusNode.requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchTimer = null;
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickKeysDirectory() async {
    // Cancel the search timer immediately to prevent background focus requests while FilePicker is open
    _searchTimer?.cancel();
    _searchTimer = null;
    
    if (_isSearching) {
      setState(() {
        _isSearching = false;
      });
    }

    // Unfocus the PIN field before opening file picker to avoid native window focus conflicts
    _pinFocusNode.unfocus();
    
    // Give the focus system a tiny moment to clear
    await Future.delayed(const Duration(milliseconds: 50));

    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'اختاري مجلد مفاتيح الموظف من الفلاشة',
    );
    
    if (path != null) {
      if (mounted) {
        setState(() {
          _keysDirectoryPath = path;
        });
      }
    }

    // Refocus the PIN field after the file picker is closed, delayed to avoid Win32 window focus collision
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pinFocusNode.requestFocus();
      }
    });
  }

  String _getFolderName(String path) {
    if (path.isEmpty) return '';
    final parts = path.split(RegExp(r'[/\\]'));
    return parts.lastWhere((part) => part.isNotEmpty, orElse: () => path);
  }

  void _checkPin(String pin) {
    if (pin.length < 6) return;

    if (_keysDirectoryPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار مجلد مفاتيح الأمان من الفلاشة أولاً'),
        ),
      );
      _pinController.clear();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _pinFocusNode.requestFocus();
        }
      });
      return;
    }

    Navigator.of(context).pop<Map<String, String>>({
      'pin': pin,
      'keysDirectoryPath': _keysDirectoryPath!,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Container(
              color: AppColors.forest,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Shield Icon
                  const Icon(
                    LucideIcons.shieldAlert,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  // Title / Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: [
                        Text(
                          'التوقيع الإلكتروني الآمن',
                          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'توقيع المعاملة: ${widget.transactionNumber}',
                          style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dialog Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Insert Flash Alert Card
                    _buildInsertFlashCard(),
                    const SizedBox(height: 20),

                    // Search/Detected State Container
                    _isSearching
                        ? _buildSearchingState()
                        : _buildDetectedState(),
                    const SizedBox(height: 24),

                    // PIN Code Inputs Label
                    Text(
                      'رمز PIN للموظف (6 أرقام)',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(fontWeight: AppTextStyles.medium, color: AppColors.charcoalDark),
                    ),
                    const SizedBox(height: 12),

                    // 6 digits PIN row using Pinput
                    _buildPinInputRow(),

                    // Error text
                    if (_hasError) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.xCircle,
                              color: Colors.red, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'رمز PIN غير صحيح، يرجى كتابة الرمز الصحيح الخاص بك.',
                            style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Info banner
                    _buildSecurityInfo(),
                    const SizedBox(height: 24),

                    // Cancel button or loading
                    _isSigning
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.forest,
                            ),
                          )
                        : OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.charcoal,
                              side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.35)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              'إلغاء',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: AppTextStyles.medium),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsertFlashCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.key, color: AppColors.goldDark, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  'الرجاء اختيار مجلد التوقيع من الفلاشة:',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.goldDark),
                ),
                SizedBox(height: 2),
                Text(
                  'يرجى تحديد المجلد الذي يحتوي على مفتاح الأمان والتوقيع الإلكتروني الخاص بالموظف من الفلاشة للبدء.',
                  style: AppTextStyles.labelMedium.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              'جاري البحث عن مفتاح الأمان (الفلاشة)... يرجى الانتظار...',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.medium),
            ),
          ),
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.forest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Status detected text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F9F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD4EFEB)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(LucideIcons.checkCircle, color: Color(0xFF2E7D32), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم الكشف عن منفذ التوقيع. يرجى اختيار مجلد مفاتيح الأمان من الفلاشة وإدخال رمز PIN المكون من 6 أرقام لتوقيع المعاملة.',
                  style: AppTextStyles.labelMedium.copyWith(color: Color(0xFF2E7D32), height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Folder Selector Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: InkWell(
            onTap: _pickKeysDirectory,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                const Icon(LucideIcons.folderOpen,
                    color: AppColors.goldDark, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        _keysDirectoryPath == null
                            ? 'اضغط هنا لتحديد مجلد مفاتيح الأمان'
                            : 'تم تحديد مجلد المفاتيح بنجاح',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.forest),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _keysDirectoryPath == null
                            ? 'لم يتم اختيار مجلد الفلاشة'
                            : _getFolderName(_keysDirectoryPath!),
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
                if (_keysDirectoryPath != null)
                  const Icon(LucideIcons.checkCircle2,
                      color: Colors.green, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputRow() {
    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Pinput(
          controller: _pinController,
          focusNode: _pinFocusNode,
          length: 6,
          obscureText: true,
          enabled: !_isSearching && !_isSigning,
          pinAnimationType: PinAnimationType.scale,
          defaultPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: AppTextStyles.headlineMedium.copyWith(fontWeight: AppTextStyles.semiBold, color: AppColors.charcoalDark),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F8F4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hasError ? Colors.red : AppColors.gold.withOpacity(0.25),
                width: 1.0,
              ),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 52,
            height: 52,
            textStyle: AppTextStyles.headlineMedium.copyWith(fontWeight: AppTextStyles.semiBold),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hasError ? Colors.red : AppColors.forest,
                width: 1.5,
              ),
            ),
          ),
          onCompleted: (pin) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _pinFocusNode.unfocus();
                _checkPin(pin);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.lock,
              color: AppColors.charcoal.withOpacity(0.6), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'عملية التوقيع تتم بشكل آمن ومشفر وفق معايير PKI الحكومية، لا تشارك رمز PIN مع أي شخص.',
              style: AppTextStyles.labelSmall.copyWith(fontSize: 10.5, color: AppColors.charcoal.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}

