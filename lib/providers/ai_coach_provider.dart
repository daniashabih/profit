import 'package:flutter/material.dart';
import '../services/ai_coach_service.dart';

class AiCoachProvider extends ChangeNotifier {
  final AiCoachService _aiService;
  final List<AiMessage> _messages = [];
  bool _isThinking = false;
  String _dailyRecommendation = '';

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isThinking => _isThinking;
  String get dailyRecommendation => _dailyRecommendation;

  AiCoachProvider({required AiCoachService aiService}) : _aiService = aiService {
    _init();
  }

  Future<void> _init() async {
    _dailyRecommendation = await _aiService.getDailyRecommendation();

    // Initial greeting message
    _messages.add(
      AiMessage(
        id: 'init_greeting',
        content: "Hi Alex! 👋 Based on your recent activity, you've trained 3 days this week. Today would be a great day for an Upper Body session. What would you like to focus on today?",
        isUser: false,
        timestamp: DateTime.now(),
        actionChips: ['Start Workout', 'Swap Exercises', 'Nutrition Advice', 'Rest & Recovery'],
      ),
    );
    notifyListeners();
  }

  Future<void> sendUserMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMsg = AiMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isThinking = true;
    notifyListeners();

    final aiReply = await _aiService.sendMessage(content, _messages);

    _messages.add(aiReply);
    _isThinking = false;
    notifyListeners();
  }
}
