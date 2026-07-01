import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:government_employee_dashboard/core/storage/secure_storage_service.dart';

import '../../../../core/di/injection.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
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
      duration: const Duration(seconds: 15),
    )..repeat();

    _checkAuth();
  }

  @override
  void dispose() {
    _illusController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final token = await getIt<SecureStorageService>().getToken();
    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final angle = _bgController.value * 2 * pi;
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(cos(angle) * 180, sin(angle) * 180),
                      child: child!,
                    ),
                  );
                },
                child: Container(
                  width: 300,
                  height: 300,
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
              AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  final angle = _bgController.value * 2 * pi + pi;
                  return Align(
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(cos(angle) * 180, sin(angle) * 180),
                      child: child!,
                    ),
                  );
                },
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldLight.withOpacity(0.1),
                        AppColors.goldLight.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _illusController,
                      builder: (context, child) {
                        final value = CurvedAnimation(
                          parent: _illusController,
                          curve: Curves.easeInOut,
                        ).value;

                        final yOffset =
                            Tween<double>(begin: -10, end: 10).transform(value);
                        final scale =
                            Tween<double>(begin: 0.97, end: 1.03).transform(value);

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
                    const SizedBox(height: 32),
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: const Text(
                        'مديرية تربية ريف دمشق',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeInDown(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 600),
                      child: Text(
                        'منصة الخدمات الموحدة للموظف الحكومي',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          color: AppColors.goldLight.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    FadeIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(milliseconds: 600),
                      child: const _CircularLoadingIndicator(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircularLoadingIndicator extends StatefulWidget {
  const _CircularLoadingIndicator();

  @override
  State<_CircularLoadingIndicator> createState() =>
      _CircularLoadingIndicatorState();
}

class _CircularLoadingIndicatorState extends State<_CircularLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withOpacity(0.08),
                width: 3,
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold,
                    blurRadius: 8,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}