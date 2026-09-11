enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get defaultTime {
    switch (this) {
      case MealType.breakfast:
        return '08:30 AM';
      case MealType.lunch:
        return '01:00 PM';
      case MealType.dinner:
        return '07:30 PM';
      case MealType.snack:
        return '04:30 PM';
    }
  }
}
