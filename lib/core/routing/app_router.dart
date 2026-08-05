import 'package:go_router/go_router.dart';
import '../../common/navigation/main_wrapper_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/kuri/presentation/my_kuris_screen.dart';
import '../../features/kuri/presentation/kuri_details_screen.dart';
import '../../features/kuri/models/kuri_model.dart';
import '../../features/payment/presentation/payment_screen.dart';
import '../../features/payment/presentation/payment_success_screen.dart';
import '../../features/payment/presentation/passbook_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

import '../../features/settings/presentation/settings_screen.dart';

import '../../features/support/presentation/support_screen.dart';

import '../../features/profile/presentation/account_details_screen.dart';
import '../../features/profile/presentation/bank_details_screen.dart';
import '../../features/kuri/presentation/available_chitties_screen.dart';
import '../../features/kuri/presentation/kuri_application_screen.dart';
import '../../features/auth/presentation/quick_security_lock_screen.dart';

// Top level routes
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/quick-lock',
      name: 'quick-lock',
      builder: (context, state) => const QuickSecurityLockScreen(),
    ),
    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: '/kuri-details',
      name: 'kuri-details',
      builder: (context, state) {
        final kuri = state.extra as KuriModel?;
        return KuriDetailsScreen(kuri: kuri);
      },
    ),
    GoRoute(
      path: '/payment',
      name: 'payment',
      builder: (context, state) {
        final kuri = state.extra as KuriModel?;
        return PaymentScreen(kuri: kuri);
      },
    ),
    GoRoute(
      path: '/payment-success',
      name: 'payment-success',
      builder: (context, state) {
        final kuri = state.extra as KuriModel?;
        return PaymentSuccessScreen(kuri: kuri);
      },
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/support',
      name: 'support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      path: '/account-details',
      name: 'account-details',
      builder: (context, state) => const AccountDetailsScreen(),
    ),
    GoRoute(
      path: '/bank-details',
      name: 'bank-details',
      builder: (context, state) => const BankDetailsScreen(),
    ),
    GoRoute(
      path: '/available-chitties',
      name: 'available-chitties',
      builder: (context, state) => const AvailableChittiesScreen(),
    ),
    GoRoute(
      path: '/apply-kuri',
      name: 'apply-kuri',
      builder: (context, state) {
        final kuri = state.extra as KuriModel?;
        return KuriApplicationScreen(kuri: kuri);
      },
    ),

    // Bottom Navigation Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapperScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Tab 2: My Kuris
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-kuris',
              name: 'my-kuris',
              builder: (context, state) => const MyKurisScreen(),
            ),
          ],
        ),

        // Tab 3: Available Chitties (Join)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore-chitties',
              name: 'explore-chitties',
              builder: (context, state) => const AvailableChittiesScreen(),
            ),
          ],
        ),

        // Tab 4: Payments & Passbook
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/payments',
              name: 'payments',
              builder: (context, state) => const PassbookScreen(),
            ),
          ],
        ),

        // Tab 5: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
