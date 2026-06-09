import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();

  Timer? _timer;
  int _remaining = 30;
  bool _resendAvailable = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
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
          backgroundColor: AppColors.goldLight,
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

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    constraints: const BoxConstraints(maxWidth: 520),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeIn(
                          duration: const Duration(milliseconds: 420),
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: AppColors.forest,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 44,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'رمز التحقق',
                          style: GoogleFonts.cairo(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'أدخل رمز التحقق المرسل إلى هاتفك',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 22),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: otpController,
                            length: 6,
                            pinAnimationType: PinAnimationType.scale,
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 64,
                              textStyle: GoogleFonts.cairo(
                                fontSize: 20,
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.goldLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 58,
                              height: 66,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.forest,
                                  width: 2,
                                ),
                              ),
                              textStyle: GoogleFonts.cairo(
                                fontSize: 20,
                                color: AppColors.charcoal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'أعد إرسال الرمز خلال',
                              style: GoogleFonts.cairo(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '00:${_remaining.toString().padLeft(2, '0')}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                                color: AppColors.umber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _resendAvailable ? _onResend : null,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                (_) => _resendAvailable
                                    ? AppColors.forest
                                    : AppColors.gold.withOpacity(0.6),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            child: Text(
                              _resendAvailable
                                  ? 'إعادة إرسال الرمز'
                                  : 'إعادة الإرسال',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
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
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                AppColors.forest,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Text(
                                    'تأكيد',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}