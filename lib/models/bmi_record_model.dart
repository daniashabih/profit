/// Model representing a logged BMI record in Cloud Firestore: bmiRecords/{recordId}
class BmiRecord {
  final String id;
  final String userId;
  final double weight;
  final double height;
  final double bmi;
  final String category;
  final DateTime calculatedAt;

  const BmiRecord({
    required this.id,
    required this.userId,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'category': category,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory BmiRecord.fromMap(Map<String, dynamic> map, {String? docId}) {
    return BmiRecord(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      bmi: (map['bmi'] as num?)?.toDouble() ?? 0.0,
      category: map['category']?.toString() ?? 'Healthy Weight',
      calculatedAt: map['calculatedAt'] != null
          ? DateTime.tryParse(map['calculatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
