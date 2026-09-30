/// User roles in PROFIT:
/// - [self]: User manages their own fitness journey (workouts, meals, progress).
/// - [trainer]: Fitness trainer who manages assigned clients.
/// - [admin]: Internal administrative capabilities.
enum UserRole {
  self,
  trainer,
  admin;

  /// Backward-compatibility alias: existing code and legacy tests referencing
  /// [UserRole.member] seamlessly resolve to [UserRole.self].
  static const UserRole member = UserRole.self;

  /// Role alias for [UserRole.self] as requested in PROFIT architecture:
  /// 'self_trainer' (Self Trainer) vs 'trainer' (Trainer).
  static const UserRole selfTrainer = UserRole.self;

  String get displayName {
    switch (this) {
      case UserRole.self:
        return 'Self Trainer';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isSelf => this == UserRole.self;
  bool get isSelfTrainer => this == UserRole.self;
  bool get isMember => this == UserRole.self;
  bool get isTrainer => this == UserRole.trainer;
  bool get isAdmin => this == UserRole.admin;

  /// Standard Firestore string representation:
  /// Newly registered self users are stored with role: 'self_trainer'.
  String get firestoreValue {
    switch (this) {
      case UserRole.self:
        return 'self_trainer';
      case UserRole.trainer:
        return 'trainer';
      case UserRole.admin:
        return 'admin';
    }
  }

  /// Safely resolves a role string from Firestore documents or local storage.
  /// Handles 'self_trainer', 'self', 'member', 'trainer', 'admin'.
  /// Missing, null, empty, unknown, or legacy 'member' values safely resolve to [UserRole.self].
  static UserRole fromString(String? roleStr) {
    if (roleStr == null) return UserRole.self;
    final normalized = roleStr.trim().toLowerCase();
    if (normalized == 'trainer') return UserRole.trainer;
    if (normalized == 'admin') return UserRole.admin;
    // 'self_trainer', 'self', 'member', or any legacy/empty value defaults safely to 'self'
    return UserRole.self;
  }
}
