import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/theme/app_colors.dart';

class SecureSignatureDialog extends StatefulWidget {
  final String transactionNumber;
  final VoidCallback onSuccess;

  const SecureSignatureDialog({
    super.key,
    required this.transactionNumber,
    required this.onSuccess,
  });

  @override
  State<SecureSignatureDialog> createState() => _SecureSignatureDialogState();
}

class _SecureSignatureDialogState extends State<SecureSignatureDialog> {
  bool _isSearching = true;
  bool _hasError = false;
  bool _isSigning = false;
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _startSearchTimer();
  }

  void _startSearchTimer() {
    _searchTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        // Focus on the first text field after detecting
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _focusNodes[0].requestFocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkPin() {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length < 6) return;

    setState(() {
      _isSigning = true;
    });

    // Simulate cryptographic processing
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      // Mock behavior: first attempt fails to show error state, second attempt succeeds
      if (!_hasError && pin != "123456") {
        setState(() {
          _hasError = true;
          _isSigning = false;
          // Clear all pin entries
          for (var controller in _controllers) {
            controller.clear();
          }
          // Refocus first field
          _focusNodes[0].requestFocus();
        });
      } else {
        // Correct pin or second try
        setState(() {
          _isSigning = false;
        });
        Navigator.of(context).pop();
        widget.onSuccess();
      }
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
                        const Text(
                          'التوقيع الإلكتروني الآمن',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'توقيع المعاملة رقم ${widget.transactionNumber}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                          ),
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
                    const Text(
                      'رمز PIN للموظف (6 أرقام)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.charcoalDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 6 digits PIN row
                    _buildPinInputRow(),

                    // Error text
                    if (_hasError) ...[
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.xCircle,
                              color: Colors.red, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'رمز PIN غير صحيح، يرجى كتابة الرمز الصحيح الخاص بك.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
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
      child: const Row(
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
                  'الرجاء إدخال الفلاشة:',
                  style: TextStyle(
                    color: AppColors.goldDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'يرجى توصيل الفلاشة الخاصة بك التي تحتوي على مفتاح الأمان والتوقيع الإلكتروني الخاص بالموظف للبدء.',
                  style: TextStyle(
                    color: AppColors.charcoal,
                    fontSize: 11,
                    height: 1.4,
                  ),
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
      child: const Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: Text(
              'جاري البحث عن مفتاح الأمان (الفلاشة)... يرجى الانتظار...',
              style: TextStyle(
                color: AppColors.charcoal,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
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
          child: const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(LucideIcons.checkCircle, color: Color(0xFF2E7D32), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم التحقق من الفلاشة: تم الكشف عن مفتاح الأمان والتوقيع الإلكتروني بنجاح، يرجى إدخال رمز PIN للموظف المكون من 6 أرقام لتوقيع المعاملة.',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Device info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
          ),
          child: const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(LucideIcons.usb, color: AppColors.forestLight, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'تم اكتشاف مفتاح الأمان (USB Key) بنجاح',
                      style: TextStyle(
                        color: AppColors.forest,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Secure eToken — Serial: AE3F9D2C',
                      style: TextStyle(
                        color: AppColors.charcoal,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: TextDirection.ltr, // Input digits show from left to right
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            enabled: !_isSearching && !_isSigning,
            obscureText: true,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoalDark,
            ),
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: const Color(0xFFF9F8F4),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      _hasError ? Colors.red : AppColors.gold.withOpacity(0.25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      _hasError ? Colors.red : AppColors.gold.withOpacity(0.25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _hasError ? Colors.red : AppColors.forest,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next cell
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // Submit PIN on 6th digit
                  _focusNodes[index].unfocus();
                  _checkPin();
                }
              } else {
                // Move to previous cell on delete
                if (index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
            },
          ),
        );
      }),
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
              style: TextStyle(
                color: AppColors.charcoal.withOpacity(0.7),
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
