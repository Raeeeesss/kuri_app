import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/kuri_model.dart';
import 'kuri_provider.dart';

enum AvailableChittyFilter { all, newOnly, joined }

class AvailableChittyItem {
  final KuriModel kuri;
  final bool isAlreadyJoined;

  const AvailableChittyItem({
    required this.kuri,
    required this.isAlreadyJoined,
  });
}

final chittyFilterProvider = StateProvider<AvailableChittyFilter>((ref) => AvailableChittyFilter.all);

final availableChittiesProvider = Provider<List<AvailableChittyItem>>((ref) {
  final userKuris = ref.watch(kuriListProvider).koris;
  final userCodes = userKuris.map((k) => k.code).toSet();
  final currentFilter = ref.watch(chittyFilterProvider);

  final newCatalog = [
    KuriModel(
      id: '5',
      title: 'Kerala Diamond Savings Scheme',
      titleEn: 'Kerala Diamond Savings Scheme',
      titleMl: 'കേരള ഡയമണ്ട് സേവിംഗ്സ് ചിട്ടി',
      code: 'KD-901',
      monthlyAmount: 20000.0,
      totalAmount: 600000.0,
      completedInstallments: 0,
      totalInstallments: 30,
      nextDueDate: DateTime(2024, 11, 15),
      status: 'ACTIVE',
      availableSeats: 8,
      description: 'High dividend diamond savings scheme with monthly auctions.',
    ),
    KuriModel(
      id: '6',
      title: 'Smart Lakhpati Monthly Kuri',
      titleEn: 'Smart Lakhpati Monthly Kuri',
      titleMl: 'സ്മാർട്ട് ലക്ഷാധിപതി മാസ ചിട്ടി',
      code: 'SL-202',
      monthlyAmount: 5000.0,
      totalAmount: 200000.0,
      completedInstallments: 0,
      totalInstallments: 40,
      nextDueDate: DateTime(2024, 11, 20),
      status: 'ACTIVE',
      availableSeats: 14,
      description: 'Affordable monthly savings scheme designed for small business owners.',
    ),
    KuriModel(
      id: '7',
      title: 'Mega Silver Bumper Kuri',
      titleEn: 'Mega Silver Bumper Kuri',
      titleMl: 'മെഗാ സിൽവർ ബമ്പർ ചിട്ടി',
      code: 'MS-707',
      monthlyAmount: 10000.0,
      totalAmount: 400000.0,
      completedInstallments: 0,
      totalInstallments: 40,
      nextDueDate: DateTime(2024, 12, 1),
      status: 'ACTIVE',
      availableSeats: 22,
      description: 'Festive special bumper scheme with early payment bonus perks.',
    ),
  ];

  final List<AvailableChittyItem> joinedItems = [];
  final List<AvailableChittyItem> newItems = [];

  // Add user joined Kuries
  for (final userKuri in userKuris) {
    joinedItems.add(AvailableChittyItem(
      kuri: userKuri,
      isAlreadyJoined: true,
    ));
  }

  // Add new unjoined Chitties
  for (final newKuri in newCatalog) {
    if (!userCodes.contains(newKuri.code)) {
      newItems.add(AvailableChittyItem(
        kuri: newKuri,
        isAlreadyJoined: false,
      ));
    }
  }

  switch (currentFilter) {
    case AvailableChittyFilter.newOnly:
      return newItems;
    case AvailableChittyFilter.joined:
      return joinedItems;
    case AvailableChittyFilter.all:
      // Show NEW unjoined Chitties at the TOP, and ALREADY JOINED Chitties BELOW
      return [...newItems, ...joinedItems];
  }
});
