enum NotificationCategory {
  all,
  reminders,
  updates;

  String get displayName {
    switch (this) {
      case NotificationCategory.all:
        return 'All';
      case NotificationCategory.reminders:
        return 'Reminders';
      case NotificationCategory.updates:
        return 'Updates';
    }
  }
}

class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationCategory category;
  final String iconEmoji;
  bool isRead;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    required this.iconEmoji,
    this.isRead = false,
  });

  NotificationItemModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationCategory? category,
    String? iconEmoji,
    bool? isRead,
  }) {
    return NotificationItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isRead: isRead ?? this.isRead,
    );
  }
}
