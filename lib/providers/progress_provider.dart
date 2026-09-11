import 'package:flutter/material.dart';
import '../models/measurement_model.dart';
import '../models/achievement_model.dart';
import '../repositories/progress_repository.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepo;

  List<BodyMeasurementModel> _measurements = [];
  List<AchievementModel> _achievements = [];
  List<PersonalRecordModel> _personalRecords = [];
  List<bool> _weeklyActivity = [];

  List<BodyMeasurementModel> get measurements => _measurements;
  List<AchievementModel> get achievements => _achievements;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  List<bool> get weeklyActivity => _weeklyActivity;

  double get currentWeight => _measurements.isNotEmpty ? _measurements.last.weightKg : 74.5;
  double get startingWeight => _measurements.isNotEmpty ? _measurements.first.weightKg : 81.0;
  double get targetWeight => 72.0;

  ProgressProvider({required ProgressRepository progressRepo})
      : _progressRepo = progressRepo {
    _init();
  }

  void _init() {
    _measurements = List.from(_progressRepo.getMeasurementsHistory());
    _achievements = List.from(_progressRepo.getAchievements());
    _personalRecords = List.from(_progressRepo.getPersonalRecords());
    _weeklyActivity = List.from(_progressRepo.getWeeklyWorkoutActivity());
  }

  void addMeasurement(BodyMeasurementModel measurement) {
    _progressRepo.addMeasurement(measurement);
    _measurements = List.from(_progressRepo.getMeasurementsHistory());
    notifyListeners();
  }
}
