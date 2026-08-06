import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/permission_dialog.dart';

import '../../core/update/update_dialog.dart';
import '../../core/update/update_provider.dart';

class MainWrapperScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends ConsumerState<MainWrapperScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await PermissionDialog.checkAndShow(context);
        if (!mounted) return;

        // Silent background update check
        final updateNotifier = ref.read(updateProvider.notifier);
        await updateNotifier.checkForUpdates(isManual: false);

        final updateState = ref.read(updateProvider);
        if (mounted && updateState.status == UpdateStatus.available && updateState.updateInfo != null) {
          UpdateDialog.show(context);
        }
      }
    });
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(appLocalizationsProvider);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              selectedLabelStyle: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: AppColors.primary,
              ),
              unselectedLabelStyle: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: AppColors.textMuted,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined, size: 24),
                  activeIcon: const Icon(Icons.home_rounded, size: 24),
                  label: loc.tr('Home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 24),
                  activeIcon: const Icon(Icons.account_balance_wallet_rounded, size: 24),
                  label: loc.tr('My Kuris'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.add_business_outlined, size: 24),
                  activeIcon: const Icon(Icons.add_business_rounded, size: 24),
                  label: loc.tr('Explore Chitties'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt_long_outlined, size: 24),
                  activeIcon: const Icon(Icons.receipt_long_rounded, size: 24),
                  label: loc.tr('Payments & Passbook'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline_rounded, size: 24),
                  activeIcon: const Icon(Icons.person_rounded, size: 24),
                  label: loc.tr('My Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
