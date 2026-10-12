enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  drink,
  other;

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
      case MealType.drink:
        return 'Drink';
      case MealType.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
      case MealType.drink:
        return '🥤';
      case MealType.other:
        return '🍽️';
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
      case MealType.drink:
        return '11:00 AM';
      case MealType.other:
        return '03:00 PM';
    }
  }

  static MealType fromString(String? val) {
    if (val == null) return MealType.other;
    final lower = val.toLowerCase().trim();
    for (final t in MealType.values) {
      if (t.name.toLowerCase() == lower) return t;
    }
    return MealType.other;
  }
}
