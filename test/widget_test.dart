import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuri_app/features/auth/presentation/login_screen.dart';
import 'package:kuri_app/features/auth/presentation/otp_screen.dart';
import 'package:kuri_app/features/home/presentation/home_screen.dart';
import 'package:kuri_app/features/kuri/presentation/my_kuris_screen.dart';
import 'package:kuri_app/features/kuri/presentation/kuri_details_screen.dart';
import 'package:kuri_app/features/payment/presentation/payment_screen.dart';
import 'package:kuri_app/features/payment/presentation/payment_success_screen.dart';
import 'package:kuri_app/features/notifications/presentation/notifications_screen.dart';
import 'package:kuri_app/features/profile/presentation/profile_screen.dart';
import 'package:kuri_app/features/settings/presentation/settings_screen.dart';
import 'package:kuri_app/features/support/presentation/support_screen.dart';

void main() {
  testWidgets('LoginScreen initial render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: LoginScreen())));
    await tester.pumpAndSettle();

    expect(find.text('KERALA KURI'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Passcode (4-Digit)'), findsOneWidget);
    expect(find.text('Log In Securely'), findsOneWidget);
  });

  testWidgets('OtpScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: OtpScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Verification'), findsOneWidget);
    expect(find.text('Verify & Proceed'), findsOneWidget);
  });

  testWidgets('HomeScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: HomeScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Mohammed Kurian'), findsOneWidget);
    expect(find.text('Your Active Kuris'), findsOneWidget);
  });

  testWidgets('MyKurisScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: MyKurisScreen())));
    await tester.pumpAndSettle();

    expect(find.text('My Kuris'), findsOneWidget);
  });

  testWidgets('KuriDetailsScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: KuriDetailsScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Kuri Details'), findsOneWidget);
    expect(find.text('Installment History'), findsOneWidget);
  });

  testWidgets('PaymentScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PaymentScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Chitty Payment'), findsOneWidget);
    expect(find.text('Select Payment Method'), findsOneWidget);
  });

  testWidgets('PaymentSuccessScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: PaymentSuccessScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(find.text('Go To Dashboard'), findsOneWidget);
  });

  testWidgets('NotificationsScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: NotificationsScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('ProfileScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: ProfileScreen())));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Mohammed Kurian'), findsOneWidget);
  });

  testWidgets('SettingsScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SettingsScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('General Preferences'), findsOneWidget);
  });

  testWidgets('SupportScreen render test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: SupportScreen())));
    await tester.pumpAndSettle();

    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Need Immediate Assistance?'), findsOneWidget);
  });
}
