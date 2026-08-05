enum BiometricType { fingerprint, faceId, pinFallback }

class BiometricResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricType usedType;

  const BiometricResult({
    required this.isSuccess,
    this.errorMessage,
    required this.usedType,
  });
}

class BiometricService {
  /// Simulates biometric authentication (Fingerprint / Face ID) with PIN fallback.
  static Future<BiometricResult> authenticate({
    String reason = 'Verify your identity to access Kerala Kuri',
    bool allowPinFallback = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const BiometricResult(
      isSuccess: true,
      usedType: BiometricType.fingerprint,
    );
  }
}
