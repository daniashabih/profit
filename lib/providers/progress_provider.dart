import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/measurement_model.dart';
import '../models/achievement_model.dart';
import '../repositories/progress_repository.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressRepository _progressRepo;
  final ProgressService _progressService;

  List<BodyMeasurementModel> _measurements = [];
  List<AchievementModel> _achievements = [];
  List<PersonalRecordModel> _personalRecords = [];
  List<bool> _weeklyActivity = [];
  String? _boundUserId;
  StreamSubscription? _measurementsSub;

  List<BodyMeasurementModel> get measurements => _measurements;
  List<AchievementModel> get achievements => _achievements;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  List<bool> get weeklyActivity => _weeklyActivity;

  double get currentWeight => _measurements.isNotEmpty ? _measurements.last.weightKg : 74.5;
  double get startingWeight => _measurements.isNotEmpty ? _measurements.first.weightKg : 81.0;
  double get targetWeight => 72.0;

  ProgressProvider({
    required ProgressRepository progressRepo,
    ProgressService? progressService,
  })  : _progressRepo = progressRepo,
        _progressService = progressService ?? ProgressService() {
    _init();
  }

  void _init() {
    _measurements = List.from(_progressRepo.getMeasurementsHistory());
    _achievements = List.from(_progressRepo.getAchievements());
    _personalRecords = List.from(_progressRepo.getPersonalRecords());
    _weeklyActivity = List.from(_progressRepo.getWeeklyWorkoutActivity());
  }

  /// Binds to a user's real-time measurements in Firestore
  void bindUser(String userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;

    if (Firebase.apps.isEmpty) return;

    _measurementsSub?.cancel();
    _measurementsSub = _progressService.streamMeasurements(userId).listen((list) {
      if (list.isNotEmpty) {
        _measurements = list;
        notifyListeners();
      }
    });
  }

  void addMeasurement(BodyMeasurementModel measurement) {
    _progressRepo.addMeasurement(measurement);
    _measurements = List.from(_progressRepo.getMeasurementsHistory());
    notifyListeners();

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _progressService.addMeasurement(_boundUserId!, measurement).catchError((_) {});
    }
  }

  void deleteMeasurement(String measurementId) {
    _measurements.removeWhere((m) => m.id == measurementId);
    notifyListeners();

    if (Firebase.apps.isNotEmpty) {
      _progressService.deleteMeasurement(measurementId).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _measurementsSub?.cancel();
    super.dispose();
  }
}
