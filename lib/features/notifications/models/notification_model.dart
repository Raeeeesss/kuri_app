class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String timestamp;
  final String type; // 'DUE', 'DIVIDEND', 'AUCTION', 'PAYMENT'
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      timestamp: timestamp,
      type: type,
      isRead: isRead ?? this.isRead,
    );
  }
}
