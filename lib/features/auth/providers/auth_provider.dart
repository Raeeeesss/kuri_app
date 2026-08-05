import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage_service.dart';

enum AuthMode { signIn, signUp }

class AuthState {
  final AuthMode mode;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String passcode;
  final String otpCode;
  final bool isLoading;
  final bool isVerifying;
  final String? errorMessage;
  final bool isAuthenticated;
  final int resendTimerSeconds;
  final bool canResendOtp;

  AuthState({
    this.mode = AuthMode.signIn,
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
    this.passcode = '',
    this.otpCode = '',
    this.isLoading = false,
    this.isVerifying = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.resendTimerSeconds = 30,
    this.canResendOtp = false,
  });

  AuthState copyWith({
    AuthMode? mode,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? passcode,
    String? otpCode,
    bool? isLoading,
    bool? isVerifying,
    String? errorMessage,
    bool? isAuthenticated,
    int? resendTimerSeconds,
    bool? canResendOtp,
  }) {
    return AuthState(
      mode: mode ?? this.mode,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      passcode: passcode ?? this.passcode,
      otpCode: otpCode ?? this.otpCode,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      resendTimerSeconds: resendTimerSeconds ?? this.resendTimerSeconds,
      canResendOtp: canResendOtp ?? this.canResendOtp,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  Timer? _resendTimer;

  AuthNotifier() : super(AuthState()) {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final saved = await LocalStorageService.getUserSession();
    if (saved != null) {
      state = state.copyWith(
        fullName: saved.fullName,
        phoneNumber: saved.phoneNumber,
        email: saved.email,
        passcode: saved.passcode,
        isAuthenticated: saved.isAuthenticated,
      );
    }
  }

  void setAuthMode(AuthMode mode) {
    state = state.copyWith(mode: mode, errorMessage: null);
  }

  void setFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setEmail(String mail) {
    state = state.copyWith(email: mail);
  }

  void setPasscode(String pin) {
    state = state.copyWith(passcode: pin);
  }

  void setOtpCode(String code) {
    state = state.copyWith(otpCode: code);
  }

  void startResendTimer() {
    _resendTimer?.cancel();
    state = state.copyWith(resendTimerSeconds: 30, canResendOtp: false);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendTimerSeconds > 1) {
        state = state.copyWith(resendTimerSeconds: state.resendTimerSeconds - 1);
      } else {
        state = state.copyWith(resendTimerSeconds: 0, canResendOtp: true);
        timer.cancel();
      }
    });
  }

  Future<bool> authenticate() async {
    final phone = state.phoneNumber.trim();
    final pin = state.passcode.trim();

    if (state.mode == AuthMode.signUp && state.fullName.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your full name');
      return false;
    }
    if (phone.length < 10) {
      state = state.copyWith(errorMessage: 'Please enter a valid 10-digit mobile number');
      return false;
    }
    if (pin.length < 4) {
      state = state.copyWith(errorMessage: 'Please enter a 4-digit passcode');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 500));

    if (state.mode == AuthMode.signIn) {
      // 1. Look up registered user by phone number
      final registeredUser = await LocalStorageService.getRegisteredUser(phone);

      if (registeredUser == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No registered account found with this number. Please Sign Up first.',
        );
        return false;
      }

      // 2. Verify passcode
      if (registeredUser.passcode != pin) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Incorrect passcode. Please try again.',
        );
        return false;
      }

      // 3. Authenticate active session
      await LocalStorageService.saveUserSession(
        fullName: registeredUser.fullName,
        phoneNumber: registeredUser.phoneNumber,
        email: registeredUser.email,
        passcode: registeredUser.passcode,
        isAuthenticated: true,
        aadhaar: registeredUser.aadhaar,
        pan: registeredUser.pan,
        nominee: registeredUser.nominee,
        bankName: registeredUser.bankName,
        bankAccount: registeredUser.bankAccount,
        bankIfsc: registeredUser.bankIfsc,
        upiId: registeredUser.upiId,
      );

      state = state.copyWith(
        fullName: registeredUser.fullName,
        email: registeredUser.email,
        phoneNumber: registeredUser.phoneNumber,
        passcode: registeredUser.passcode,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } else {
      // Sign Up mode
      final existing = await LocalStorageService.getRegisteredUser(phone);
      if (existing != null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'An account with this number already exists. Please Sign In.',
        );
        return false;
      }

      final newName = state.fullName.trim();
      await LocalStorageService.registerNewUser(
        fullName: newName,
        phoneNumber: phone,
        email: state.email,
        passcode: pin,
      );

      state = state.copyWith(
        fullName: newName,
        phoneNumber: phone,
        passcode: pin,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    }
  }

  Future<bool> verifyOtp() async {
    if (state.otpCode.length < 4) {
      state = state.copyWith(errorMessage: 'Please enter complete 4-digit OTP');
      return false;
    }

    state = state.copyWith(isVerifying: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 1000));

    // Save authenticated session in local storage
    await LocalStorageService.saveUserSession(
      fullName: state.fullName,
      phoneNumber: state.phoneNumber,
      email: state.email,
      passcode: state.passcode,
      isAuthenticated: true,
    );

    state = state.copyWith(isVerifying: false, isAuthenticated: true);
    return true;
  }

  void resendOtp() {
    if (!state.canResendOtp) return;
    startResendTimer();
  }

  Future<void> logout() async {
    _resendTimer?.cancel();
    await LocalStorageService.clearUserSession();
    state = AuthState();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
