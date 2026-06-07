import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  late AnimationController _illusController;

  @override
  void initState() {
    super.initState();
    _illusController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _illusController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({required String hint, Widget? prefix, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.goldLight,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.goldLight,

        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpSentState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم إرسال رمز التحقق بنجاح',
                    style: GoogleFonts.cairo(),
                  ),
                ),
              );

              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OtpPage()),
              );
            }

            if (state is AuthErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },

          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),

                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft abstract background shapes
                        Positioned(
                          top: -80,
                          right: -60,
                          child: Transform.rotate(
                            angle: -pi / 8,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.forestLight.withOpacity(0.12), AppColors.umberLight.withOpacity(0.08)],
                                ),
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.forest.withOpacity(0.06),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -100,
                          left: -80,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.gold.withOpacity(0.08), AppColors.goldLight.withOpacity(0.06)],
                              ),
                              borderRadius: BorderRadius.circular(80),
                            ),
                          ),
                        ),

                        // Main card
                        Container(
                          constraints: BoxConstraints(maxWidth: isWide ? 1000 : 520),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 12),
                              )
                            ],
                          ),

                          child: isWide
                              ? Row(
                                  children: [
                                    // Form side (right because RTL)
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(36),
                                        child: FadeInRight(
                                          child: _buildForm(isLoading),
                                        ),
                                      ),
                                    ),

                                    // Illustration side
                                    Expanded(
                                      flex: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(36),
                                        child: FadeInLeft(
                                          child: _buildIllustration(isWide),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 24),
                                      child: _buildIllustration(isWide),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: _buildForm(isLoading),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIllustration(bool isWide) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _illusController, curve: Curves.easeInOut)),
            child: Container(
              width: isWide ? 220 : 120,
              height: isWide ? 220 : 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.forest, AppColors.forestLight]),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: AppColors.forest.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: const Icon(Icons.business_center, size: 64, color: AppColors.white),
            ),
          ),

          const SizedBox(height: 20),

          Text('مرحبًا بك يا موظف', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          const SizedBox(height: 6),
          Text('سجل الدخول للوصول إلى بياناتك وملفاتك الرسمية', textAlign: TextAlign.center, style: GoogleFonts.cairo(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(color: AppColors.forest, shape: BoxShape.circle),
            child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.white, size: 34),
          ),

          const SizedBox(height: 18),

          Text('تسجيل الدخول', style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          Text('قم بتسجيل الدخول للمتابعة إلى لوحة التحكم', style: GoogleFonts.cairo(color: Colors.grey[600])),

          const SizedBox(height: 24),

          // USERNAME
          TextFormField(
            controller: usernameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الرجاء إدخال اسم المستخدم';
              }

              if (value.trim().length < 3) {
                return 'اسم المستخدم قصير جدًا';
              }

              return null;
            },
            decoration: _inputDecoration(hint: 'اسم المستخدم', prefix: const Icon(Icons.person_outline, color: AppColors.forest)),
          ),

          const SizedBox(height: 14),

          // PASSWORD
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
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
              prefix: const Icon(Icons.lock_outline, color: AppColors.forest),
              suffix: IconButton(
                onPressed: () => setState(() => obscurePassword = !obscurePassword),
                icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
              ),
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();

                      if (!formKey.currentState!.validate()) return;

                      context.read<AuthBloc>().add(
                            LoginRequested(usernameController.text.trim(), passwordController.text.trim()),
                          );
                    },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) => AppColors.forest),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                elevation: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.disabled) ? 0 : 6),
                overlayColor: MaterialStateProperty.all(AppColors.forestLight.withOpacity(0.12)),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                  : Text('إرسال رمز التحقق', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}