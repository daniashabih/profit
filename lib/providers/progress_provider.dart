import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/measurement_model.dart';
import '../models/achievement_model.dart';
import '../services/progress_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService;

  List<BodyMeasurementModel> _measurements = [];
  List<AchievementModel> _achievements = [];
  List<PersonalRecordModel> _personalRecords = [];
  List<bool> _weeklyActivity = [];
  String? _boundUserId;
  StreamSubscription? _measurementsSub;

  bool _isLoading = false;
  String? _error;

  List<BodyMeasurementModel> get measurements => _measurements;
  List<AchievementModel> get achievements => _achievements;
  List<PersonalRecordModel> get personalRecords => _personalRecords;
  List<bool> get weeklyActivity => _weeklyActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get currentWeight => _measurements.isNotEmpty ? _measurements.last.weightKg : 0.0;
  double get startingWeight => _measurements.isNotEmpty ? _measurements.first.weightKg : 0.0;
  double get targetWeight => 0.0;

  ProgressProvider({
    ProgressService? progressService,
  })  : _progressService = progressService ?? ProgressService() {
    _init();
  }

  void _init() {
    _measurements = [];
    _achievements = [];
    _personalRecords = [];
    _weeklyActivity = [];
  }

  /// Binds to a user's real-time measurements in Firestore
  void bindUser(String userId) {
    if (_boundUserId == userId) return;
    _boundUserId = userId;

    if (Firebase.apps.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    _measurementsSub?.cancel();
    _measurementsSub = _progressService.streamMeasurements(userId).listen(
      (list) {
        _measurements = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _isLoading = false;
        _error = err.toString();
        debugPrint('Error streaming measurements: $_error');
        notifyListeners();
      },
    );
  }

  void addMeasurement(BodyMeasurementModel measurement) {
    _measurements.add(measurement);
    notifyListeners();

    if (Firebase.apps.isNotEmpty && _boundUserId != null) {
      _progressService.addMeasurement(_boundUserId!, measurement).catchError((err) {
        _error = err.toString();
        debugPrint('Error adding measurement: $_error');
        // If we want full revert, we could re-fetch or remove it.
        // For now, just logging the error.
        notifyListeners();
      });
    }
  }

  void deleteMeasurement(String measurementId) {
    _measurements.removeWhere((m) => m.id == measurementId);
    notifyListeners();

    if (Firebase.apps.isNotEmpty) {
      _progressService.deleteMeasurement(measurementId).catchError((err) {
        _error = err.toString();
        debugPrint('Error deleting measurement: $_error');
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _measurementsSub?.cancel();
    super.dispose();
  }
}
