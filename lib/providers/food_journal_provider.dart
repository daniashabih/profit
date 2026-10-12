import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/enums/meal_type.dart';
import '../models/food_post_model.dart';
import '../models/trainer_food_feedback_model.dart';
import '../models/daily_food_summary_model.dart';
import '../models/nutrition_insight_model.dart';
import '../models/user_model.dart';
import '../services/food_post_service.dart';
import '../services/ai_food_analysis_service.dart';
import '../services/nutrition_analytics_service.dart';

class FoodJournalProvider extends ChangeNotifier {
  final FoodPostService _postService;
  final AiFoodAnalysisService _analysisService;

  String? _userId;
  UserModel? _currentUser;
  List<FoodPost> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;
  FoodAnalysisStatus _analysisStatus = FoodAnalysisStatus.pending;

  DateTime _selectedDate = DateTime.now();
  DailyFoodSummary? _selectedDateSummary;
  WeeklyNutritionInsights? _weeklyInsights;
  MonthlyNutritionReport? _monthlyReport;

  StreamSubscription<List<FoodPost>>? _postsSubscription;

  FoodJournalProvider({
    FoodPostService? postService,
    AiFoodAnalysisService? analysisService,
  })  : _postService = postService ?? FoodPostService(),
        _analysisService = analysisService ?? AiFoodAnalysisService() {
    _initSampleData();
  }

  // Getters
  List<FoodPost> get posts => _posts;
  List<FoodPost> get userPosts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  FoodAnalysisStatus get analysisStatus => _analysisStatus;
  DateTime get selectedDate => _selectedDate;
  DailyFoodSummary? get selectedDateSummary => _selectedDateSummary;
  WeeklyNutritionInsights? get weeklyInsights => _weeklyInsights;
  MonthlyNutritionReport? get monthlyReport => _monthlyReport;
  int get totalPostsCount => _posts.length;

  void _initSampleData() {
    // Initial fetch from service cache
    _posts = [
      FoodPost.fromItems(
        id: 'sample_post_1',
        userId: 'usr_sample_1',
        mealType: MealType.breakfast,
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800&auto=format&fit=crop&q=80',
        title: 'Eggs & Avocado Sourdough Toast',
        notes: 'Pre-workout morning fuel',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        mealDate: DateTime.now(),
        items: [
          const DetectedFoodItem(
            id: 'item_s1',
            name: '🍳 Poached Eggs',
            portion: '2 eggs',
            portionGrams: 100,
            calories: 144,
            protein: 12.6,
            carbs: 0.8,
            fat: 9.8,
            fiber: 0.0,
            sodium: 140.0,
            micronutrients: {'calcium': 56.0, 'iron': 1.8, 'magnesium': 12.0, 'potassium': 138.0, 'zinc': 1.3, 'sodium': 140.0},
            vitamins: {'vitaminA': 18.0, 'vitaminC': 0.0, 'vitaminD': 2.0, 'vitaminE': 1.1, 'vitaminK': 0.3},
          ),
          const DetectedFoodItem(
            id: 'item_s2',
            name: '🍞 Whole Grain Toast',
            portion: '2 slices',
            portionGrams: 80,
            calories: 195,
            protein: 8.2,
            carbs: 36.0,
            fat: 2.4,
            fiber: 5.2,
            sodium: 260.0,
            micronutrients: {'calcium': 38.0, 'iron': 2.2, 'magnesium': 48.0, 'potassium': 160.0, 'zinc': 1.4, 'sodium': 260.0},
            vitamins: {'vitaminA': 0.0, 'vitaminC': 0.0, 'vitaminD': 0.0, 'vitaminE': 0.4, 'vitaminK': 1.2},
          ),
          const DetectedFoodItem(
            id: 'item_s3',
            name: '🥑 Ripe Avocado',
            portion: '50 g',
            portionGrams: 50,
            calories: 80,
            protein: 1.0,
            carbs: 4.3,
            fat: 7.3,
            fiber: 3.4,
            sodium: 4.0,
            micronutrients: {'calcium': 6.0, 'iron': 0.3, 'magnesium': 15.0, 'potassium': 242.0, 'zinc': 0.3, 'sodium': 4.0},
            vitamins: {'vitaminA': 3.0, 'vitaminC': 5.0, 'vitaminD': 0.0, 'vitaminE': 1.1, 'vitaminK': 13.0},
          ),
        ],
      ),
      FoodPost.fromItems(
        id: 'sample_post_2',
        userId: 'usr_sample_1',
        mealType: MealType.lunch,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
        title: 'Grilled Herb Chicken with Brown Rice',
        notes: 'High protein recovery meal',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        mealDate: DateTime.now(),
        items: [
          const DetectedFoodItem(
            id: 'item_s4',
            name: '🍗 Grilled Chicken Breast',
            portion: '160 g',
            portionGrams: 160,
            cookingMethod: 'Grilled',
            calories: 264,
            protein: 49.6,
            carbs: 0.0,
            fat: 5.8,
            fiber: 0.0,
            sodium: 118.0,
            micronutrients: {'calcium': 24.0, 'iron': 1.8, 'magnesium': 48.0, 'potassium': 410.0, 'zinc': 1.6, 'sodium': 118.0},
            vitamins: {'vitaminA': 1.0, 'vitaminC': 0.0, 'vitaminD': 0.1, 'vitaminE': 0.5, 'vitaminK': 0.3},
          ),
          const DetectedFoodItem(
            id: 'item_s5',
            name: '🍚 Steamed Brown Rice',
            portion: '1 cup',
            portionGrams: 150,
            cookingMethod: 'Steamed',
            calories: 168,
            protein: 3.8,
            carbs: 35.2,
            fat: 1.4,
            fiber: 2.8,
            sodium: 2.0,
            micronutrients: {'calcium': 15.0, 'iron': 1.4, 'magnesium': 64.0, 'potassium': 125.0, 'zinc': 1.2, 'sodium': 2.0},
            vitamins: {'vitaminA': 0.0, 'vitaminC': 0.0, 'vitaminD': 0.0, 'vitaminE': 0.2, 'vitaminK': 0.0},
          ),
          const DetectedFoodItem(
            id: 'item_s6',
            name: '🥦 Steamed Broccoli & Greens',
            portion: '100 g',
            portionGrams: 100,
            cookingMethod: 'Steamed',
            calories: 35,
            protein: 2.8,
            carbs: 7.2,
            fat: 0.4,
            fiber: 3.3,
            sodium: 33.0,
            micronutrients: {'calcium': 47.0, 'iron': 0.7, 'magnesium': 21.0, 'potassium': 316.0, 'zinc': 0.4, 'sodium': 33.0},
            vitamins: {'vitaminA': 31.0, 'vitaminC': 89.0, 'vitaminD': 0.0, 'vitaminE': 0.8, 'vitaminK': 102.0},
          ),
        ],
      ),
    ];
    _recomputeAggregates();
  }

  void bindUser(String userId, {UserModel? user}) {
    if (_userId == userId && _currentUser == user) return;
    _userId = userId;
    _currentUser = user;

    _postsSubscription?.cancel();
    _postsSubscription = _postService.streamUserFoodPosts(userId).listen((postsList) {
      if (postsList.isNotEmpty) {
        _posts = postsList;
      }
      _recomputeAggregates();
      notifyListeners();
    });

    _recomputeAggregates();
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _recomputeAggregates();
    notifyListeners();
  }

  void _recomputeAggregates() {
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    final dayPosts = _posts.where((p) {
      return p.mealDate.toIso8601String().split('T').first == dateStr;
    }).toList();

    _selectedDateSummary = NutritionAnalyticsService.calculateDailySummary(
      date: _selectedDate,
      postsForDate: dayPosts,
      user: _currentUser,
    );

    _weeklyInsights = NutritionAnalyticsService.calculateWeeklyInsights(
      currentDay: _selectedDate,
      recentPosts: _posts,
      user: _currentUser,
    );

    final now = DateTime.now();
    final monthId = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _monthlyReport = NutritionAnalyticsService.calculateMonthlyReport(
      monthId: monthId,
      monthName: 'October',
      year: now.year,
      monthlyPosts: _posts,
      user: _currentUser,
    );
  }

  /// Sends image to backend AI analysis service with status and confidence
  Future<({
    List<DetectedFoodItem> detectedFoods,
    FoodAnalysisStatus status,
    double confidence,
    String? errorMessage,
  })> analyzeFoodImage({
    required Uint8List imageBytes,
    required MealType mealType,
    String? mealTitleHint,
    String? notes,
  }) async {
    _analysisStatus = FoodAnalysisStatus.analyzing;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _analysisService.analyzeFoodImage(
        imageBytes: imageBytes,
        mealType: mealType,
        mealTitleHint: mealTitleHint,
        userNotes: notes,
      );

      _analysisStatus = result.status;
      _errorMessage = result.errorMessage;
      notifyListeners();
      return result;
    } catch (e) {
      _analysisStatus = FoodAnalysisStatus.failed;
      _errorMessage = 'We couldn\'t analyze this meal. You can enter the foods manually.';
      notifyListeners();
      return (
        detectedFoods: <DetectedFoodItem>[],
        status: FoodAnalysisStatus.failed,
        confidence: 0.0,
        errorMessage: _errorMessage,
      );
    }
  }

  /// Uploads photo to Firebase Storage and saves the complete FoodPost to Firestore
  Future<FoodPost> saveFoodPost({
    required String postId,
    required MealType mealType,
    required String title,
    String notes = '',
    required DateTime mealDate,
    required List<DetectedFoodItem> items,
    Uint8List? imageBytes,
    String? existingImageUrl,
    bool userVerified = true,
  }) async {
    _isLoading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      String finalImageUrl = existingImageUrl ?? '';

      if (imageBytes != null && imageBytes.isNotEmpty) {
        finalImageUrl = await _postService.uploadFoodImage(
          userId: _userId ?? '',
          postId: postId,
          imageBytes: imageBytes,
          onProgress: (p) {
            _uploadProgress = p;
            notifyListeners();
          },
        );
      }

      if (finalImageUrl.isEmpty) {
        // Safe placeholder
        finalImageUrl = 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=800&auto=format&fit=crop&q=80';
      }

      final newPost = FoodPost.fromItems(
        id: postId,
        userId: _userId ?? 'usr_local',
        mealType: mealType,
        imageUrl: finalImageUrl,
        imagePath: 'food_images/${_userId ?? 'usr_local'}/$postId/image.jpg',
        title: title.isNotEmpty ? title : '${mealType.displayName} Meal',
        notes: notes,
        mealDate: mealDate,
        items: items,
        userVerified: userVerified,
      );

      await _postService.createFoodPost(newPost);

      // Add to local state immediately
      _posts.removeWhere((p) => p.id == newPost.id);
      _posts.insert(0, newPost);
      _recomputeAggregates();

      _isLoading = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return newPost;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Updates an existing food post
  Future<void> updateFoodPost(FoodPost updatedPost) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _postService.updateFoodPost(updatedPost);
      final idx = _posts.indexWhere((p) => p.id == updatedPost.id);
      if (idx != -1) {
        _posts[idx] = updatedPost;
      }
      _recomputeAggregates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a food post
  Future<void> deleteFoodPost(String postId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _postService.deleteFoodPost(postId, userId: _userId);
      _posts.removeWhere((p) => p.id == postId);
      _recomputeAggregates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Trainer adds feedback to client's food post
  Future<void> addTrainerFeedback(TrainerFoodFeedback feedback) async {
    await _postService.addTrainerFeedback(feedback);
    notifyListeners();
  }

  /// Streams feedback for a specific post
  Stream<List<TrainerFoodFeedback>> streamFeedbackForPost(String postId) {
    return _postService.streamFeedbackForPost(postId);
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}
