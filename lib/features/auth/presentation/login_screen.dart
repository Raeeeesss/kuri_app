import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_logo_widget.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../settings/providers/settings_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _passcodeController;
  bool _isPasscodeObscured = true;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    _nameController = TextEditingController(text: authState.fullName);
    _phoneController = TextEditingController(text: authState.phoneNumber);
    _passcodeController = TextEditingController(text: authState.passcode);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentAuth = ref.read(authProvider);
      final settingsState = ref.read(settingsProvider);
      if (currentAuth.isAuthenticated) {
        if (settingsState.isBiometricEnabled) {
          context.go('/quick-lock');
        } else {
          context.go('/home');
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  void _handleAuthSubmit() async {
    FocusScope.of(context).unfocus();
    final authNotifier = ref.read(authProvider.notifier);
    final isSignUp = ref.read(authProvider).mode == AuthMode.signUp;

    if (isSignUp) {
      authNotifier.setFullName(_nameController.text.trim());
    }
    authNotifier.setPhoneNumber(_phoneController.text.trim());
    authNotifier.setPasscode(_passcodeController.text.trim());

    final success = await authNotifier.authenticate();
    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authProvider).errorMessage;
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isSignUp = authState.mode == AuthMode.signUp;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Section: Logo & Header Titles
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: isSignUp ? 4 : 12),
                              AppLogoWidget(size: isSignUp ? 64 : 72)
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: -0.1, end: 0),
                              const SizedBox(height: 12),
                              Text(
                                isSignUp ? loc.tr('Create Account') : loc.tr('Welcome Back'),
                                style: AppTypography.headlineMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: isSignUp ? 22 : 24,
                                ),
                              ).animate().fadeIn(duration: 350.ms, delay: 50.ms),
                              const SizedBox(height: 10),
                              Text(
                                isSignUp
                                    ? loc.tr('Enter your details to register for Kerala Kuri')
                                    : loc.tr('Enter mobile number & passcode to log in'),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ).animate().fadeIn(duration: 350.ms, delay: 70.ms),
                            ],
                          ),

                          // Middle Section: Form Fields
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (isSignUp) ...[
                                  CustomTextField(
                                    label: loc.tr('Full Name'),
                                    hintText: loc.tr('Enter full legal name'),
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    prefixIcon: const Icon(
                                      Icons.person_outline_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ).animate().fadeIn(duration: 300.ms),
                                  const SizedBox(height: 12),
                                ],
                                CustomTextField(
                                  label: loc.tr('Mobile Number'),
                                  hintText: loc.tr('Enter 10-digit number'),
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  prefixIcon: const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ).animate().fadeIn(duration: 300.ms),
                                SizedBox(height: isSignUp ? 12 : 16),
                                CustomTextField(
                                  label: loc.tr('Passcode (4-Digit PIN)'),
                                  hintText: loc.tr('Enter 4-digit PIN'),
                                  controller: _passcodeController,
                                  keyboardType: TextInputType.number,
                                  obscureText: _isPasscodeObscured,
                                  maxLength: 4,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasscodeObscured
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasscodeObscured =
                                            !_isPasscodeObscured;
                                      });
                                    },
                                  ),
                                ).animate().fadeIn(duration: 300.ms),
                              ],
                            ),
                          ),

                          // Bottom Section: Actions
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomButton(
                                text: isSignUp ? loc.tr('Create Account') : loc.tr('Sign In Securely'),
                                isLoading: authState.isLoading,
                                onPressed: _handleAuthSubmit,
                              ).animate().fadeIn(duration: 350.ms, delay: 150.ms),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    authNotifier.setAuthMode(
                                      isSignUp
                                          ? AuthMode.signIn
                                          : AuthMode.signUp,
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      text: isSignUp
                                          ? loc.tr('Already have an account? ')
                                          : loc.tr("Don't have an account? "),
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: isSignUp ? loc.tr('Sign In') : loc.tr('Sign Up'),
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(duration: 350.ms, delay: 200.ms),
                            ],
                          ),
                        ],
                      ),
                    ),
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
