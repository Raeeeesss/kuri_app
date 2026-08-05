import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/passbook_entry_model.dart';

enum PassbookFilter { all, paid, due }
enum PassbookPeriodFilter { all, monthly, weekly, yearly }

class PassbookState {
  final PassbookFilter filter;
  final PassbookPeriodFilter periodFilter;
  final String selectedSchemeCode; // 'ALL' or specific code like 'GK-102'
  final String searchQuery;
  final List<PassbookEntry> entries;
  final bool isDownloadingPdf;

  const PassbookState({
    this.filter = PassbookFilter.all,
    this.periodFilter = PassbookPeriodFilter.all,
    this.selectedSchemeCode = 'ALL',
    this.searchQuery = '',
    this.entries = const [],
    this.isDownloadingPdf = false,
  });

  List<PassbookEntry> get filteredEntries {
    return entries.where((entry) {
      // Filter by status
      if (filter == PassbookFilter.paid && !entry.isPaid) return false;
      if (filter == PassbookFilter.due && !entry.isDue) return false;

      // Filter by period / frequency
      if (periodFilter == PassbookPeriodFilter.weekly && !entry.kuriTitle.toLowerCase().contains('weekly')) {
        return false;
      }
      if (periodFilter == PassbookPeriodFilter.monthly && entry.kuriTitle.toLowerCase().contains('weekly')) {
        return false;
      }
      if (periodFilter == PassbookPeriodFilter.yearly && !entry.kuriTitle.toLowerCase().contains('yearly')) {
        return false;
      }

      // Filter by scheme code
      if (selectedSchemeCode != 'ALL' && entry.kuriCode != selectedSchemeCode) {
        return false;
      }

      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = entry.kuriTitle.toLowerCase().contains(query);
        final matchesCode = entry.kuriCode.toLowerCase().contains(query);
        final matchesTxn = entry.transactionId.toLowerCase().contains(query);
        final matchesMethod = entry.paymentMethod.toLowerCase().contains(query);
        return matchesTitle || matchesCode || matchesTxn || matchesMethod;
      }

      return true;
    }).toList();
  }

  double get totalPaidAmount {
    return filteredEntries
        .where((e) => e.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  int get totalPaidCount {
    return filteredEntries.where((e) => e.isPaid).length;
  }

  double get totalDueAmount {
    return filteredEntries
        .where((e) => e.isDue)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  PassbookState copyWith({
    PassbookFilter? filter,
    PassbookPeriodFilter? periodFilter,
    String? selectedSchemeCode,
    String? searchQuery,
    List<PassbookEntry>? entries,
    bool? isDownloadingPdf,
  }) {
    return PassbookState(
      filter: filter ?? this.filter,
      periodFilter: periodFilter ?? this.periodFilter,
      selectedSchemeCode: selectedSchemeCode ?? this.selectedSchemeCode,
      searchQuery: searchQuery ?? this.searchQuery,
      entries: entries ?? this.entries,
      isDownloadingPdf: isDownloadingPdf ?? this.isDownloadingPdf,
    );
  }
}

class PassbookNotifier extends StateNotifier<PassbookState> {
  PassbookNotifier()
      : super(
          PassbookState(
            entries: [
              PassbookEntry(
                id: 'p1',
                kuriTitle: 'Premium Gold - Oct 2024',
                kuriCode: 'GK-102',
                installmentNumber: 13,
                amount: 11000.0,
                date: DateTime(2024, 10, 15),
                paymentMethod: 'Pending (Due)',
                transactionId: 'TXN-PENDING-13',
                status: 'DUE',
              ),
              PassbookEntry(
                id: 'p2',
                kuriTitle: 'Premium Gold - Oct 2024',
                kuriCode: 'GK-102',
                installmentNumber: 12,
                amount: 12500.0,
                date: DateTime(2024, 9, 10, 16, 30),
                paymentMethod: 'Google Pay / UPI',
                transactionId: 'TXN882941092',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p3',
                kuriTitle: 'Weekly Gold Savings Chitty',
                kuriCode: 'SK-405',
                installmentNumber: 18,
                amount: 2500.0,
                date: DateTime(2024, 9, 28, 11, 15),
                paymentMethod: 'PhonePe UPI',
                transactionId: 'TXN559102938',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p4',
                kuriTitle: 'Business Growth Chitty',
                kuriCode: 'BK-880',
                installmentNumber: 5,
                amount: 25000.0,
                date: DateTime(2024, 9, 5, 14, 20),
                paymentMethod: 'Net Banking (ICICI)',
                transactionId: 'TXN448201923',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p5',
                kuriTitle: 'Premium Gold - Oct 2024',
                kuriCode: 'GK-102',
                installmentNumber: 11,
                amount: 12500.0,
                date: DateTime(2024, 8, 10, 10, 45),
                paymentMethod: 'Net Banking (SBI)',
                transactionId: 'TXN771049281',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p6',
                kuriTitle: 'Weekly Gold Savings Chitty',
                kuriCode: 'SK-405',
                installmentNumber: 17,
                amount: 2500.0,
                date: DateTime(2024, 9, 21, 18, 00),
                paymentMethod: 'Google Pay / UPI',
                transactionId: 'TXN559102810',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p7',
                kuriTitle: 'Business Growth Chitty',
                kuriCode: 'BK-880',
                installmentNumber: 4,
                amount: 25000.0,
                date: DateTime(2024, 8, 5, 09, 30),
                paymentMethod: 'Net Banking (HDFC)',
                transactionId: 'TXN448200192',
                status: 'SUCCESS',
              ),
              PassbookEntry(
                id: 'p8',
                kuriTitle: 'Festive Special Scheme',
                kuriCode: 'FS-012',
                installmentNumber: 50,
                amount: 10000.0,
                date: DateTime(2023, 12, 10, 12, 00),
                paymentMethod: 'Federal Bank NetBanking',
                transactionId: 'TXN330192847',
                status: 'SUCCESS',
              ),
            ],
          ),
        );

  void setFilter(PassbookFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setPeriodFilter(PassbookPeriodFilter periodFilter) {
    state = state.copyWith(periodFilter: periodFilter);
  }

  void setSchemeFilter(String schemeCode) {
    state = state.copyWith(selectedSchemeCode: schemeCode);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addPaidEntry({
    required String kuriTitle,
    required String kuriCode,
    required int installmentNumber,
    required double amount,
    required String paymentMethod,
    required String transactionId,
  }) {
    // Remove any pending due entry for this installment
    final updatedList = state.entries.where((e) => !(e.kuriCode == kuriCode && e.installmentNumber == installmentNumber)).toList();

    final newEntry = PassbookEntry(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      kuriTitle: kuriTitle,
      kuriCode: kuriCode,
      installmentNumber: installmentNumber,
      amount: amount,
      date: DateTime.now(),
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      status: 'SUCCESS',
    );

    state = state.copyWith(entries: [newEntry, ...updatedList]);
  }

  Future<bool> generatePassbookPdf() async {
    state = state.copyWith(isDownloadingPdf: true);
    await Future.delayed(const Duration(milliseconds: 1500));
    state = state.copyWith(isDownloadingPdf: false);
    return true;
  }
}

final passbookProvider =
    StateNotifierProvider<PassbookNotifier, PassbookState>((ref) {
  return PassbookNotifier();
});
