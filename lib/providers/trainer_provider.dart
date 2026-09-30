import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/trainer_member_model.dart';
import '../models/workout_model.dart';
import '../models/user_model.dart';
import '../models/measurement_model.dart';
import '../models/nutrition_model.dart';
import '../services/client_service.dart';
import '../services/workout_service.dart';
import '../repositories/exercise_repository.dart';

/// TrainerProvider manages dynamic state, Firestore streams, and CRUD operations
/// for the Trainer portal (clients, workout plans, compliance, and client metrics).
class TrainerProvider extends ChangeNotifier {
  final ClientService _clientService;
  final WorkoutService _workoutService;

  List<ClientModel> _clients = [];
  List<WorkoutModel> _workoutPlans = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentTrainerId;

  StreamSubscription? _clientsSub;
  StreamSubscription? _plansSub;

  List<ClientModel> get clients => _clients;
  List<WorkoutModel> get workoutPlans => _workoutPlans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalMembers => _clients.length;
  int get activeMembers => _clients.where((c) => c.status.toLowerCase() == 'active').length;
  int get pendingMembers => _clients.where((c) => c.status.toLowerCase() == 'pending').length;

  TrainerProvider({
    ClientService? clientService,
    WorkoutService? workoutService,
  })  : _clientService = clientService ?? ClientService(),
        _workoutService = workoutService ?? WorkoutService() {
    _initDefaultData();
  }

  void _initDefaultData() {
    // Sensible base data for offline / widget test verification
    _clients = [
      ClientModel(
        id: 'm_01',
        trainerId: 'trainer_01',
        memberId: 'usr_alex',
        memberName: 'Alex Rivera',
        memberEmail: 'alex.rivera@example.com',
        memberGoal: 'Build Muscle & Bulk',
        assignedPlan: 'Upper/Lower 4-Day Split',
        progressPercent: 0.85,
        status: 'active',
        clientWeightKg: 82.5,
        clientHeightCm: 180.0,
        clientAge: 26,
        clientGender: 'Male',
        clientActivityLevel: 'very_active',
        phone: '+1 (555) 234-5678',
        notes: 'Targeting 200g protein daily. Solid bench progression.',
      ),
      ClientModel(
        id: 'm_02',
        trainerId: 'trainer_01',
        memberId: 'usr_sarah',
        memberName: 'Sarah Connor',
        memberEmail: 'sarah.c@example.com',
        memberGoal: 'Fat Loss & Conditioning',
        assignedPlan: 'Metabolic HIIT & Cardio',
        progressPercent: 0.92,
        status: 'active',
        clientWeightKg: 64.0,
        clientHeightCm: 168.0,
        clientAge: 29,
        clientGender: 'Female',
        clientActivityLevel: 'moderately_active',
        phone: '+1 (555) 345-6789',
        notes: 'High compliance. Preparing for 10k run.',
      ),
      ClientModel(
        id: 'm_03',
        trainerId: 'trainer_01',
        memberId: 'usr_james',
        memberName: 'James Wilson',
        memberEmail: 'j.wilson@example.com',
        memberGoal: 'Strength & 1RM Gains',
        assignedPlan: 'Push / Pull / Legs',
        progressPercent: 0.65,
        status: 'active',
        clientWeightKg: 91.0,
        clientHeightCm: 185.0,
        clientAge: 32,
        clientGender: 'Male',
        clientActivityLevel: 'very_active',
        phone: '+1 (555) 456-7890',
        notes: 'Squat 1RM increasing steadily. Focus on mobility.',
      ),
      ClientModel(
        id: 'm_04',
        trainerId: 'trainer_01',
        memberId: 'usr_maya',
        memberName: 'Maya Lin',
        memberEmail: 'maya.lin@example.com',
        memberGoal: 'General Health & Tone',
        assignedPlan: 'Full Body 3x Weekly',
        progressPercent: 0.30,
        status: 'pending',
        clientWeightKg: 58.5,
        clientHeightCm: 162.0,
        clientAge: 24,
        clientGender: 'Female',
        clientActivityLevel: 'lightly_active',
        phone: '+1 (555) 567-8901',
        notes: 'Requested onboarding call.',
      ),
      ClientModel(
        id: 'm_05',
        trainerId: 'trainer_01',
        memberId: 'usr_david',
        memberName: 'David Chen',
        memberEmail: 'd.chen@example.com',
        memberGoal: 'Hypertrophy & Mobility',
        assignedPlan: 'Custom Routine',
        progressPercent: 0.10,
        status: 'pending',
        clientWeightKg: 76.0,
        clientHeightCm: 175.0,
        clientAge: 30,
        clientGender: 'Male',
        clientActivityLevel: 'moderately_active',
        phone: '+1 (555) 678-9012',
        notes: 'Needs custom nutrition macro target.',
      ),
    ];

    final exerciseRepo = LocalExerciseRepository();
    final allEx = exerciseRepo.getAllExercises();

    _workoutPlans = [
      WorkoutModel(
        id: 'plan_01',
        title: 'Upper/Lower 4-Day Split',
        subtitle: 'Optimal for hypertrophy and strength',
        durationMinutes: 45,
        category: 'Hypertrophy',
        intensity: 'Intermediate',
        estimatedCalories: 380,
        isTemplate: true,
        exercises: allEx.take(5).toList(),
      ),
      WorkoutModel(
        id: 'plan_02',
        title: 'Metabolic HIIT & Fat Burn',
        subtitle: 'High energy conditioning',
        durationMinutes: 30,
        category: 'Cardio & Conditioning',
        intensity: 'All Levels',
        estimatedCalories: 410,
        isTemplate: true,
        exercises: allEx.skip(2).take(4).toList(),
      ),
      WorkoutModel(
        id: 'plan_03',
        title: 'Push / Pull / Legs Strength',
        subtitle: 'Max volume 5-day cycle',
        durationMinutes: 55,
        category: 'Power & Mass',
        intensity: 'Advanced',
        estimatedCalories: 450,
        isTemplate: true,
        exercises: allEx.take(6).toList(),
      ),
      WorkoutModel(
        id: 'plan_04',
        title: 'Beginner Full Body Foundation',
        subtitle: 'Core compound movement mechanics',
        durationMinutes: 35,
        category: 'Mobility & Habit',
        intensity: 'Beginner',
        estimatedCalories: 290,
        isTemplate: true,
        exercises: allEx.take(3).toList(),
      ),
    ];
  }

  /// Binds to a specific trainer's real-time Firestore streams
  void bindTrainer(String trainerId) {
    if (_currentTrainerId == trainerId) return;
    _currentTrainerId = trainerId;

    if (Firebase.apps.isEmpty) return;

    _clientsSub?.cancel();
    _plansSub?.cancel();

    _isLoading = true;
    notifyListeners();

    _clientsSub = _clientService.streamClientsForTrainer(trainerId).listen((list) {
      if (list.isNotEmpty) {
        _clients = list;
      }
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _isLoading = false;
      _errorMessage = err.toString();
      notifyListeners();
    });

    _plansSub = _workoutService.streamTemplateWorkouts().listen((plans) {
      if (plans.isNotEmpty) {
        _workoutPlans = plans;
        notifyListeners();
      }
    });
  }

  /// Adds a new client and syncs to Firestore
  Future<void> addClient(ClientModel client) async {
    _clients.insert(0, client);
    notifyListeners();

    if (Firebase.apps.isNotEmpty) {
      try {
        await _clientService.addClient(client);
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  /// Updates an existing client and syncs to Firestore
  Future<void> updateClient(ClientModel client) async {
    final idx = _clients.indexWhere((c) => c.id == client.id || c.memberId == client.memberId);
    if (idx != -1) {
      _clients[idx] = client;
      notifyListeners();
    }

    if (Firebase.apps.isNotEmpty) {
      try {
        await _clientService.updateClient(client);
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  /// Deletes a client relationship with confirmation and syncs to Firestore
  Future<void> deleteClient(String relationshipId) async {
    _clients.removeWhere((c) => c.id == relationshipId || c.memberId == relationshipId);
    notifyListeners();

    if (Firebase.apps.isNotEmpty) {
      try {
        await _clientService.deleteClient(relationshipId);
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  /// Accepts a pending client request
  Future<void> acceptPendingClient(String clientId) async {
    final idx = _clients.indexWhere((c) => c.id == clientId || c.memberId == clientId);
    if (idx != -1) {
      final updated = _clients[idx].copyWith(status: 'active');
      _clients[idx] = updated;
      notifyListeners();

      if (Firebase.apps.isNotEmpty) {
        try {
          await _clientService.updateClient(updated);
        } catch (e) {
          _errorMessage = e.toString();
        }
      }
    }
  }

  /// Assigns a workout plan to an athlete
  Future<void> assignPlanToClient(String clientId, String planTitle) async {
    final idx = _clients.indexWhere((c) => c.id == clientId || c.memberId == clientId);
    if (idx != -1) {
      final updated = _clients[idx].copyWith(
        assignedPlan: planTitle,
        status: 'active',
      );
      _clients[idx] = updated;
      notifyListeners();

      if (Firebase.apps.isNotEmpty) {
        try {
          await _clientService.assignPlanToClient(_clients[idx].id, planTitle);
        } catch (e) {
          _errorMessage = e.toString();
        }
      }
    }
  }

  /// Creates a new workout plan template
  Future<void> createWorkoutPlan(WorkoutModel plan) async {
    _workoutPlans.insert(0, plan);
    notifyListeners();

    if (Firebase.apps.isNotEmpty) {
      try {
        await _workoutService.createWorkout(plan);
      } catch (e) {
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }

  /// Fetches client user profile
  Future<UserModel?> getClientProfile(String clientUid) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        return await _clientService.getClientFullProfile(clientUid);
      } catch (_) {}
    }
    return null;
  }

  /// Fetches client measurement history
  Future<List<BodyMeasurementModel>> getClientMeasurements(String clientUid) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        return await _clientService.getClientMeasurements(clientUid);
      } catch (_) {}
    }
    return [];
  }

  /// Fetches client today nutrition
  Future<DailyNutritionModel?> getClientTodayNutrition(String clientUid) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        return await _clientService.getClientTodayNutrition(clientUid);
      } catch (_) {}
    }
    return null;
  }

  /// Fetches client workouts
  Future<List<WorkoutModel>> getClientWorkouts(String clientUid) async {
    if (Firebase.apps.isNotEmpty) {
      try {
        return await _clientService.getClientWorkouts(clientUid);
      } catch (_) {}
    }
    return [];
  }

  @override
  void dispose() {
    _clientsSub?.cancel();
    _plansSub?.cancel();
    super.dispose();
  }
}
