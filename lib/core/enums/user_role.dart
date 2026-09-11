enum UserRole {
  member,
  trainer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Member';
      case UserRole.trainer:
        return 'Trainer';
      case UserRole.admin:
        return 'Admin';
    }
  }

  bool get isMember => this == UserRole.member;
  bool get isTrainer => this == UserRole.trainer;
  bool get isAdmin => this == UserRole.admin;
}
