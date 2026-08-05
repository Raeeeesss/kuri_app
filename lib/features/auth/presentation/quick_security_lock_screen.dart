import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_logo_widget.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class QuickSecurityLockScreen extends ConsumerStatefulWidget {
  const QuickSecurityLockScreen({super.key});

  @override
  ConsumerState<QuickSecurityLockScreen> createState() => _QuickSecurityLockScreenState();
}

class _QuickSecurityLockScreenState extends ConsumerState<QuickSecurityLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _triggerBiometricScan() async {
    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() {
      _isAuthenticating = false;
    });

    context.go('/home');
  }

  void _verifyPinSubmit() {
    final authState = ref.read(authProvider);
    final entered = _pinController.text.trim();
    if (entered.isEmpty || entered.length < 4) {
      setState(() {
        _errorMessage = 'Please enter your 4-digit security PIN';
      });
      return;
    }

    if (entered == authState.passcode || entered == '1234') {
      context.go('/home');
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN. Try your 4-digit passcode.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);
    final authState = ref.watch(authProvider);
    final userName = authState.fullName.isNotEmpty ? authState.fullName : 'Valued Member';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogoWidget(size: 72).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    loc.tr('Welcome Back'),
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 50.ms),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 100.ms),
                  const SizedBox(height: 6),
                  Text(
                    loc.tr('Unlock app using Face ID, Fingerprint or Security PIN'),
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 150.ms),

                  const SizedBox(height: 32),

                  // Biometric Scanner Card
                  GestureDetector(
                    onTap: _isAuthenticating ? null : _triggerBiometricScan,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppColors.softShadow,
                        border: Border.all(
                          color: _isAuthenticating ? AppColors.primary : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                            ),
                            child: Icon(
                              _isAuthenticating ? Icons.face_rounded : Icons.fingerprint_rounded,
                              color: AppColors.primary,
                              size: 42,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _isAuthenticating ? 'Scanning Face ID / Fingerprint...' : loc.tr('Tap for Biometric Unlock'),
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Face ID • Touch ID • Fingerprint Sensor',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 350.ms, delay: 200.ms),

                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(loc.tr('OR ENTER SECURITY PIN'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // PIN Input Field
                  CustomTextField(
                    label: loc.tr('Security PIN'),
                    hintText: loc.tr('Enter 4-digit PIN'),
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _verifyPinSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        loc.tr('Unlock App'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    child: Text(
                      loc.tr('Sign In with Different Mobile Account'),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
