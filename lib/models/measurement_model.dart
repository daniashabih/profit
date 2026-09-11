class BodyMeasurementModel {
  final String id;
  final DateTime date;
  final double weightKg;
  final double waistCm;
  final double chestCm;
  final double armsCm;
  final double thighsCm;
  final String? note;

  BodyMeasurementModel({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.waistCm,
    required this.chestCm,
    required this.armsCm,
    required this.thighsCm,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armsCm': armsCm,
      'thighsCm': thighsCm,
      'note': note,
    };
  }

  factory BodyMeasurementModel.fromMap(Map<String, dynamic> map) {
    return BodyMeasurementModel(
      id: map['id'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      waistCm: (map['waistCm'] as num?)?.toDouble() ?? 0.0,
      chestCm: (map['chestCm'] as num?)?.toDouble() ?? 0.0,
      armsCm: (map['armsCm'] as num?)?.toDouble() ?? 0.0,
      thighsCm: (map['thighsCm'] as num?)?.toDouble() ?? 0.0,
      note: map['note'],
    );
  }
}
