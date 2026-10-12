import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/enums/meal_type.dart';
import '../models/food_post_model.dart';
import '../models/trainer_food_feedback_model.dart';

/// Service managing Food Posts in Cloud Firestore (`foodPosts`)
/// and food images in Firebase Storage (`food_images/{uid}/{postId}/image.jpg`).
class FoodPostService {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  // In-memory cache for fast responsive rendering & offline/testing mode
  final Map<String, FoodPost> _localPosts = {};
  final Map<String, List<TrainerFoodFeedback>> _localFeedback = {};

  final StreamController<List<FoodPost>> _localPostsStreamController =
      StreamController<List<FoodPost>>.broadcast();

  FoodPostService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ??
            (Firebase.apps.isNotEmpty ? FirebaseFirestore.instance : null),
        _storage = storage ??
            (Firebase.apps.isNotEmpty ? FirebaseStorage.instance : null) {
    _seedInitialSampleDataIfEmpty();
  }

  void _seedInitialSampleDataIfEmpty() {
    if (_localPosts.isNotEmpty) return;
    final now = DateTime.now();

    final sample1 = FoodPost.fromItems(
      id: 'sample_post_1',
      userId: 'usr_sample_1',
      mealType: MealType.breakfast,
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=800&auto=format&fit=crop&q=80',
      title: 'Eggs & Avocado Sourdough Toast',
      notes: 'Morning pre-workout breakfast',
      createdAt: now.subtract(const Duration(hours: 6)),
      mealDate: now,
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
          sugar: 0.8,
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
          sugar: 2.0,
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
          sugar: 0.3,
          sodium: 4.0,
          micronutrients: {'calcium': 6.0, 'iron': 0.3, 'magnesium': 15.0, 'potassium': 242.0, 'zinc': 0.3, 'sodium': 4.0},
          vitamins: {'vitaminA': 3.0, 'vitaminC': 5.0, 'vitaminD': 0.0, 'vitaminE': 1.1, 'vitaminK': 13.0},
        ),
      ],
    );

    final sample2 = FoodPost.fromItems(
      id: 'sample_post_2',
      userId: 'usr_sample_1',
      mealType: MealType.lunch,
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
      title: 'Grilled Herb Chicken with Brown Rice',
      notes: 'High protein recovery lunch',
      createdAt: now.subtract(const Duration(hours: 2)),
      mealDate: now,
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
    );

    _localPosts[sample1.id] = sample1;
    _localPosts[sample2.id] = sample2;
  }

  /// Uploads food photo to Firebase Storage (`food_images/{userId}/{postId}/image.jpg`)
  /// with resilience, progress reporting, and base64 fallback when offline or in tests.
  Future<String> uploadFoodImage({
    required String userId,
    required String postId,
    required Uint8List imageBytes,
    void Function(double progress)? onProgress,
  }) async {
    final effectiveUserId = userId.isNotEmpty ? userId : 'guest_user';
    final storagePath = 'food_images/$effectiveUserId/$postId/image.jpg';

    if (_storage != null) {
      try {
        final ref = _storage.ref().child(storagePath);
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': effectiveUserId,
            'postId': postId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );

        final uploadTask = ref.putData(imageBytes, metadata);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0 && onProgress != null) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress(progress);
          }
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        debugPrint('[FoodPostService] Image successfully uploaded to Storage: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        debugPrint('[FoodPostService] Storage upload failed, falling back to data URL: $e');
      }
    }

    // Local fallback: create data URI
    onProgress?.call(1.0);
    final base64String = base64Encode(imageBytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  /// Creates a new food post in Firestore & local cache
  Future<FoodPost> createFoodPost(FoodPost post) async {
    _localPosts[post.id] = post;
    _notifyLocalStream(post.userId);

    if (_firestore != null && post.userId.isNotEmpty) {
      try {
        await _firestore.collection('foodPosts').doc(post.id).set(post.toFirestoreMap());
      } catch (e) {
        debugPrint('[FoodPostService] Firestore create failed: $e');
      }
    }

    return post;
  }

  /// Updates an existing food post (e.g. after user edits portion, foods, notes)
  Future<FoodPost> updateFoodPost(FoodPost post) async {
    final updated = post.copyWith(updatedAt: DateTime.now());
    _localPosts[updated.id] = updated;
    _notifyLocalStream(updated.userId);

    if (_firestore != null && updated.userId.isNotEmpty) {
      try {
        await _firestore.collection('foodPosts').doc(updated.id).update(updated.toFirestoreMap());
      } catch (e) {
        debugPrint('[FoodPostService] Firestore update failed: $e');
      }
    }

    return updated;
  }

  /// Deletes a food post from Firestore & local cache
  Future<void> deleteFoodPost(String postId, {String? userId}) async {
    final post = _localPosts.remove(postId);
    final uid = userId ?? post?.userId ?? '';
    _notifyLocalStream(uid);

    if (_firestore != null) {
      try {
        await _firestore.collection('foodPosts').doc(postId).delete();
      } catch (e) {
        debugPrint('[FoodPostService] Firestore delete failed: $e');
      }
    }

    // Also delete associated storage image if present
    if (_storage != null && post != null && post.imagePath.isNotEmpty) {
      try {
        await _storage.ref().child(post.imagePath).delete();
      } catch (_) {}
    }
  }

  /// Streams food posts for a specific user ordered by createdAt descending
  Stream<List<FoodPost>> streamUserFoodPosts(String userId) {
    if (_firestore != null && userId.isNotEmpty) {
      return _firestore
          .collection('foodPosts')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((doc) {
          final data = Map<String, dynamic>.from(doc.data());
          if (!data.containsKey('id') || (data['id']?.toString().isEmpty ?? true)) {
            data['id'] = doc.id;
          }
          final post = FoodPost.fromMap(data);
          _localPosts[post.id] = post;
          return post;
        }).toList();

        list.sort((a, b) => b.mealDate.compareTo(a.mealDate));
        return list;
      });
    }

    // Local stream fallback
    return _localPostsStreamController.stream.map((_) {
      final userPosts = _localPosts.values
          .where((p) => p.userId == userId || userId.isEmpty || p.userId == 'usr_sample_1')
          .toList();
      userPosts.sort((a, b) => b.mealDate.compareTo(a.mealDate));
      return userPosts;
    });
  }

  /// Fetches food posts for a specific user on a specific date (YYYY-MM-DD)
  Future<List<FoodPost>> getFoodPostsForDate(String userId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;

    // Check local posts first
    final matching = _localPosts.values.where((p) {
      final pDate = p.mealDate.toIso8601String().split('T').first;
      return (p.userId == userId || userId.isEmpty || p.userId == 'usr_sample_1') && pDate == dateStr;
    }).toList();

    if (matching.isNotEmpty || _firestore == null || userId.isEmpty) {
      matching.sort((a, b) => a.mealDate.compareTo(b.mealDate));
      return matching;
    }

    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('foodPosts')
          .where('userId', isEqualTo: userId)
          .where('mealDate', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('mealDate', isLessThan: end.toIso8601String())
          .get();

      final list = snapshot.docs.map((d) => FoodPost.fromMap(d.data(), docId: d.id)).toList();
      for (final p in list) {
        _localPosts[p.id] = p;
      }
      list.sort((a, b) => a.mealDate.compareTo(b.mealDate));
      return list;
    } catch (_) {
      return matching;
    }
  }

  /// Fetches food posts across a date range (for weekly insights & monthly reports)
  Future<List<FoodPost>> getFoodPostsForDateRange(String userId, DateTime start, DateTime end) async {
    final matching = _localPosts.values.where((p) {
      return (p.userId == userId || userId.isEmpty || p.userId == 'usr_sample_1') &&
          p.mealDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
          p.mealDate.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();

    if (_firestore != null && userId.isNotEmpty) {
      try {
        final snapshot = await _firestore
            .collection('foodPosts')
            .where('userId', isEqualTo: userId)
            .where('mealDate', isGreaterThanOrEqualTo: start.toIso8601String())
            .where('mealDate', isLessThanOrEqualTo: end.toIso8601String())
            .get();

        final fetched = snapshot.docs.map((d) => FoodPost.fromMap(d.data(), docId: d.id)).toList();
        for (final p in fetched) {
          _localPosts[p.id] = p;
        }
        fetched.sort((a, b) => b.mealDate.compareTo(a.mealDate));
        return fetched;
      } catch (_) {}
    }

    matching.sort((a, b) => b.mealDate.compareTo(a.mealDate));
    return matching;
  }

  /// Adds trainer feedback to a client's food post
  Future<void> addTrainerFeedback(TrainerFoodFeedback feedback) async {
    _localFeedback.putIfAbsent(feedback.postId, () => []).add(feedback);

    if (_firestore != null) {
      try {
        await _firestore
            .collection('trainerFeedback')
            .doc(feedback.id)
            .set(feedback.toFirestoreMap());
      } catch (e) {
        debugPrint('[FoodPostService] Error saving trainer feedback: $e');
      }
    }
  }

  /// Streams trainer feedback for a specific post
  Stream<List<TrainerFoodFeedback>> streamFeedbackForPost(String postId) {
    if (_firestore != null) {
      return _firestore
          .collection('trainerFeedback')
          .where('postId', isEqualTo: postId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs.map((d) => TrainerFoodFeedback.fromMap(d.data(), docId: d.id)).toList();
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return list;
      });
    }

    final localList = _localFeedback[postId] ?? [];
    return Stream.value(localList);
  }

  void _notifyLocalStream(String userId) {
    final list = _localPosts.values.where((p) => p.userId == userId || userId.isEmpty).toList();
    _localPostsStreamController.add(list);
  }

  void dispose() {
    _localPostsStreamController.close();
  }
}
