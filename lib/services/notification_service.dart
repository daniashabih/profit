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
      title: 'Workout Reminder 🏋️',
      message: 'Time for your Upper Body workout! 7 exercises are scheduled for today.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      category: NotificationCategory.reminders,
      iconEmoji: '⏰',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_2',
      title: 'Achievement Unlocked! 🔥',
      message: 'You hit a 5-Day Workout Streak! Keep the momentum going.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      category: NotificationCategory.updates,
      iconEmoji: '🏆',
      isRead: false,
    ),
    NotificationItemModel(
      id: 'notif_3',
      title: 'Nutrition Reminder 🥗',
      message: 'Don\'t forget to log your lunch. You still have 950 kcal remaining.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      category: NotificationCategory.reminders,
      iconEmoji: '🥑',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_4',
      title: 'New Plan Assigned 📋',
      message: 'Coach Marcus updated your weekly hypertrophy routine with new progressive overload targets.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      category: NotificationCategory.updates,
      iconEmoji: '📝',
      isRead: true,
    ),
    NotificationItemModel(
      id: 'notif_5',
      title: 'Membership Alert ⭐',
      message: 'Your FitFlow Premium status is active with 184 days remaining. Enjoy full features!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      category: NotificationCategory.updates,
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
