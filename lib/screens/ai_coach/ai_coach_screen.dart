import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_coach_provider.dart';
import '../../providers/workout_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/fit_flow_button.dart';
import '../../widgets/common/fit_flow_card.dart';
import '../workout/workout_screen.dart';
import '../nutrition/nutrition_screen.dart';

class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  bool _showChat = false;
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    context.read<AiCoachProvider>().sendUserMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aiProv = context.watch<AiCoachProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          _showChat ? 'AI Coach Chat' : 'Daily Guidance',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          // Toggle button between Daily Suggestion & Interactive Chat
          IconButton(
            tooltip: _showChat ? 'View Daily Plan' : 'Open AI Chat',
            icon: Icon(
              _showChat ? Icons.dashboard_outlined : Icons.chat_bubble_outline_rounded,
              color: AppColors.primaryLime,
            ),
            onPressed: () => setState(() => _showChat = !_showChat),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _showChat ? _buildChatView(context, isDark, aiProv) : _buildDailySuggestionView(context, isDark),
    );
  }

  // Screen 16 Layout: "What should I do today?"
  Widget _buildDailySuggestionView(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'What should I do today?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Based on your plan and goals',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // 4 Suggestion Cards in 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
            children: [
              // 1. Workout Card
              _buildSuggestionCard(
                context,
                title: 'Workout',
                subtitle: 'Upper Body Strength',
                detail: '45 mins • 7 exercises',
                icon: Icons.fitness_center_rounded,
                accentColor: AppColors.primaryLime,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorkoutScreen()),
                  );
                },
              ),

              // 2. Nutrition Card
              _buildSuggestionCard(
                context,
                title: 'Nutrition',
                subtitle: '1,800 kcal Target',
                detail: '120g protein • Log meals',
                icon: Icons.restaurant_rounded,
                accentColor: AppColors.proteinColor,
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NutritionScreen()),
                  );
                },
              ),

              // 3. Recovery Card
              _buildSuggestionCard(
                context,
                title: 'Recovery',
                subtitle: 'Rest & Stretch',
                detail: '15 mins mobility • Relax',
                icon: Icons.self_improvement_rounded,
                accentColor: AppColors.carbsColor,
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting 15-minute guided dynamic mobility stretch...')),
                  );
                },
              ),

              // 4. Hydration Card
              _buildSuggestionCard(
                context,
                title: 'Hydration',
                subtitle: '2.5L Daily Goal',
                detail: '1.8L logged • 72%',
                icon: Icons.water_drop_rounded,
                accentColor: const Color(0xFF38BDF8),
                isDark: isDark,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('+250ml water added! Keep staying hydrated 💧')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Primary "Let's Go →" Button
          FitFlowButton(
            text: "Let's Go →",
            height: 52,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutScreen()),
              );
            },
          ),
          const SizedBox(height: 24),

          // Bottom Quote / Inspiration Card (Screen 16 mockup)
          FitFlowCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLime.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.format_quote_rounded,
                    color: AppColors.primaryLime,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '"Small steps every day lead to big results."',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PROFIT Daily Motivation',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Chat Switch Prompt
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.primaryLime),
              label: const Text(
                'Have questions? Ask AI Coach',
                style: TextStyle(
                  color: AppColors.primaryLime,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              onPressed: () => setState(() => _showChat = true),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Interactive AI Companion Chat
  Widget _buildChatView(BuildContext context, bool isDark, AiCoachProvider aiProv) {
    return Column(
      children: [
        // Chat Messages List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: aiProv.messages.length,
            itemBuilder: (context, index) {
              final msg = aiProv.messages[index];
              return _buildMessageBubble(context, msg, isDark);
            },
          ),
        ),

        // Thinking indicator
        if (aiProv.isThinking)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLime),
                ),
                const SizedBox(width: 10),
                Text(
                  'Coach is typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

        // Message Input Field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask about form, diet, or recovery...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                    ),
                    onSubmitted: _handleSend,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLime,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF111827), size: 20),
                    onPressed: () => _handleSend(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, dynamic msg, bool isDark) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? (isDark ? AppColors.primaryLime : const Color(0xFF111827))
                    : (isDark ? AppColors.darkSurface : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: Border.all(
                  color: isUser
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              child: Text(
                msg.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isUser
                      ? (isDark ? const Color(0xFF111827) : Colors.white)
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
            if (msg.actionChips != null && (msg.actionChips as List).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (msg.actionChips as List<String>).map((chip) {
                    return GestureDetector(
                      onTap: () => _handleSend(chip),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          chip,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.primaryLime : const Color(0xFF111827),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
