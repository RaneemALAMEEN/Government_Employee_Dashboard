import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../bloc/document_verification_bloc.dart';
import '../bloc/document_verification_event.dart';
import '../bloc/document_verification_state.dart';
import '../widgets/document_verification_widgets.dart';

class DocumentVerificationPage extends StatefulWidget {
  const DocumentVerificationPage({super.key});

  @override
  State<DocumentVerificationPage> createState() =>
      _DocumentVerificationPageState();
}

class _DocumentVerificationPageState extends State<DocumentVerificationPage> {
  final TextEditingController _codeController = TextEditingController();

  void _verify() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      AppSnackBar.show(
        context,
        message: 'أدخل رمز التفاصيل أولاً',
        isError: true,
      );
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      AppSnackBar.show(
        context,
        message: 'يجب أن يتكون رمز التفاصيل من 6 أرقام',
        isError: true,
      );
      return;
    }
    context
        .read<DocumentVerificationBloc>()
        .add(VerifyDocumentRequested(code: code));
  }

  void _reset() {
    _codeController.clear();
    context
        .read<DocumentVerificationBloc>()
        .add(const ResetDocumentVerification());
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: ColoredBox(
          color: AppColors.background,
          child:
              BlocBuilder<DocumentVerificationBloc, DocumentVerificationState>(
            builder: (context, state) {
              final loading = state is DocumentVerificationLoading;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 25, 28, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const VerificationPageHeader(),
                        const SizedBox(height: 18),
                        VerificationInputCard(
                          controller: _codeController,
                          loading: loading,
                          compact: state is DocumentVerificationSuccess,
                          onVerify: _verify,
                          onReset: state is DocumentVerificationInitial
                              ? null
                              : _reset,
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 230),
                          switchInCurve: Curves.easeOutCubic,
                          child: switch (state) {
                            DocumentVerificationLoading() =>
                              const VerificationSkeleton(
                                key: ValueKey('loading'),
                              ),
                            DocumentVerificationSuccess(:final data) =>
                              VerificationResult(
                                key: const ValueKey('success'),
                                data: data,
                              ),
                            DocumentVerificationFailure(
                              :final code,
                              :final isNetworkError,
                              :final isExpired,
                            ) =>
                              VerificationErrorCard(
                                key: const ValueKey('failure'),
                                isNetworkError: isNetworkError,
                                isExpired: isExpired,
                                onRetry: () => context
                                    .read<DocumentVerificationBloc>()
                                    .add(VerifyDocumentRequested(code: code)),
                                onReset: _reset,
                              ),
                            _ => const SizedBox.shrink(
                                key: ValueKey('initial'),
                              ),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
