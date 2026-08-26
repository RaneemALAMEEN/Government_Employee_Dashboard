import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:government_employee_dashboard/core/services/session_service.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../domain/usecases/verify_app_pin_usecase.dart';

TextStyle _style({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
}) {
  return TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
  );
}

class AppPinUnlockPage extends StatefulWidget {
  const AppPinUnlockPage({super.key});

  @override
  State<AppPinUnlockPage> createState() => _AppPinUnlockPageState();
}

class _AppPinUnlockPageState extends State<AppPinUnlockPage>
    with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _pinFocusNode = FocusNode();

  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _illusController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _illusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _illusController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _verifyPin(String pin) async {
    if (pin.length != 6 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final useCase = getIt<VerifyAppPinUseCase>();
    final result = await useCase(pin);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
          _pinController.clear();
        });
        _pinFocusNode.requestFocus();
      },
      (_) {
        getIt<SessionService>().setSessionPin(pin);
        setState(() {
          _isLoading = false;
        });
        context.go('/my-transactions');
      },
    );
  }

  Future<void> _handleLogout() async {
    await getIt<SecureStorageService>().clear();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            final scaffoldBackgroundCircles = [
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final angle = _bgController.value * 2 * pi;
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(cos(angle) * 240, sin(angle) * 240),
                      child: child!,
                    ),
                  );
                },
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withOpacity(0.12),
                        AppColors.gold.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final angle = _bgController.value * 2 * pi + pi;
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(cos(angle) * 240, sin(angle) * 240),
                      child: child!,
                    ),
                  );
                },
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.forest.withOpacity(0.08),
                        AppColors.forest.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ];

            if (isWide) {
              return Stack(
                children: [
                  ...scaffoldBackgroundCircles,
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 40,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: _buildPinUnlockForm(isWide: true),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                AppColors.forest,
                                AppColors.forestDark,
                              ],
                            ),
                          ),
                          child: ClipRect(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedBuilder(
                                  animation: _bgController,
                                  builder: (context, child) {
                                    final angle = _bgController.value * 2 * pi;
                                    return Transform.translate(
                                      offset: Offset(
                                        cos(angle) * 210,
                                        sin(angle) * 210,
                                      ),
                                      child: child!,
                                    );
                                  },
                                  child: Container(
                                    width: 280,
                                    height: 280,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppColors.gold.withOpacity(0.18),
                                          AppColors.gold.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 40,
                                    ),
                                    child: _PinIllustration(
                                      controller: _illusController,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Stack(
              children: [
                ...scaffoldBackgroundCircles,
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 40,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildPinUnlockForm(isWide: false),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPinUnlockForm({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isWide) ...[
          Center(
            child: FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _illusController,
                    builder: (context, child) {
                      final value = CurvedAnimation(
                        parent: _illusController,
                        curve: Curves.easeInOut,
                      ).value;

                      final yOffset =
                          Tween<double>(begin: -6, end: 6).transform(value);

                      return Transform.translate(
                        offset: Offset(0, yOffset),
                        child: child,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/vectors/syria-logo.svg',
                      width: 85,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'مديرية تربية ريف دمشق',
                    style: _style(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest,
                    ),
                  ),
                  Text(
                    'منصة الخدمات الموحدة للموظف الحكومي',
                    textAlign: TextAlign.center,
                    style: _style(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1.5,
                    width: 80,
                    color: Colors.grey[200],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
        FadeInDown(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 400),
          child: Text(
            'فتح قفل التطبيق',
            style: _style(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
        ),
        const SizedBox(height: 6),
        FadeInDown(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 400),
          child: Text(
            'يرجى إدخال رمز PIN الخاص بك لمتابعة استخدام التطبيق',
            style: _style(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 36),
        FadeInUp(
          delay: const Duration(milliseconds: 150),
          duration: const Duration(milliseconds: 450),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: _pinController,
              focusNode: _pinFocusNode,
              length: 6,
              obscureText: true,
              obscuringCharacter: '●',
              enabled: !_isLoading,
              pinAnimationType: PinAnimationType.scale,
              defaultPinTheme: PinTheme(
                width: 52,
                height: 60,
                textStyle: _style(
                  fontSize: 22,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorMessage != null
                        ? AppColors.error
                        : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 54,
                height: 62,
                textStyle: _style(
                  fontSize: 22,
                  color: AppColors.forest,
                  fontWeight: FontWeight.w700,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorMessage != null
                        ? AppColors.error
                        : AppColors.forest,
                    width: 2.0,
                  ),
                ),
              ),
              onCompleted: (pin) => _verifyPin(pin),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 14),
          FadeIn(
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: _style(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 450),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _isLoading
                  ? AppColors.forest.withOpacity(0.6)
                  : AppColors.forest,
              boxShadow: [
                if (!_isLoading)
                  BoxShadow(
                    color: AppColors.forest.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _verifyPin(_pinController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.zero,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'فتح القفل',
                      style: _style(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          delay: const Duration(milliseconds: 250),
          duration: const Duration(milliseconds: 450),
          child: TextButton.icon(
            onPressed: _isLoading ? null : _handleLogout,
            icon: const Icon(
              LucideIcons.logOut,
              size: 18,
              color: AppColors.error,
            ),
            label: Text(
              'تسجيل الخروج من الحساب',
              style: _style(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PinIllustration extends StatelessWidget {
  final AnimationController controller;

  const _PinIllustration({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final value = CurvedAnimation(
                  parent: controller,
                  curve: Curves.easeInOut,
                ).value;

                final yOffset =
                    Tween<double>(begin: -8, end: 8).transform(value);
                final scale =
                    Tween<double>(begin: 0.98, end: 1.02).transform(value);

                return Transform.translate(
                  offset: Offset(0, yOffset),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/vectors/syria-logo.svg',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'مديرية تربية ريف دمشق',
              textAlign: TextAlign.center,
              style: _style(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'منصة الخدمات الموحدة للموظف الحكومي',
              textAlign: TextAlign.center,
              style: _style(
                color: AppColors.goldLight.withOpacity(0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.lock,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'تطبيق محمي برمز PIN آمن',
                    style: _style(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
