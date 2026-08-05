import '../models/kuri_model.dart';

abstract class IKuriRepository {
  Future<List<KuriModel>> fetchUserKuris();
  Future<List<KuriModel>> fetchAvailableKuris();
  Future<KuriModel?> getKuriById(String id);
  Future<bool> joinKuri(String kuriId, int ticketsCount);
}

class KuriRepository implements IKuriRepository {
  @override
  Future<List<KuriModel>> fetchUserKuris() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      KuriModel(
        id: '1',
        title: 'Premium Gold - Oct 2024',
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
        code: 'FS-012',
        monthlyAmount: 10000.0,
        totalAmount: 500000.0,
        completedInstallments: 50,
        totalInstallments: 50,
        nextDueDate: DateTime(2023, 12, 10),
        status: 'COMPLETED',
        frequency: 'Monthly',
      ),
    ];
  }

  @override
  Future<List<KuriModel>> fetchAvailableKuris() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      KuriModel(
        id: '5',
        title: 'Kerala Diamond Savings Scheme',
        code: 'KD-901',
        monthlyAmount: 20000.0,
        totalAmount: 600000.0,
        completedInstallments: 0,
        totalInstallments: 30,
        nextDueDate: DateTime(2024, 11, 15),
        status: 'ACTIVE',
        availableSeats: 8,
      ),
      KuriModel(
        id: '6',
        title: 'Smart Lakhpati Monthly Kuri',
        code: 'SL-202',
        monthlyAmount: 5000.0,
        totalAmount: 200000.0,
        completedInstallments: 0,
        totalInstallments: 40,
        nextDueDate: DateTime(2024, 11, 20),
        status: 'ACTIVE',
        availableSeats: 14,
      ),
    ];
  }

  @override
  Future<KuriModel?> getKuriById(String id) async {
    final koris = await fetchUserKuris();
    return koris.firstWhere(
      (k) => k.id == id,
      orElse: () => koris.isNotEmpty ? koris.first : KuriModel(id: '1', title: 'Default Chitty', code: 'GK-100', monthlyAmount: 5000, totalAmount: 100000, completedInstallments: 0, totalInstallments: 20, status: 'ACTIVE', nextDueDate: DateTime(2024, 11, 1)),
    );
  }

  @override
  Future<bool> joinKuri(String kuriId, int ticketsCount) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }
}
