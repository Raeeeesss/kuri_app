import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserSession {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String passcode;
  final bool isAuthenticated;
  final String aadhaar;
  final String pan;
  final String nominee;
  final String bankName;
  final String bankAccount;
  final String bankIfsc;
  final String upiId;

  const LocalUserSession({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.passcode,
    required this.isAuthenticated,
    this.aadhaar = '',
    this.pan = '',
    this.nominee = '',
    this.bankName = '',
    this.bankAccount = '',
    this.bankIfsc = '',
    this.upiId = '',
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'passcode': passcode,
        'isAuthenticated': isAuthenticated,
        'aadhaar': aadhaar,
        'pan': pan,
        'nominee': nominee,
        'bankName': bankName,
        'bankAccount': bankAccount,
        'bankIfsc': bankIfsc,
        'upiId': upiId,
      };

  factory LocalUserSession.fromJson(Map<String, dynamic> json) => LocalUserSession(
        fullName: json['fullName'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        email: json['email'] ?? '',
        passcode: json['passcode'] ?? '',
        isAuthenticated: json['isAuthenticated'] ?? false,
        aadhaar: json['aadhaar'] ?? '',
        pan: json['pan'] ?? '',
        nominee: json['nominee'] ?? '',
        bankName: json['bankName'] ?? '',
        bankAccount: json['bankAccount'] ?? '',
        bankIfsc: json['bankIfsc'] ?? '',
        upiId: json['upiId'] ?? '',
      );
}

class LocalStorageService {
  static const String _keyRegisteredUsers = 'registered_users_map';
  static const String _keyActivePhone = 'active_user_phone';
  static const String _keyIsAuth = 'user_is_authenticated';

  // Default demo registered user account
  static const LocalUserSession _demoUser = LocalUserSession(
    fullName: 'Anand Nair',
    phoneNumber: '9876543210',
    email: 'anand.nair@keralakuri.com',
    passcode: '1234',
    isAuthenticated: false,
  );

  /// Internal helper to load persistent registry of registered users
  static Future<Map<String, LocalUserSession>> _getRegisteredUsersMap() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyRegisteredUsers);
    final Map<String, LocalUserSession> users = {
      _demoUser.phoneNumber: _demoUser,
    };

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        decoded.forEach((key, value) {
          users[key] = LocalUserSession.fromJson(Map<String, dynamic>.from(value));
        });
      } catch (_) {}
    }
    return users;
  }

  /// Internal helper to save persistent registry of registered users
  static Future<void> _saveRegisteredUsersMap(Map<String, LocalUserSession> users) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> mapToSave = {};
    users.forEach((key, value) {
      mapToSave[key] = value.toJson();
    });
    await prefs.setString(_keyRegisteredUsers, jsonEncode(mapToSave));
  }

  /// Register a new user persistently
  static Future<void> registerNewUser({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String passcode,
  }) async {
    final users = await _getRegisteredUsersMap();
    final newUser = LocalUserSession(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      passcode: passcode,
      isAuthenticated: true,
    );
    users[phoneNumber] = newUser;
    await _saveRegisteredUsersMap(users);
    await saveUserSession(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      passcode: passcode,
      isAuthenticated: true,
    );
  }

  /// Retrieve a registered user by mobile phone number
  static Future<LocalUserSession?> getRegisteredUser(String phone) async {
    final users = await _getRegisteredUsersMap();
    return users[phone.trim()];
  }

  /// Save active user session to local storage
  static Future<void> saveUserSession({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String passcode,
    required bool isAuthenticated,
    String? aadhaar,
    String? pan,
    String? nominee,
    String? bankName,
    String? bankAccount,
    String? bankIfsc,
    String? upiId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActivePhone, phoneNumber);
    await prefs.setBool(_keyIsAuth, isAuthenticated);

    final users = await _getRegisteredUsersMap();
    final existing = users[phoneNumber];
    final updated = LocalUserSession(
      fullName: fullName.isNotEmpty ? fullName : (existing?.fullName ?? ''),
      phoneNumber: phoneNumber,
      email: email.isNotEmpty ? email : (existing?.email ?? ''),
      passcode: passcode.isNotEmpty ? passcode : (existing?.passcode ?? ''),
      isAuthenticated: isAuthenticated,
      aadhaar: aadhaar ?? existing?.aadhaar ?? '',
      pan: pan ?? existing?.pan ?? '',
      nominee: nominee ?? existing?.nominee ?? '',
      bankName: bankName ?? existing?.bankName ?? '',
      bankAccount: bankAccount ?? existing?.bankAccount ?? '',
      bankIfsc: bankIfsc ?? existing?.bankIfsc ?? '',
      upiId: upiId ?? existing?.upiId ?? '',
    );
    users[phoneNumber] = updated;
    await _saveRegisteredUsersMap(users);
  }

  /// Retrieve active user session from local storage
  static Future<LocalUserSession?> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString(_keyActivePhone);
    final users = await _getRegisteredUsersMap();

    if (phone != null && users.containsKey(phone)) {
      final u = users[phone]!;
      final isAuth = prefs.getBool(_keyIsAuth) ?? false;
      return LocalUserSession(
        fullName: u.fullName,
        phoneNumber: u.phoneNumber,
        email: u.email,
        passcode: u.passcode,
        isAuthenticated: isAuth,
        aadhaar: u.aadhaar,
        pan: u.pan,
        nominee: u.nominee,
        bankName: u.bankName,
        bankAccount: u.bankAccount,
        bankIfsc: u.bankIfsc,
        upiId: u.upiId,
      );
    }

    return null;
  }

  /// Clear active user session on logout (preserves registered accounts and paid status)
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAuth, false);
    await prefs.remove(_keyActivePhone);
  }

  static const String _keyPaidKuris = 'paid_kuris_ids_list';

  /// Save a Kuri ID as paid persistently so state survives logout/login
  static Future<void> markKuriPaidPersistent(String kuriId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPaidKuris) ?? [];
    if (!list.contains(kuriId)) {
      list.add(kuriId);
      await prefs.setStringList(_keyPaidKuris, list);
    }
  }

  /// Get set of persistently paid Kuri IDs
  static Future<Set<String>> getPaidKuriIdsPersistent() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyPaidKuris) ?? [];
    return list.toSet();
  }

  static const String _keySettingsLang = 'settings_language';
  static const String _keySettingsDarkMode = 'settings_dark_mode';
  static const String _keySettingsBiometric = 'settings_biometric';
  static const String _keySettingsNotifications = 'settings_notifications';

  /// Save user settings preferences persistently
  static Future<void> saveSettings({
    required String language,
    required bool isDarkMode,
    required bool isBiometricEnabled,
    required bool isNotificationsEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettingsLang, language);
    await prefs.setBool(_keySettingsDarkMode, isDarkMode);
    await prefs.setBool(_keySettingsBiometric, isBiometricEnabled);
    await prefs.setBool(_keySettingsNotifications, isNotificationsEnabled);
  }

  /// Load user settings preferences from storage
  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'language': prefs.getString(_keySettingsLang) ?? 'English',
      'isDarkMode': prefs.getBool(_keySettingsDarkMode) ?? false,
      'isBiometricEnabled': prefs.getBool(_keySettingsBiometric) ?? true,
      'isNotificationsEnabled': prefs.getBool(_keySettingsNotifications) ?? true,
    };
  }
}
