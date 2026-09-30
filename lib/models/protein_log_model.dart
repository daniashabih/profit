/// Daily protein tracking record: proteinLogs/{logId}
class ProteinLog {
  final String id;
  final String userId;
  final String date; // 'YYYY-MM-DD'
  final double targetGrams;
  final double consumedGrams;
  final double remainingGrams;
  final int mealsLoggedCount;
  final DateTime updatedAt;

  const ProteinLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.targetGrams,
    required this.consumedGrams,
    required this.remainingGrams,
    this.mealsLoggedCount = 0,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetGrams <= 0) return 0.0;
    return (consumedGrams / targetGrams).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'targetGrams': targetGrams,
      'consumedGrams': consumedGrams,
      'remainingGrams': remainingGrams,
      'mealsLoggedCount': mealsLoggedCount,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProteinLog.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ProteinLog(
      id: map['id']?.toString() ?? docId ?? '',
      userId: map['userId']?.toString() ?? '',
      date: map['date']?.toString() ?? DateTime.now().toIso8601String().split('T').first,
      targetGrams: (map['targetGrams'] as num?)?.toDouble() ?? 0.0,
      consumedGrams: (map['consumedGrams'] as num?)?.toDouble() ?? 0.0,
      remainingGrams: (map['remainingGrams'] as num?)?.toDouble() ?? 0.0,
      mealsLoggedCount: (map['mealsLoggedCount'] as num?)?.toInt() ?? 0,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
