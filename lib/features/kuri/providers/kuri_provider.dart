import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/local_storage_service.dart';
import '../models/kuri_model.dart';

enum KuriFilter { all, active, completed }

class KuriListState {
  final KuriFilter selectedFilter;
  final List<KuriModel> koris;
  final bool isLoading;

  const KuriListState({
    this.selectedFilter = KuriFilter.all,
    this.koris = const [],
    this.isLoading = false,
  });

  List<KuriModel> get filteredKuris {
    switch (selectedFilter) {
      case KuriFilter.active:
        return koris.where((k) => !k.isCompleted).toList();
      case KuriFilter.completed:
        return koris.where((k) => k.isCompleted).toList();
      case KuriFilter.all:
        return koris;
    }
  }

  KuriListState copyWith({
    KuriFilter? selectedFilter,
    List<KuriModel>? koris,
    bool? isLoading,
  }) {
    return KuriListState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      koris: koris ?? this.koris,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class KuriNotifier extends StateNotifier<KuriListState> {
  KuriNotifier()
      : super(
          KuriListState(
            koris: [
              KuriModel(
                id: '1',
                title: 'Premium Gold - Oct 2024',
                titleEn: 'Premium Gold - Oct 2024',
                titleMl: 'പ്രീമിയം ഗോൾഡ് - ഒക്ടോബർ 2024',
                code: 'GK-102',
                monthlyAmount: 12500.0,
                totalAmount: 375000.0,
                completedInstallments: 12,
                totalInstallments: 30,
                nextDueDate: DateTime(2024, 10, 15),
                status: 'DUE_SOON',
                frequency: 'Monthly',
              ),
              KuriModel(
                id: '2',
                title: 'Weekly Gold Savings Chitty',
                titleEn: 'Weekly Gold Savings Chitty',
                titleMl: 'വീക്കിലി ഗോൾഡ് സേവിംഗ്സ് ചിട്ടി',
                code: 'SK-405',
                monthlyAmount: 2500.0,
                totalAmount: 125000.0,
                completedInstallments: 18,
                totalInstallments: 50,
                nextDueDate: DateTime(2024, 10, 22),
                status: 'PAID',
                frequency: 'Weekly',
              ),
              KuriModel(
                id: '3',
                title: 'Business Growth Chitty',
                titleEn: 'Business Growth Chitty',
                titleMl: 'ബിസിനസ്സ് ഗ്രോത്ത് ചിട്ടി',
                code: 'BK-880',
                monthlyAmount: 25000.0,
                totalAmount: 1000000.0,
                completedInstallments: 5,
                totalInstallments: 40,
                nextDueDate: DateTime(2024, 11, 5),
                status: 'ACTIVE',
                frequency: 'Monthly',
              ),
              KuriModel(
                id: '4',
                title: 'Festive Special Scheme',
                titleEn: 'Festive Special Scheme',
                titleMl: 'ഫെസ്റ്റീവ് സ്പെഷ്യൽ ചിട്ടി',
                code: 'FS-012',
                monthlyAmount: 10000.0,
                totalAmount: 500000.0,
                completedInstallments: 50,
                totalInstallments: 50,
                nextDueDate: DateTime(2023, 12, 10),
                status: 'COMPLETED',
                frequency: 'Monthly',
              ),
            ],
          ),
        ) {
    _loadSavedPaidState();
  }

  Future<void> _loadSavedPaidState() async {
    final paidSet = await LocalStorageService.getPaidKuriIdsPersistent();
    if (paidSet.isEmpty) return;

    final updated = state.koris.map((kuri) {
      if (paidSet.contains(kuri.id) && kuri.status != 'COMPLETED') {
        final newCompleted = kuri.completedInstallments < kuri.totalInstallments
            ? kuri.completedInstallments + 1
            : kuri.completedInstallments;
        return kuri.copyWith(
          completedInstallments: newCompleted,
          status: 'PAID',
        );
      }
      return kuri;
    }).toList();

    state = state.copyWith(koris: updated);
  }

  void setFilter(KuriFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void markInstallmentAsPaid(String kuriId) async {
    await LocalStorageService.markKuriPaidPersistent(kuriId);

    final updatedList = state.koris.map((kuri) {
      if (kuri.id == kuriId) {
        final newCompleted = kuri.completedInstallments + 1;
        final isFinished = newCompleted >= kuri.totalInstallments;
        final nextDate = kuri.frequency == 'Weekly'
            ? kuri.nextDueDate.add(const Duration(days: 7))
            : DateTime(kuri.nextDueDate.year, kuri.nextDueDate.month + 1, kuri.nextDueDate.day);

        return kuri.copyWith(
          completedInstallments: newCompleted,
          status: isFinished ? 'COMPLETED' : 'PAID',
          nextDueDate: nextDate,
        );
      }
      return kuri;
    }).toList();

    state = state.copyWith(koris: updatedList);
  }
}

final kuriListProvider = StateNotifierProvider<KuriNotifier, KuriListState>((ref) {
  return KuriNotifier();
});
