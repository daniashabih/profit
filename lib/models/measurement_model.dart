class BodyMeasurementModel {
  final String id;
  final String? userId;
  final DateTime date;
  final double weightKg;
  final double waistCm;
  final double chestCm;
  final double armsCm;
  final double thighsCm;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  BodyMeasurementModel({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.waistCm,
    required this.chestCm,
    required this.armsCm,
    required this.thighsCm,
    this.userId,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  BodyMeasurementModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? weightKg,
    double? waistCm,
    double? chestCm,
    double? armsCm,
    double? thighsCm,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BodyMeasurementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      armsCm: armsCm ?? this.armsCm,
      thighsCm: thighsCm ?? this.thighsCm,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armsCm': armsCm,
      'thighsCm': thighsCm,
      if (note != null) 'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Cloud Firestore payload strictly adhering to firestore.rules isValidMeasurement
  Map<String, dynamic> toFirestoreMap(String ownerUid) {
    final map = <String, dynamic>{
      'id': id,
      'userId': userId?.isNotEmpty == true ? userId! : ownerUid,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armsCm': armsCm,
      'thighsCm': thighsCm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (note != null && note!.isNotEmpty) {
      map['note'] = note!;
    }
    return map;
  }

  factory BodyMeasurementModel.fromMap(Map<String, dynamic> map) {
    return BodyMeasurementModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString(),
      date: map['date'] != null ? DateTime.parse(map['date'].toString()) : DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      waistCm: (map['waistCm'] as num?)?.toDouble() ?? 0.0,
      chestCm: (map['chestCm'] as num?)?.toDouble() ?? 0.0,
      armsCm: (map['armsCm'] as num?)?.toDouble() ?? 0.0,
      thighsCm: (map['thighsCm'] as num?)?.toDouble() ?? 0.0,
      note: map['note']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

