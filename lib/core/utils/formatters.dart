import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat _shortDate = DateFormat('MMM d');
  static final DateFormat _dayOfWeek = DateFormat('E');
  static final DateFormat _fullDate = DateFormat('MMMM d, yyyy');
  static final DateFormat _timeOnly = DateFormat('h:mm a');

  static String formatDate(DateTime date) => _shortDate.format(date);
  static String formatFullDate(DateTime date) => _fullDate.format(date);
  static String formatDayOfWeek(DateTime date) => _dayOfWeek.format(date);
  static String formatTime(DateTime date) => _timeOnly.format(date);

  static String formatSecondsToMinutes(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String formatWeight(double weight, {bool isLbs = false}) {
    final value = isLbs ? weight * 2.20462 : weight;
    return '${value.toStringAsFixed(1)} ${isLbs ? 'lbs' : 'kg'}';
  }

  static String formatCalories(int calories) {
    return NumberFormat('#,###').format(calories);
  }
}
