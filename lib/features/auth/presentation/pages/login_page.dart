import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';

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

class _LoginViewState extends State<_LoginView> with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _illusController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Widget _movingCircle({
    required double radius,
    required double size,
    required Color color,
    double angleOffset = 0,
  }) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final angle = _bgController.value * 2 * pi + angleOffset;
        return Align(
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(cos(angle) * radius, sin(angle) * radius),
            child: child!,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
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
              _movingCircle(
                radius: 240,
                size: 320,
                color: AppColors.gold.withOpacity(0.12),
              ),
              _movingCircle(
                radius: 240,
                size: 340,
                color: AppColors.forest.withOpacity(0.08),
                angleOffset: pi,
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
                              child: const LoginForm(isWide: true),
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
                                _movingCircle(
                                  radius: 210,
                                  size: 280,
                                  color: AppColors.gold.withOpacity(0.18),
                                ),
                                _movingCircle(
                                  radius: 210,
                                  size: 260,
                                  color: AppColors.goldLight.withOpacity(0.14),
                                  angleOffset: pi,
                                ),
                                Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                      vertical: 40,
                                    ),
                                    child: _LoginIllustration(
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
                      child: LoginForm(
                        isWide: false,
                        controller: _illusController,
                      ),
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
}

class _LoginIllustration extends StatelessWidget {
  final AnimationController controller;

  const _LoginIllustration({
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
            _FloatingLogo(
              controller: controller,
              width: 140,
              height: 140,
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
      hintStyle: _style(
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
      errorStyle: _style(
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
            const SnackBar(
              content: Text('تم إرسال رمز التحقق بنجاح'),
            ),
          );

          context.go('/otp', extra: state.sessionId);
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
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
                if (!widget.isWide) ...[
                  Center(
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          if (widget.controller != null)
                            _FloatingLogo(
                              controller: widget.controller!,
                              width: 85,
                              height: 85,
                              yBegin: -6,
                              yEnd: 6,
                              scaleBegin: 1,
                              scaleEnd: 1,
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
                    'تسجيل الدخول',
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
                    'قم بتسجيل الدخول للمتابعة إلى لوحة التحكم',
                    style: _style(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  duration: const Duration(milliseconds: 450),
                  child: TextFormField(
                    controller: usernameController,
                    style: _style(fontSize: 15),
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
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 450),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: _style(fontSize: 15),
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
                              style: _style(
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

class _FloatingLogo extends StatelessWidget {
  final AnimationController controller;
  final double width;
  final double height;
  final double yBegin;
  final double yEnd;
  final double scaleBegin;
  final double scaleEnd;

  const _FloatingLogo({
    required this.controller,
    required this.width,
    required this.height,
    this.yBegin = -8,
    this.yEnd = 8,
    this.scaleBegin = 0.98,
    this.scaleEnd = 1.02,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ).value;

        final yOffset = Tween<double>(
          begin: yBegin,
          end: yEnd,
        ).transform(value);

        final scale = Tween<double>(
          begin: scaleBegin,
          end: scaleEnd,
        ).transform(value);

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
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
