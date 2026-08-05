import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/otp_input_field.dart';
import '../../../core/widgets/security_badge.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  void _handleVerify() async {
    FocusScope.of(context).unfocus();
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.verifyOtp();

    if (success && mounted) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authProvider).errorMessage;
      if (errorMsg != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 22),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 32.0).clamp(0.0, double.infinity),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      // Title
                      Text(
                        'Verification',
                        style: AppTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 30,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Please enter the 4-digit code sent to your registered mobile number ending with ${authState.phoneNumber.length >= 4 ? authState.phoneNumber.substring(authState.phoneNumber.length - 4) : "8769"}.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                      const SizedBox(height: 36),

                      // OTP Pin Boxes
                      OtpInputField(
                        length: 4,
                        onChanged: (code) {
                          ref.read(authProvider.notifier).setOtpCode(code);
                        },
                        onCompleted: (code) {
                          ref.read(authProvider.notifier).setOtpCode(code);
                          _handleVerify();
                        },
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

                      const SizedBox(height: 28),

                      // Resend Code Section
                      Center(
                        child: authState.canResendOtp
                            ? TextButton(
                                onPressed: () {
                                  ref.read(authProvider.notifier).resendOtp();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('OTP code resent successfully!'),
                                      backgroundColor: AppColors.primary,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Resend OTP Code',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  children: [
                                    const TextSpan(text: "Didn't receive code? "),
                                    TextSpan(
                                      text: 'Resend OTP in 0:${authState.resendTimerSeconds.toString().padLeft(2, '0')}',
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                      const Spacer(),

                      const SizedBox(height: 24),

                      // Verify Button
                      CustomButton(
                        text: 'Verify & Proceed',
                        isLoading: authState.isVerifying,
                        onPressed: _handleVerify,
                      ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Security Footer
                      const SecurityBadge()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 500.ms),
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
}
