class AiMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionChips;

  AiMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.actionChips,
  });
}

abstract class AiCoachService {
  Future<String> getDailyRecommendation();
  Future<AiMessage> sendMessage(String userPrompt, List<AiMessage> history);
}

class ExtensibleAiCoachService implements AiCoachService {
  // Optional API key for Gemini or OpenAI integration
  final String? apiKey;

  ExtensibleAiCoachService({this.apiKey});

  @override
  Future<String> getDailyRecommendation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return "Hi Alex! 👋 Based on your recent activity, you've trained 3 days this week. Today would be a great day for an Upper Body session focusing on chest and back.";
  }

  @override
  Future<AiMessage> sendMessage(String userPrompt, List<AiMessage> history) async {
    // If apiKey is present, standard HTTP POST to Gemini / OpenAI endpoint
    // Fallback to intelligent conversational response engine:
    await Future.delayed(const Duration(milliseconds: 600));

    final promptLower = userPrompt.toLowerCase();
    String reply = '';
    List<String>? suggestions;

    if (promptLower.contains('sore') || promptLower.contains('recovery') || promptLower.contains('rest')) {
      reply = "It's completely normal to feel sore after progressive overload! 🧘 Make sure to hydrate with at least 3L of water, consume 25-30g of protein within your next meal, and consider 10 minutes of light dynamic stretching.";
      suggestions = ['Show recovery routine', 'Log rest day', 'Check protein intake'];
    } else if (promptLower.contains('protein') || promptLower.contains('diet') || promptLower.contains('eat') || promptLower.contains('nutrition')) {
      reply = "To support muscle repair and fat loss, aim for 1.6 to 2.2g of protein per kg of body weight. For you (~74.5 kg), that's roughly 140-155g daily! Chicken breast, Greek yogurt, eggs, and whey protein are fantastic choices.";
      suggestions = ['Log a meal', 'View macro balance', 'High-protein recipes'];
    } else if (promptLower.contains('workout') || promptLower.contains('exercise') || promptLower.contains('train')) {
      reply = "Today's scheduled workout is 'Upper Body Focus' with 7 compound and isolation exercises. You're already 70% through your weekly volume target!";
      suggestions = ['Start Workout Now', 'Swap an exercise', 'Adjust rest time'];
    } else if (promptLower.contains('weight') || promptLower.contains('lose') || promptLower.contains('gain')) {
      reply = "You've dropped 6.5 kg since your starting weight—fantastic consistency! Focus on keeping your weekly rate of change between 0.3-0.5 kg to protect lean muscle tissue.";
      suggestions = ['View Weight Chart', 'Log current weight', 'Recalculate calories'];
    } else {
      reply = "You're making great progress towards your fitness goals! Remember that consistency beats intensity over time. How are you feeling physically today?";
      suggestions = ['Ready to train', 'Feeling fatigued', 'Ask nutrition question'];
    }

    return AiMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      content: reply,
      isUser: false,
      timestamp: DateTime.now(),
      actionChips: suggestions,
    );
  }
}
