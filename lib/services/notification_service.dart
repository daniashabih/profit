import '../models/notification_model.dart';

abstract class NotificationService {
  Future<List<NotificationItemModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> clearAll();
}

class LocalNotificationService implements NotificationService {
  final List<NotificationItemModel> _notifications = [
    NotificationItemModel(
      id: 'notif_1',
      title: 'Workout Reminder',
      message: 'Don\'t forget your workout today!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: NotificationCategory.reminders,
      iconEmoji: '🏋️',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_2',
      title: 'Membership Alert',
      message: 'Your membership expires in 12 days.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: NotificationCategory.reminders,
      iconEmoji: '💳',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_3',
      title: 'New Plan Assigned',
      message: 'Your trainer has updated your plan.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: NotificationCategory.updates,
      iconEmoji: '📋',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_4',
      title: 'Achievement Unlocked',
      message: 'You completed 10 workouts!',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      category: NotificationCategory.updates,
      iconEmoji: '🏆',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_5',
      title: 'Nutrition Reminder',
      message: 'Stay on track with your nutrition goals.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: NotificationCategory.reminders,
      iconEmoji: '🥗',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_6',
      title: 'General Update',
      message: 'New exercises added to the library!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      category: NotificationCategory.updates,
      iconEmoji: '🔔',
      isRead: true,
    ),
  ];

  @override
  Future<List<NotificationItemModel>> getNotifications() async {
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (final notif in _notifications) {
      notif.isRead = true;
    }
  }

  @override
  Future<void> clearAll() async {
    _notifications.clear();
  }
}
