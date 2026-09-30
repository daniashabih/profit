import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../models/bmi_record_model.dart';
import '../core/utils/fitness_calculators.dart';

/// Service responsible for dynamic BMI calculations, WHO-based healthy ranges,
/// target weight estimations, safety guidance, and Cloud Firestore BMI record logging.
class BmiService {
  final FirebaseFirestore? _firestore;
  static const _uuid = Uuid();

  // Local cache for offline/mock mode
  final List<BmiRecord> _localBmiHistory = [];

  BmiService({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null);

  /// Calculates Body Mass Index: weight(kg) / height(m)^2
  static double calculateBmi(double weightKg, double heightCm) {
    return FitnessCalculators.calculateBmi(weightKg, heightCm);
  }

  /// Returns standard WHO BMI category
  static String getBmiCategory(double bmi) {
    return FitnessCalculators.getBmiCategory(bmi);
  }

  /// Calculates healthy weight range in kg corresponding to BMI 18.5 - 24.9
  static ({double minKg, double maxKg}) getHealthyWeightRange(double heightCm) {
    if (heightCm <= 0) return (minKg: 45.0, maxKg: 70.0);
    final hm = heightCm / 100.0;
    final hm2 = hm * hm;
    final minKg = double.parse((18.5 * hm2).toStringAsFixed(1));
    final maxKg = double.parse((24.9 * hm2).toStringAsFixed(1));
    return (minKg: minKg, maxKg: maxKg);
  }

  /// Calculates a personalized, safe suggested target weight range and recommended initial target
  /// based on current weight, height, and goal type.
  ///
  /// Important: This is a suggested fitness target range, NOT a medical prescription.
  static ({
    double minTargetKg,
    double maxTargetKg,
    double suggestedInitialTargetKg,
    String rationale,
    bool requiresMedicalCaution,
  }) suggestTargetWeight({
    required double currentWeightKg,
    required double heightCm,
    required String goalType,
  }) {
    final healthyRange = getHealthyWeightRange(heightCm);
    final currentBmi = calculateBmi(currentWeightKg, heightCm);
    final normalizedGoal = goalType.toLowerCase();

    double minTarget;
    double maxTarget;
    double suggestedTarget;
    String rationale;
    bool medicalCaution = false;

    if (normalizedGoal.contains('lose') || normalizedGoal.contains('weight loss') || normalizedGoal.contains('cut')) {
      if (currentWeightKg <= healthyRange.minKg) {
        // Already underweight or at lower boundary
        minTarget = healthyRange.minKg;
        maxTarget = healthyRange.maxKg;
        suggestedTarget = currentWeightKg;
        rationale = 'Your current weight is already at or below the lower healthy range. Further weight loss is not advised without medical supervision.';
        medicalCaution = true;
      } else if (currentWeightKg > healthyRange.maxKg) {
        // Overweight or Obese: suggest upper half of healthy range as safe initial milestone
        minTarget = healthyRange.minKg;
        maxTarget = healthyRange.maxKg;
        // Recommend upper boundary of healthy range or a safe 10% initial weight loss milestone
        final tenPercentLoss = double.parse((currentWeightKg * 0.9).toStringAsFixed(1));
        suggestedTarget = (tenPercentLoss > healthyRange.maxKg) ? healthyRange.maxKg : tenPercentLoss;
        rationale = 'Suggested healthy range: ${healthyRange.minKg} – ${healthyRange.maxKg} kg. An initial achievable target of $suggestedTarget kg provides sustainable, non-extreme progress.';
      } else {
        // Within healthy range already
        minTarget = healthyRange.minKg;
        maxTarget = currentWeightKg;
        suggestedTarget = double.parse(((currentWeightKg + healthyRange.minKg) / 2).toStringAsFixed(1));
        rationale = 'Your weight is currently within the healthy range. A modest refinement to $suggestedTarget kg is suggested.';
      }
    } else if (normalizedGoal.contains('build') || normalizedGoal.contains('muscle') || normalizedGoal.contains('bulk')) {
      if (currentWeightKg < healthyRange.minKg) {
        minTarget = healthyRange.minKg;
        maxTarget = healthyRange.maxKg;
        suggestedTarget = double.parse(((healthyRange.minKg + healthyRange.maxKg) / 2).toStringAsFixed(1));
        rationale = 'Building lean mass to reach the healthy range (${healthyRange.minKg} – ${healthyRange.maxKg} kg) is recommended.';
      } else {
        // Moderate lean muscle addition (+2 to +5 kg)
        minTarget = currentWeightKg;
        maxTarget = double.parse((currentWeightKg + 6.0).toStringAsFixed(1));
        suggestedTarget = double.parse((currentWeightKg + 3.0).toStringAsFixed(1));
        rationale = 'Gradual progressive hypertrophy targeting lean tissue gains of 2–4 kg.';
      }
    } else {
      // Maintain Weight or Improve Fitness
      minTarget = healthyRange.minKg;
      maxTarget = healthyRange.maxKg;
      suggestedTarget = currentWeightKg;
      rationale = 'Focus on body recomposition, stamina, and consistency while maintaining your current weight.';
    }

    if (currentBmi >= 35.0 || currentBmi < 16.5) {
      medicalCaution = true;
    }

    return (
      minTargetKg: minTarget,
      maxTargetKg: maxTarget,
      suggestedInitialTargetKg: suggestedTarget,
      rationale: rationale,
      requiresMedicalCaution: medicalCaution,
    );
  }

  /// Saves a newly calculated BMI record to Cloud Firestore: bmiRecords/{recordId}
  Future<BmiRecord> logBmiRecord({
    required String userId,
    required double weightKg,
    required double heightCm,
    String? recordId,
  }) async {
    final bmi = calculateBmi(weightKg, heightCm);
    final category = getBmiCategory(bmi);
    final id = recordId ?? 'bmi_${_uuid.v4()}';

    final record = BmiRecord(
      id: id,
      userId: userId,
      weight: weightKg,
      height: heightCm,
      bmi: bmi,
      category: category,
      calculatedAt: DateTime.now(),
    );

    _localBmiHistory.add(record);

    if (_firestore != null && userId.isNotEmpty) {
      try {
        await _firestore.collection('bmiRecords').doc(id).set(record.toMap());
      } catch (e) {
        // Keep in local cache if offline or unauthenticated in test environment
      }
    }

    return record;
  }

  /// Streams or fetches the user's BMI record history
  Stream<List<BmiRecord>> streamBmiHistory(String userId) {
    if (_firestore == null || userId.isEmpty) {
      return Stream.value(_localBmiHistory.where((r) => r.userId == userId).toList());
    }

    return _firestore
        .collection('bmiRecords')
        .where('userId', isEqualTo: userId)
        .orderBy('calculatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BmiRecord.fromMap(doc.data(), docId: doc.id))
          .toList();
    });
  }

  /// Retrieves list of BMI records for a user
  Future<List<BmiRecord>> getBmiHistory(String userId) async {
    if (_firestore == null || userId.isEmpty) {
      return _localBmiHistory.where((r) => r.userId == userId).toList();
    }

    try {
      final snapshot = await _firestore
          .collection('bmiRecords')
          .where('userId', isEqualTo: userId)
          .orderBy('calculatedAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => BmiRecord.fromMap(doc.data(), docId: doc.id))
            .toList();
      }
    } catch (_) {}

    return _localBmiHistory.where((r) => r.userId == userId).toList();
  }
}
