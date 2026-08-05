import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../kuri/models/kuri_model.dart';
import '../../kuri/providers/kuri_provider.dart';
import '../../notifications/providers/notifications_provider.dart';

enum HomePeriodFilter { all, monthly, weekly, yearly }

final homePeriodFilterProvider = StateProvider<HomePeriodFilter>((ref) => HomePeriodFilter.all);

class HomeDashboardState {
  final String userName;
  final double nextDueAmount;
  final DateTime nextDueDate;
  final int activeKurisCount;
  final int unreadNotificationsCount;
  final List<KuriModel> activeKuris;
  final bool hasDueSoonKuri;
  final bool isLoading;

  const HomeDashboardState({
    required this.userName,
    this.nextDueAmount = 12500.0,
    required this.nextDueDate,
    this.activeKurisCount = 3,
    this.unreadNotificationsCount = 0,
    this.activeKuris = const [],
    this.hasDueSoonKuri = true,
    this.isLoading = false,
  });
}

final homeDashboardProvider = Provider<HomeDashboardState>((ref) {
  final kuriListState = ref.watch(kuriListProvider);
  final authState = ref.watch(authProvider);
  final notifications = ref.watch(notificationsProvider);
  final selectedPeriod = ref.watch(homePeriodFilterProvider);

  final unreadNotificationsCount = notifications.where((n) => !n.isRead).length;
  final koris = kuriListState.koris;

  // Active Kuries (non-completed)
  List<KuriModel> activeKuris = koris.where((k) => !k.isCompleted).toList();

  // Filter by selected period
  if (selectedPeriod == HomePeriodFilter.monthly) {
    activeKuris = activeKuris.where((k) => k.frequency == 'Monthly').toList();
  } else if (selectedPeriod == HomePeriodFilter.weekly) {
    activeKuris = activeKuris.where((k) => k.frequency == 'Weekly').toList();
  } else if (selectedPeriod == HomePeriodFilter.yearly) {
    activeKuris = activeKuris.where((k) => k.frequency == 'Yearly').toList();
  }

  // Find due soon Kuries
  final dueKuris = activeKuris.where((k) => k.isDueSoon || k.status == 'DUE_SOON').toList();

  // Calculate total next due amount across due soon Kuries using netPayableAmount
  final nextDueAmount = dueKuris.isNotEmpty
      ? dueKuris.fold(0.0, (sum, k) => sum + k.netPayableAmount)
      : 0.0;

  final nextDueDate = dueKuris.isNotEmpty
      ? dueKuris.first.nextDueDate
      : (activeKuris.isNotEmpty ? activeKuris.first.nextDueDate : DateTime.now().add(const Duration(days: 30)));

  final userName = authState.fullName.trim().isNotEmpty
      ? authState.fullName.trim()
      : 'User';

  return HomeDashboardState(
    userName: userName,
    nextDueAmount: nextDueAmount,
    nextDueDate: nextDueDate,
    activeKurisCount: activeKuris.length,
    unreadNotificationsCount: unreadNotificationsCount,
    activeKuris: activeKuris,
    hasDueSoonKuri: dueKuris.isNotEmpty,
  );
});
