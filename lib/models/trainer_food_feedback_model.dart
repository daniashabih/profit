/// Trainer feedback on client food posts: trainerFeedback/{feedbackId}
class TrainerFoodFeedback {
  final String id;
  final String postId;
  final String clientUserId;
  final String trainerId;
  final String trainerName;
  final String? trainerAvatarUrl;
  final String comment;
  final DateTime createdAt;

  const TrainerFoodFeedback({
    required this.id,
    required this.postId,
    required this.clientUserId,
    required this.trainerId,
    required this.trainerName,
    this.trainerAvatarUrl,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'clientUserId': clientUserId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      if (trainerAvatarUrl != null) 'trainerAvatarUrl': trainerAvatarUrl,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestoreMap() => toMap();

  factory TrainerFoodFeedback.fromMap(Map<String, dynamic> map, {String? docId}) {
    return TrainerFoodFeedback(
      id: map['id']?.toString() ?? docId ?? '',
      postId: map['postId']?.toString() ?? '',
      clientUserId: map['clientUserId']?.toString() ?? '',
      trainerId: map['trainerId']?.toString() ?? '',
      trainerName: map['trainerName']?.toString() ?? 'Coach',
      trainerAvatarUrl: map['trainerAvatarUrl']?.toString(),
      comment: map['comment']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
