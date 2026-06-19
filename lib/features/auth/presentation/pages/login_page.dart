import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView>
    with TickerProviderStateMixin {
  late AnimationController _illusController;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    // Controller for the eagle floating animation
    _illusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Controller for the drifting background circles (speed adjusted to 10 seconds for visible, gentle movement)
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _illusController.dispose();
    _bgController.dispose();
    super.dispose();
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

            // Define the circular moving background circles for the main Scaffold
            // They orbit wide (radius 240) around the center of the screen, swapping places
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
                      // Left Side - Form Panel
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
                                child: const LoginForm(isWide: true),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right Side - Branding Panel (Forest Green Gradient + Drifting Gold Spots)
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
                        child: LoginForm(
                          isWide: false,
                          controller: _illusController,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
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
            // Eagle with floating and scale effects (No background circle)
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

class LoginForm extends StatefulWidget {
  final bool isWide;
  final AnimationController? controller;

  const LoginForm({
    super.key,
    required this.isWide,
    this.controller,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 18,
      ),
      hintStyle: GoogleFonts.cairo(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.forest,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.redAccent.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.8,
        ),
      ),
      errorStyle: GoogleFonts.cairo(
        color: Colors.redAccent,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إرسال رمز التحقق بنجاح',
                style: GoogleFonts.cairo(),
              ),
            ),
          );

          context.go('/otp', extra: state.sessionId);
        }

        if (state is LoginFailure) {
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
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mobile layout gets the logo header at the top of the form (No background circle)
                if (!widget.isWide) ...[
                  Center(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          // Floating animation on mobile if controller is present
                          if (widget.controller != null)
                            AnimatedBuilder(
                              animation: widget.controller!,
                              builder: (context, child) {
                                final double yOffset = Tween<double>(begin: -6.0, end: 6.0).transform(
                                  CurvedAnimation(
                                    parent: widget.controller!,
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
                            )
                          else
                            SvgPicture.asset(
                              'assets/vectors/syria-logo.svg',
                              width: 85,
                              height: 85,
                              fit: BoxFit.contain,
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
                    'تسجيل الدخول',
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
                    'قم بتسجيل الدخول للمتابعة إلى لوحة التحكم',
                    style: GoogleFonts.cairo(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Username field
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 450),
                  child: TextFormField(
                    controller: usernameController,
                    style: GoogleFonts.cairo(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الرجاء إدخال اسم المستخدم';
                      }
                      if (value.trim().length < 3) {
                        return 'اسم المستخدم قصير جدًا';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: 'اسم المستخدم',
                      prefix: Icon(
                        LucideIcons.user,
                        color: AppColors.forest.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 450),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: GoogleFonts.cairo(fontSize: 15),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور قصيرة جدًا';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: 'كلمة المرور',
                      prefix: Icon(
                        LucideIcons.lock,
                        color: AppColors.forest.withOpacity(0.7),
                        size: 20,
                      ),
                      suffix: IconButton(
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                        icon: Icon(
                          obscurePassword
                              ? LucideIcons.eyeOff
                              : LucideIcons.eye,
                          color: AppColors.forest.withOpacity(0.7),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button - Solid brand color (no gradient) as requested
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
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
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();

                              if (!formKey.currentState!.validate()) return;

                              context.read<LoginBloc>().add(
                                    LoginSubmitted(
                                      userName: usernameController.text.trim(),
                                      password: passwordController.text.trim(),
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
                              'إرسال رمز التحقق',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
