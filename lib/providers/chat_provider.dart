import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message.dart';
import '../models/user_profile.dart';
import '../models/linux_command.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  UserProfile? _currentUser;
  Timer? _autoSaveTimer;

  final AIService _aiService = AIService();
  final ScrollController scrollController = ScrollController();

  // Getters
  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  UserProfile? get currentUser => _currentUser;
  bool get hasMessages => _messages.isNotEmpty;

  int get totalMessages => _messages.length;
  int get userMessages => _messages.where((m) => m.isUser).length;
  int get botMessages => _messages.where((m) => !m.isUser).length;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user profile
      _currentUser = StorageService.getOrCreateDefaultProfile();

      // Load existing messages
      _messages = StorageService.getAllMessages();

      // If no messages, show welcome message
      if (_messages.isEmpty) {
        await _addWelcomeMessage();
      }

      // Start auto-save timer
      _startAutoSave();

    } catch (e) {
      debugPrint('Error initializing chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _addWelcomeMessage() async {
    final welcomeMessage = Message(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      text: _getPersonalizedWelcomeMessage(),
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.system,
    );

    _messages.add(welcomeMessage);
    await StorageService.saveMessage(welcomeMessage);
  }

  String _getPersonalizedWelcomeMessage() {
    if (_currentUser == null) return 'สวัสดีครับ! ยินดีต้อนรับ';

    final greetings = _getTimeBasedGreeting();
    final level = _currentUser!.level;
    final learnedCount = _currentUser!.learnedCommands.length;

    String message = '$greetings ${_currentUser!.name}! 🎓\n\n';

    if (learnedCount == 0) {
      message += '''
ยินดีต้อนรับสู่ระบบเรียนรู้คำสั่ง Linux สำหรับนักศึกษา!

🚀 **เริ่มต้นการเรียนรู้:**
• พิมพ์ "แนะนำคำสั่งพื้นฐาน" เพื่อเริ่มต้น
• ถามเกี่ยวกับคำสั่งที่สนใจ เช่น "ls คืออะไร"
• พิมพ์ "ช่วยเหลือ" เพื่อดูคำแนะนำ

มาเริ่มเรียนรู้ Linux กันเถอะ! 💪''';
    } else {
      message += '''
ยินดีต้อนรับกลับมา! 🌟

📊 **สถิติของคุณ:**
• ระดับ: ${level.emoji} ${level.displayName}
• คำสั่งที่เรียนรู้: $learnedCount คำสั่ง
• วันติดต่อกัน: ${_currentUser!.streakDays} วัน 🔥

${_getPersonalizedSuggestion()}''';
    }

    return message;
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'สวัสดีตอนเช้า';
    if (hour < 17) return 'สวัสดีตอนบ่าย';
    return 'สวัสดีตอนเย็น';
  }

  String _getPersonalizedSuggestion() {
    if (_currentUser == null) return '';

    final level = _currentUser!.level;
    final recentCommands = _currentUser!.learnedCommands.take(3).toList();

    switch (level) {
      case UserLevel.beginner:
        return 'เริ่มต้นด้วยคำสั่งพื้นฐาน เช่น pwd, ls, cd';
      case UserLevel.intermediate:
        return 'ลองเรียนรู้ grep, find, chmod เพิ่มเติม';
      case UserLevel.advanced:
        return 'เรียนรู้ scripting และ system administration';
      case UserLevel.expert:
        return 'สำรวจคำสั่งขั้นสูง เช่น awk, sed, systemctl';
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _isTyping) return;

    // Create user message
    final userMessage = Message(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message
    _messages.add(userMessage);
    await StorageService.saveMessage(userMessage);

    // Update user interaction
    if (_currentUser != null) {
      _currentUser!.totalInteractions++;
      _currentUser!.updateStreak();
      await StorageService.updateUserProfile(_currentUser!);
    }

    notifyListeners();
    _scrollToBottom();

    // Show typing indicator
    _setTyping(true);

    try {
      // Generate AI response
      final response = await _aiService.generateResponse(text, _currentUser!);

      // Add AI response
      _messages.add(response);
      await StorageService.saveMessage(response);

      // Check for achievements after interaction
      _checkAndAwardAchievements();

    } catch (e) {
      // Add error message
      final errorMessage = Message(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        text: 'ขออภัยครับ เกิดข้อผิดพลาดในการประมวลผล กรุณาลองใหม่อีกครั้ง 😅',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.error,
      );

      _messages.add(errorMessage);
      await StorageService.saveMessage(errorMessage);

      debugPrint('Error generating response: $e');
    } finally {
      _setTyping(false);
      _scrollToBottom();
    }
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Message management
  Future<void> deleteMessage(String messageId) async {
    _messages.removeWhere((message) => message.id == messageId);
    await StorageService.deleteMessage(messageId);
    notifyListeners();
  }

  Future<void> toggleMessageStar(String messageId) async {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      final message = _messages[messageIndex];
      final updatedMessage = message.copyWith(isStarred: !message.isStarred);
      _messages[messageIndex] = updatedMessage;

      await StorageService.saveMessage(updatedMessage);
      notifyListeners();
    }
  }

  Future<void> clearAllMessages() async {
    _messages.clear();
    await StorageService.clearAllMessages();
    await _addWelcomeMessage();
    notifyListeners();
  }

  // Search functionality
  List<Message> searchMessages(String query) {
    if (query.trim().isEmpty) return _messages;

    return _messages.where((message) =>
    message.text.toLowerCase().contains(query.toLowerCase()) ||
        (message.command?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  List<Message> getStarredMessages() {
    return _messages.where((message) => message.isStarred).toList();
  }

  List<Message> getMessagesByType(MessageType type) {
    return _messages.where((message) => message.type == type).toList();
  }

  // User profile management
  Future<void> updateUserProfile(UserProfile profile) async {
    _currentUser = profile;
    await StorageService.updateUserProfile(profile);
    notifyListeners();
  }

  Future<void> addLearnedCommand(String command) async {
    if (_currentUser != null) {
      _currentUser!.addLearnedCommand(command);
      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    }
  }

  // Quick actions
  Future<void> sendQuickMessage(String predefinedMessage) async {
    await sendMessage(predefinedMessage);
  }

  Future<void> requestHelp() async {
    await sendMessage('ช่วยเหลือ');
  }

  Future<void> requestRecommendations() async {
    await sendMessage('แนะนำคำสั่งสำหรับฉัน');
  }

  Future<void> requestLevelAssessment() async {
    await sendMessage('ประเมินระดับของฉัน');
  }

  Future<void> requestQuiz() async {
    await sendMessage('ทดสอบความรู้');
  }

  // Statistics
  Map<String, int> getMessageStats() {
    final stats = <String, int>{};
    for (final type in MessageType.values) {
      stats[type.name] = _messages.where((m) => m.type == type).length;
    }
    return stats;
  }

  Map<String, int> getDailyMessageCounts(int days) {
    final counts = <String, int>{};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.day}/${date.month}';

      counts[dateKey] = _messages.where((message) {
        final messageDate = message.timestamp;
        return messageDate.day == date.day &&
            messageDate.month == date.month &&
            messageDate.year == date.year;
      }).length;
    }

    return counts;
  }

  // Auto-save functionality
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _autoSave();
    });
  }

  Future<void> _autoSave() async {
    if (_currentUser != null && StorageService.getAutoSaveEnabled()) {
      await StorageService.updateUserProfile(_currentUser!);
    }
  }

  // Achievement system
  void _checkAndAwardAchievements() {
    if (_currentUser == null) return;

    final oldAchievementCount = _currentUser!.achievements.length;
    _currentUser!._checkAchievements(); // This is a private method, we'd need to make it public or create a public wrapper

    if (_currentUser!.achievements.length > oldAchievementCount) {
      // New achievement unlocked!
      final newAchievement = _currentUser!.achievements.last;
      _showAchievementMessage(newAchievement);
    }
  }

  Future<void> _showAchievementMessage(Achievement achievement) async {
    final achievementMessage = Message(
      id: 'achievement_${DateTime.now().millisecondsSinceEpoch}',
      text: '''
🎉 **ยินดีด้วย! คุณได้รับความสำเร็จใหม่**

${achievement.icon} **${achievement.title}**
${achievement.description}

+${achievement.points} คะแนน
''',
      isUser: false,
      timestamp: DateTime.now(),
      type: MessageType.success,
    );

    _messages.add(achievementMessage);
    await StorageService.saveMessage(achievementMessage);
    notifyListeners();
  }

  // Export functionality
  Future<Map<String, dynamic>> exportChatHistory() async {
    return {
      'messages': _messages.map((m) => m.toJson()).toList(),
      'userProfile': _currentUser?.toJson(),
      'exportDate': DateTime.now().toIso8601String(),
      'totalMessages': _messages.length,
    };
  }

  // Voice input support (placeholder for future implementation)
  bool _isListening = false;
  bool get isListening => _isListening;

  void startListening() {
    _isListening = true;
    notifyListeners();
    // Implement voice recognition here
  }

  void stopListening() {
    _isListening = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}