import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../auth/providers/auth_provider.dart';

class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String memberId;
  final bool isKycVerified;
  final String aadhaar;
  final String pan;
  final String nominee;
  final String bankName;
  final String bankAccount;
  final String bankIfsc;
  final String upiId;

  const UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    this.memberId = 'KR-98421',
    this.isKycVerified = false,
    this.aadhaar = '',
    this.pan = '',
    this.nominee = '',
    this.bankName = '',
    this.bankAccount = '',
    this.bankIfsc = '',
    this.upiId = '',
  });

  bool get isEmailVerified => email.trim().isNotEmpty;
  bool get isAadhaarAdded => aadhaar.trim().isNotEmpty;
  bool get isPanAdded => pan.trim().isNotEmpty;
  bool get isNomineeAdded => nominee.trim().isNotEmpty;
  bool get isBankAdded => bankAccount.trim().isNotEmpty;

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final Ref ref;

  UserProfileNotifier(this.ref)
      : super(const UserProfile(name: '', phone: '', email: '')) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authState = ref.read(authProvider);
    final savedSession = await LocalStorageService.getUserSession();

    final name = authState.fullName.trim().isNotEmpty
        ? authState.fullName.trim()
        : (savedSession?.fullName.trim().isNotEmpty == true
            ? savedSession!.fullName.trim()
            : 'User');

    final phone = authState.phoneNumber.trim().isNotEmpty
        ? authState.phoneNumber.trim()
        : (savedSession?.phoneNumber.trim().isNotEmpty == true
            ? savedSession!.phoneNumber.trim()
            : '');

    state = UserProfile(
      name: name,
      phone: phone,
      email: savedSession?.email ?? authState.email,
      aadhaar: savedSession?.aadhaar ?? '',
      pan: savedSession?.pan ?? '',
      nominee: savedSession?.nominee ?? '',
      bankName: savedSession?.bankName ?? '',
      bankAccount: savedSession?.bankAccount ?? '',
      bankIfsc: savedSession?.bankIfsc ?? '',
      upiId: savedSession?.upiId ?? '',
      isKycVerified: (savedSession?.aadhaar.isNotEmpty == true &&
          savedSession?.pan.isNotEmpty == true),
    );
  }

  Future<void> updateKycDetails({
    String? email,
    String? aadhaar,
    String? pan,
    String? nominee,
  }) async {
    final updatedEmail = email ?? state.email;
    final updatedAadhaar = aadhaar ?? state.aadhaar;
    final updatedPan = pan ?? state.pan;
    final updatedNominee = nominee ?? state.nominee;

    final isKyc = updatedAadhaar.trim().isNotEmpty && updatedPan.trim().isNotEmpty;

    state = UserProfile(
      name: state.name,
      phone: state.phone,
      email: updatedEmail,
      aadhaar: updatedAadhaar,
      pan: updatedPan,
      nominee: updatedNominee,
      bankName: state.bankName,
      bankAccount: state.bankAccount,
      bankIfsc: state.bankIfsc,
      upiId: state.upiId,
      isKycVerified: isKyc,
    );

    final authState = ref.read(authProvider);
    await LocalStorageService.saveUserSession(
      fullName: authState.fullName,
      phoneNumber: authState.phoneNumber,
      email: updatedEmail,
      passcode: authState.passcode,
      isAuthenticated: true,
      aadhaar: updatedAadhaar,
      pan: updatedPan,
      nominee: updatedNominee,
      bankName: state.bankName,
      bankAccount: state.bankAccount,
      bankIfsc: state.bankIfsc,
      upiId: state.upiId,
    );
  }

  Future<void> updateBankDetails({
    required String bankName,
    required String bankAccount,
    required String bankIfsc,
    required String upiId,
  }) async {
    state = UserProfile(
      name: state.name,
      phone: state.phone,
      email: state.email,
      aadhaar: state.aadhaar,
      pan: state.pan,
      nominee: state.nominee,
      bankName: bankName,
      bankAccount: bankAccount,
      bankIfsc: bankIfsc,
      upiId: upiId,
      isKycVerified: state.isKycVerified,
    );

    final authState = ref.read(authProvider);
    await LocalStorageService.saveUserSession(
      fullName: authState.fullName,
      phoneNumber: authState.phoneNumber,
      email: state.email,
      passcode: authState.passcode,
      isAuthenticated: true,
      aadhaar: state.aadhaar,
      pan: state.pan,
      nominee: state.nominee,
      bankName: bankName,
      bankAccount: bankAccount,
      bankIfsc: bankIfsc,
      upiId: upiId,
    );
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});
