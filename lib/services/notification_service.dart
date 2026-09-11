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
      message: 'Time for your scheduled Upper Body strength session!',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      category: NotificationCategory.reminders,
      iconEmoji: '🏋️',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_2',
      title: 'Water Intake Goal',
      message: 'You\'re 500ml away from reaching your daily target.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: NotificationCategory.reminders,
      iconEmoji: '💧',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_3',
      title: 'Trainer Update',
      message: 'Ahmed Khan commented on your workout plan.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: NotificationCategory.updates,
      iconEmoji: '💬',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_4',
      title: 'Calorie Target Alert',
      message: 'Log your lunch to stay on track with your 1,800 kcal goal.',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      category: NotificationCategory.reminders,
      iconEmoji: '🥗',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_5',
      title: 'Streak Milestone!',
      message: 'You\'re on a 5-day workout streak! Keep it going.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: NotificationCategory.updates,
      iconEmoji: '🔥',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_6',
      title: 'Membership Renewal',
      message: 'Your Premium membership expires in 12 days.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      category: NotificationCategory.reminders,
      iconEmoji: '👑',
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
