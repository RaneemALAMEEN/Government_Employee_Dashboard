import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../bloc/otp/otp_bloc.dart';
import '../bloc/otp/otp_event.dart';
import '../bloc/otp/otp_state.dart';

class OtpPage extends StatefulWidget {
  final String sessionId;

  const OtpPage({
    super.key,
    required this.sessionId,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage>
    with TickerProviderStateMixin {
  final otpController = TextEditingController();

  Timer? _timer;
  int _remaining = 30;
  bool _resendAvailable = false;

  late AnimationController _illusController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Floating eagle animation controller
    _illusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Drifting background circles controller (10s swap period)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    _illusController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remaining = 30;
      _resendAvailable = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _resendAvailable = true;
          _remaining = 0;
        });
      } else {
        setState(() => _remaining -= 1);
      }
    });
  }

  void _onResend() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم طلب رمز تحقق جديد',
          style: GoogleFonts.cairo(),
        ),
      ),
    );

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OtpBloc>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: BlocConsumer<OtpBloc, OtpState>(
            listener: (context, state) {
              if (state is OtpSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تسجيل الدخول بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                  ),
                );

                context.go('/dashboard');
              }

              if (state is OtpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is OtpLoading;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 850;

                  // Define circular moving background circles for the main Scaffold
                  final scaffoldBackgroundCircles = [
                    // Scaffold Circle A (Gold)
                    AnimatedBuilder(
                      animation: _bgController,
                      builder: (context, child) {
                        final double angle = _bgController.value * 2 * pi;
                        final double dx = cos(angle) * 240.0;
                        final double dy = sin(angle) * 240.0;
                        return Align(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(dx, dy),
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
                              AppColors.gold.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Scaffold Circle B (Forest Green - Opposite side)
                    AnimatedBuilder(
                      animation: _bgController,
                      builder: (context, child) {
                        final double angle = _bgController.value * 2 * pi + pi;
                        final double dx = cos(angle) * 240.0;
                        final double dy = sin(angle) * 240.0;
                        return Align(
                          alignment: Alignment.center,
                          child: Transform.translate(
                            offset: Offset(dx, dy),
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
                              AppColors.forest.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];

                  if (isWide) {
                    return Stack(
                      children: [
                        // Drifting background circles behind the white side
                        ...scaffoldBackgroundCircles,

                        Row(
                          children: [
                            // Left Side - OTP Form Panel
                            Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.transparent,
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 40,
                                    ),
                                    child: Container(
                                      constraints: const BoxConstraints(maxWidth: 420),
                                      child: _buildOtpForm(isLoading, isWide: true),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Right Side - Branding/Identity Panel (Forest Green Gradient + Drifting Gold Spots)
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
                                      // Drifting Gold Circle A (Orbits wide at 210 radius around the center)
                                      AnimatedBuilder(
                                        animation: _bgController,
                                        builder: (context, child) {
                                          final double angle = _bgController.value * 2 * pi;
                                          final double dx = cos(angle) * 210.0;
                                          final double dy = sin(angle) * 210.0;
                                          return Transform.translate(
                                            offset: Offset(dx, dy),
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
                                                AppColors.gold.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Drifting Gold Circle B (Orbits wide opposite to Circle A)
                                      AnimatedBuilder(
                                        animation: _bgController,
                                        builder: (context, child) {
                                          final double angle = _bgController.value * 2 * pi + pi;
                                          final double dx = cos(angle) * 210.0;
                                          final double dy = sin(angle) * 210.0;
                                          return Transform.translate(
                                            offset: Offset(dx, dy),
                                            child: child!,
                                          );
                                        },
                                        child: Container(
                                          width: 260,
                                          height: 260,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                AppColors.goldLight.withOpacity(0.14),
                                                AppColors.goldLight.withOpacity(0.0),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Content (Eagle & Text)
                                      Center(
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 40,
                                          ),
                                          child: _LoginIllustration(
                                            isWide: true,
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
                  } else {
                    // Mobile View - Scrollable form with drifting background circles
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
                              child: _buildOtpForm(isLoading, isWide: false),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOtpForm(bool isLoading, {required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mobile layout gets the logo header at the top of the form (No background circle)
        if (!isWide) ...[
          Center(
            child: FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Column(
                children: [
                  // Floating animation on mobile if controller is present
                  AnimatedBuilder(
                    animation: _illusController,
                    builder: (context, child) {
                      final double yOffset = Tween<double>(begin: -6.0, end: 6.0).transform(
                        CurvedAnimation(
                          parent: _illusController,
                          curve: Curves.easeInOut,
                        ).value,
                      );
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
                    'الجمهورية العربية السورية',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forest,
                    ),
                  ),
                  Text(
                    'منصة الخدمات الموحدة للموظف الحكومي',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
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
            'رمز التحقق',
            style: GoogleFonts.cairo(
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
            'أدخل رمز التحقق المكون من 6 أرقام المرسل إلى هاتفك',
            style: GoogleFonts.cairo(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // Pin input field
        FadeInUp(
          delay: const Duration(milliseconds: 150),
          duration: const Duration(milliseconds: 450),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              controller: otpController,
              length: 6,
              pinAnimationType: PinAnimationType.scale,
              defaultPinTheme: PinTheme(
                width: 52,
                height: 60,
                textStyle: GoogleFonts.cairo(
                  fontSize: 20,
                  color: AppColors.charcoal,
                  fontWeight: FontWeight.w700,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1.5,
                  ),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 54,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.forest,
                    width: 1.8,
                  ),
                ),
                textStyle: GoogleFonts.cairo(
                  fontSize: 20,
                  color: AppColors.forest,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Confirm Button (Solid Forest Green Color)
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 450),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isLoading
                  ? AppColors.forest.withOpacity(0.6)
                  : AppColors.forest,
              boxShadow: [
                if (!isLoading)
                  BoxShadow(
                    color: AppColors.forest.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Builder(builder: (context) {
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        final otp = otpController.text.trim();

                        if (otp.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'الرجاء إدخال رمز التحقق',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        if (otp.length != 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'رمز التحقق يجب أن يكون 6 أرقام',
                                style: GoogleFonts.cairo(),
                              ),
                            ),
                          );
                          return;
                        }

                        context.read<OtpBloc>().add(
                              OtpSubmitted(
                                sessionId: widget.sessionId,
                                otp: otp,
                              ),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'تأكيد الرمز',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),

        // Resend Timer Outlined Button (Dynamic countdown & clicking)
        FadeInUp(
          delay: const Duration(milliseconds: 250),
          duration: const Duration(milliseconds: 450),
          child: OutlinedButton(
            onPressed: _resendAvailable ? _onResend : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _resendAvailable ? AppColors.forest : Colors.grey[200]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              _resendAvailable
                  ? 'إعادة إرسال الرمز'
                  : 'إعادة إرسال الرمز خلال 00:${_remaining.toString().padLeft(2, '0')}',
              style: GoogleFonts.cairo(
                color: _resendAvailable ? AppColors.forest : Colors.grey[500],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginIllustration extends StatelessWidget {
  final bool isWide;
  final AnimationController controller;

  const _LoginIllustration({
    required this.isWide,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Eagle floating and scale transitions (No background circle)
            AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final double yOffset = Tween<double>(begin: -8.0, end: 8.0).transform(
                  CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeInOut,
                  ).value,
                );
                final double scale = Tween<double>(begin: 0.98, end: 1.02).transform(
                  CurvedAnimation(
                    parent: controller,
                    curve: Curves.easeInOut,
                  ).value,
                );

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
              'الجمهورية العربية السورية',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
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
              style: GoogleFonts.cairo(
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
                    LucideIcons.shield,
                    color: AppColors.gold,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'بوابة وصول آمنة ومشفرة',
                    style: GoogleFonts.cairo(
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
