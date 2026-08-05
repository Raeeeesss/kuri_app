import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier()
      : super([
          const NotificationModel(
            id: '1',
            title: 'Chitty Installment Due',
            message: '12th Installment for Premium Gold Scheme (₹12,500) is due on 15 Oct 2024.',
            timestamp: '2 hours ago',
            type: 'DUE',
            isRead: false,
          ),
          const NotificationModel(
            id: '2',
            title: 'Dividend Credited Successfully',
            message: 'Dividend of ₹1,450 credited to your active chitty account.',
            timestamp: '1 day ago',
            type: 'DIVIDEND',
            isRead: false,
          ),
          const NotificationModel(
            id: '3',
            title: 'Auction Date Announcement',
            message: 'Upcoming auction for Weekly Gold Scheme set for 20 Nov 2024 at 11:00 AM.',
            timestamp: '3 days ago',
            type: 'AUCTION',
            isRead: true,
          ),
          const NotificationModel(
            id: '4',
            title: 'Payment Receipt Generated',
            message: 'Receipt #TXN-98472910 is ready for download.',
            timestamp: '5 days ago',
            type: 'PAYMENT',
            isRead: true,
          ),
        ]);

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  void markAsRead(String id) {
    state = state.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList();
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier();
});
