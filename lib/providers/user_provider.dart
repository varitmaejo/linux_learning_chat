import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  bool _hasNewAchievement = false;
  bool _hasUncompletedQuiz = false;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get hasNewAchievement => _hasNewAchievement;
  bool get hasUncompletedQuiz => _hasUncompletedQuiz;
  bool get isLoggedIn => _currentUser != null;

  // User info getters
  String get userName => _currentUser?.name ?? 'ผู้ใช้';
  UserLevel get userLevel => _currentUser?.level ?? UserLevel.beginner;
  int get learnedCommandsCount => _currentUser?.learnedCommands.length ?? 0;
  int get totalInteractions => _currentUser?.totalInteractions ?? 0;
  int get streakDays => _currentUser?.streakDays ?? 0;
  int get experiencePoints => _currentUser?.experiencePoints ?? 0;
  double get progressPercentage => _currentUser?.progressPercentage ?? 0.0;
  List<Achievement> get achievements => _currentUser?.achievements ?? [];
  List<String> get learnedCommands => _currentUser?.learnedCommands ?? [];

  UserProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = StorageService.getOrCreateDefaultProfile();
      _checkForNewAchievements();
      _checkForUncompletedQuiz();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? university,
    String? faculty,
    UserLevel? level,
  }) async {
    if (_currentUser == null) return;

    try {
      _currentUser = UserProfile(
        id: _currentUser!.id,
        name: name ?? _currentUser!.name,
        university: university ?? _currentUser!.university,
        faculty: faculty ?? _currentUser!.faculty,
        level: level ?? _currentUser!.level,
        learnedCommands: _currentUser!.learnedCommands,
        commandUsage: _currentUser!.commandUsage,
        totalInteractions: _currentUser!.totalInteractions,
        createdAt: _currentUser!.createdAt,
        lastActiveAt: DateTime.now(),
        preferences: _currentUser!.preferences,
        achievements: _currentUser!.achievements,
        studyStats: _currentUser!.studyStats,
        favoriteCommands: _currentUser!.favoriteCommands,
        categoryProgress: _currentUser!.categoryProgress,
        streakDays: _currentUser!.streakDays,
        lastStudyDate: _currentUser!.lastStudyDate,
        currentGoal: _currentUser!.currentGoal,
        quizHistory: _currentUser!.quizHistory,
        avatarUrl: _currentUser!.avatarUrl,
      );

      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }

  Future<void> addLearnedCommand(String command) async {
    if (_currentUser == null) return;

    try {
      final oldCount = _currentUser!.learnedCommands.length;
      _currentUser!.addLearnedCommand(command);

      await StorageService.updateUserProfile(_currentUser!);

      // Check if level up occurred
      if (_currentUser!.learnedCommands.length > oldCount) {
        _checkForLevelUp();
        _checkForNewAchievements();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding learned command: $e');
    }
  }

  Future<void> incrementCommandUsage(String command) async {
    if (_currentUser == null) return;

    try {
      _currentUser!.incrementCommandUsage(command);
      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing command usage: $e');
    }
  }

  Future<void> addQuizResult(QuizResult result) async {
    if (_currentUser == null) return;

    try {
      _currentUser!.addQuizResult(result);
      await StorageService.updateUserProfile(_currentUser!);

      _checkForNewAchievements();
      _checkForUncompletedQuiz();

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding quiz result: $e');
    }
  }

  Future<void> updateStudyStreak() async {
    if (_currentUser == null) return;

    try {
      _currentUser!.updateStreak();
      await StorageService.updateUserProfile(_currentUser!);

      _checkForNewAchievements();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating study streak: $e');
    }
  }

  void _checkForLevelUp() {
    if (_currentUser == null) return;

    final calculatedLevel = _currentUser!.calculatedLevel;
    if (calculatedLevel != _currentUser!.level) {
      _currentUser!.level = calculatedLevel;

      // Add level up achievement
      final levelUpAchievement = Achievement(
        id: 'level_up_${calculatedLevel.name}',
        title: 'เลื่อนระดับ!',
        description: 'เลื่อนระดับเป็น ${calculatedLevel.displayName}',
        icon: calculatedLevel.emoji,
        unlockedAt: DateTime.now(),
        points: 200,
      );

      _currentUser!.achievements.add(levelUpAchievement);
      _hasNewAchievement = true;
    }
  }

  void _checkForNewAchievements() {
    if (_currentUser == null) return;

    final oldAchievementCount = _currentUser!.achievements.length;
    // The _checkAchievements method would be called here
    // but it's private in the UserProfile class

    // For now, we'll simulate checking for new achievements
    _checkBasicAchievements();

    if (_currentUser!.achievements.length > oldAchievementCount) {
      _hasNewAchievement = true;
    }
  }

  void _checkBasicAchievements() {
    if (_currentUser == null) return;

    // First command achievement
    if (_currentUser!.learnedCommands.isNotEmpty &&
        !_hasAchievement('first_command')) {
      _addAchievement(Achievement(
        id: 'first_command',
        title: 'ก้าวแรก',
        description: 'เรียนรู้คำสั่ง Linux คำสั่งแรก',
        icon: '🎯',
        unlockedAt: DateTime.now(),
      ));
    }

    // 5 commands achievement
    if (_currentUser!.learnedCommands.length >= 5 &&
        !_hasAchievement('five_commands')) {
      _addAchievement(Achievement(
        id: 'five_commands',
        title: 'นักเรียนใหม่',
        description: 'เรียนรู้คำสั่ง 5 คำสั่ง',
        icon: '⭐',
        unlockedAt: DateTime.now(),
      ));
    }

    // 10 commands achievement
    if (_currentUser!.learnedCommands.length >= 10 &&
        !_hasAchievement('ten_commands')) {
      _addAchievement(Achievement(
        id: 'ten_commands',
        title: 'ผู้เชี่ยวชาญใหม่',
        description: 'เรียนรู้คำสั่ง 10 คำสั่ง',
        icon: '🌟',
        unlockedAt: DateTime.now(),
      ));
    }

    // Streak achievements
    if (_currentUser!.streakDays >= 3 &&
        !_hasAchievement('three_day_streak')) {
      _addAchievement(Achievement(
        id: 'three_day_streak',
        title: 'นิสัยดี',
        description: 'เรียนติดต่อกัน 3 วัน',
        icon: '🔥',
        unlockedAt: DateTime.now(),
      ));
    }

    if (_currentUser!.streakDays >= 7 &&
        !_hasAchievement('week_streak')) {
      _addAchievement(Achievement(
        id: 'week_streak',
        title: 'นักเรียนขยัน',
        description: 'เรียนติดต่อกัน 7 วัน',
        icon: '🏆',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  bool _hasAchievement(String achievementId) {
    return _currentUser!.achievements.any((a) => a.id == achievementId);
  }

  void _addAchievement(Achievement achievement) {
    _currentUser!.achievements.add(achievement);
    _hasNewAchievement = true;
  }

  void _checkForUncompletedQuiz() {
    // Check if user has any recommended quizzes based on their progress
    if (_currentUser == null) return;

    final commandCount = _currentUser!.learnedCommands.length;
    final lastQuizDate = _currentUser!.quizHistory.isNotEmpty
        ? _currentUser!.quizHistory.last.completedAt
        : null;

    // Suggest quiz if user learned 5+ commands but hasn't taken quiz in 3 days
    if (commandCount >= 5) {
      if (lastQuizDate == null) {
        _hasUncompletedQuiz = true;
      } else {
        final daysSinceLastQuiz = DateTime.now().difference(lastQuizDate).inDays;
        _hasUncompletedQuiz = daysSinceLastQuiz >= 3;
      }
    }
  }

  void markAchievementAsViewed() {
    _hasNewAchievement = false;
    notifyListeners();
  }

  void markQuizAsCompleted() {
    _hasUncompletedQuiz = false;
    notifyListeners();
  }

  // Preferences management
  Future<void> updatePreference(String key, dynamic value) async {
    if (_currentUser == null) return;

    try {
      _currentUser!.preferences[key] = value;
      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating preference: $e');
    }
  }

  T? getPreference<T>(String key, [T? defaultValue]) {
    if (_currentUser == null) return defaultValue;
    return _currentUser!.preferences[key] as T? ?? defaultValue;
  }

  // Study goals
  Future<void> setStudyGoal(StudyGoal goal) async {
    if (_currentUser == null) return;

    try {
      _currentUser!.currentGoal = goal;
      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting study goal: $e');
    }
  }

  Future<void> updateGoalProgress(int progress) async {
    if (_currentUser?.currentGoal == null) return;

    try {
      _currentUser!.currentGoal!.currentValue = progress;

      if (progress >= _currentUser!.currentGoal!.targetValue) {
        _currentUser!.currentGoal!.isCompleted = true;

        // Add goal completion achievement
        _addAchievement(Achievement(
          id: 'goal_${_currentUser!.currentGoal!.id}',
          title: 'บรรลุเป้าหมาย!',
          description: _currentUser!.currentGoal!.title,
          icon: '🎯',
          unlockedAt: DateTime.now(),
          points: 150,
        ));
      }

      await StorageService.updateUserProfile(_currentUser!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating goal progress: $e');
    }
  }

  // Statistics
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) return {};

    return {
      'totalCommands': _currentUser!.learnedCommands.length,
      'totalInteractions': _currentUser!.totalInteractions,
      'streakDays': _currentUser!.streakDays,
      'experiencePoints': _currentUser!.experiencePoints,
      'achievements': _currentUser!.achievements.length,
      'quizzesTaken': _currentUser!.quizHistory.length,
      'quizzesPassed': _currentUser!.quizHistory.where((q) => q.passed).length,
      'studyTime': _currentUser!.studyStats.totalStudyTime,
      'level': _currentUser!.level.displayName,
      'progressPercentage': _currentUser!.progressPercentage,
    };
  }

  List<Achievement> getRecentAchievements({int limit = 5}) {
    if (_currentUser == null) return [];

    final achievements = List<Achievement>.from(_currentUser!.achievements);
    achievements.sort((a, b) => b.unlockedAt.compareTo(a.unlockedAt));
    return achievements.take(limit).toList();
  }

  List<QuizResult> getRecentQuizResults({int limit = 5}) {
    if (_currentUser == null) return [];

    final results = List<QuizResult>.from(_currentUser!.quizHistory);
    results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return results.take(limit).toList();
  }

  Map<String, int> getCommandUsageStats() {
    if (_currentUser == null) return {};

    // Get top 10 most used commands
    final entries = _currentUser!.commandUsage.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(entries.take(10));
  }

  // Data management
  Future<bool> exportUserData() async {
    if (_currentUser == null) return false;

    try {
      final data = await StorageService.exportUserData(_currentUser!.id);
      // In a real app, you would save this to a file or share it
      debugPrint('User data exported: ${data.length} bytes');
      return true;
    } catch (e) {
      debugPrint('Error exporting user data: $e');
      return false;
    }
  }

  Future<bool> resetUserData() async {
    if (_currentUser == null) return false;

    try {
      // Keep basic profile info but reset progress
      final newProfile = UserProfile(
        id: _currentUser!.id,
        name: _currentUser!.name,
        university: _currentUser!.university,
        faculty: _currentUser!.faculty,
        level: UserLevel.beginner,
      );

      await StorageService.saveUserProfile(newProfile);
      _currentUser = newProfile;

      _hasNewAchievement = false;
      _hasUncompletedQuiz = false;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error resetting user data: $e');
      return false;
    }
  }

  // Study session tracking
  DateTime? _sessionStartTime;

  void startStudySession() {
    _sessionStartTime = DateTime.now();
  }

  Future<void> endStudySession() async {
    if (_sessionStartTime == null || _currentUser == null) return;

    try {
      final duration = DateTime.now().difference(_sessionStartTime!);
      final minutes = duration.inMinutes;

      if (minutes > 0) {
        _currentUser!.studyStats.totalStudyTime += minutes;
        await StorageService.addStudySession(minutes);
        await StorageService.updateUserProfile(_currentUser!);

        // Update streak
        await updateStudyStreak();

        notifyListeners();
      }

      _sessionStartTime = null;
    } catch (e) {
      debugPrint('Error ending study session: $e');
    }
  }

  Duration? getCurrentSessionDuration() {
    if (_sessionStartTime == null) return null;
    return DateTime.now().difference(_sessionStartTime!);
  }

  bool get isInStudySession => _sessionStartTime != null;

  // Recommendations
  List<String> getRecommendedCommands() {
    if (_currentUser == null) return [];

    final learned = _currentUser!.learnedCommands.toSet();
    final allCommands = [
      'ls', 'cd', 'pwd', 'mkdir', 'rm', 'cp', 'mv', 'grep', 'find', 'chmod',
      'chown', 'sudo', 'ps', 'top', 'kill', 'cat', 'less', 'head', 'tail',
      'tar', 'gzip', 'wget', 'curl', 'ssh', 'scp', 'awk', 'sed', 'sort'
    ];

    // Filter out already learned commands
    final unlearned = allCommands.where((cmd) => !learned.contains(cmd)).toList();

    // Recommend based on level
    switch (_currentUser!.level) {
      case UserLevel.beginner:
        return unlearned.where((cmd) =>
            ['ls', 'cd', 'pwd', 'mkdir', 'cat', 'cp', 'mv'].contains(cmd)
        ).take(3).toList();

      case UserLevel.intermediate:
        return unlearned.where((cmd) =>
            ['grep', 'find', 'chmod', 'ps', 'kill', 'head', 'tail'].contains(cmd)
        ).take(4).toList();

      case UserLevel.advanced:
        return unlearned.where((cmd) =>
            ['awk', 'sed', 'tar', 'ssh', 'wget', 'curl'].contains(cmd)
        ).take(5).toList();

      case UserLevel.expert:
        return unlearned.take(3).toList();
    }
  }

  String getMotivationalMessage() {
    if (_currentUser == null) return 'เริ่มเรียนรู้ Linux กันเถอะ!';

    final streak = _currentUser!.streakDays;
    final commands = _currentUser!.learnedCommands.length;

    if (streak >= 7) {
      return 'สุดยอด! คุณเรียนติดต่อกันมา $streak วันแล้ว! 🔥';
    } else if (commands >= 20) {
      return 'ยอดเยี่ยม! คุณรู้คำสั่ง Linux แล้ว $commands คำสั่ง! 🌟';
    } else if (streak >= 3) {
      return 'เก่งมาก! รักษาความต่อเนื่องในการเรียนรู้ไว้นะ! 💪';
    } else if (commands >= 5) {
      return 'ดีใจด้วย! คุณก้าวหน้าไปมากแล้ว! 🎉';
    } else {
      return 'มาเรียนรู้คำสั่ง Linux ใหม่ๆ กันเถอะ! 🚀';
    }
  }

  // Achievement helpers
  List<Achievement> getAchievementsByCategory() {
    if (_currentUser == null) return [];

    return _currentUser!.achievements;
  }

  bool hasAchievementType(String type) {
    if (_currentUser == null) return false;

    return _currentUser!.achievements.any((a) => a.id.contains(type));
  }

  Achievement? getLatestAchievement() {
    if (_currentUser?.achievements.isEmpty ?? true) return null;

    return _currentUser!.achievements.last;
  }
}