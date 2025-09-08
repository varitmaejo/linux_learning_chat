import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 2)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  UserLevel level;

  @HiveField(4)
  List<String> learnedCommands;

  @HiveField(5)
  Map<String, int> commandUsage;

  @HiveField(6)
  int totalInteractions;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime lastActiveAt;

  @HiveField(9)
  Map<String, dynamic> preferences;

  @HiveField(10)
  List<Achievement> achievements;

  @HiveField(11)
  StudyStats studyStats;

  @HiveField(12)
  List<String> favoriteCommands;

  @HiveField(13)
  Map<String, DateTime> categoryProgress;

  @HiveField(14)
  int streakDays;

  @HiveField(15)
  DateTime? lastStudyDate;

  @HiveField(16)
  StudyGoal? currentGoal;

  @HiveField(17)
  List<QuizResult> quizHistory;

  @HiveField(18)
  String? avatarUrl;

  @HiveField(19)
  String university;

  @HiveField(20)
  String faculty;

  UserProfile({
    required this.id,
    this.name = 'นักศึกษา',
    this.email = '',
    this.level = UserLevel.beginner,
    List<String>? learnedCommands,
    Map<String, int>? commandUsage,
    this.totalInteractions = 0,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    Map<String, dynamic>? preferences,
    List<Achievement>? achievements,
    StudyStats? studyStats,
    List<String>? favoriteCommands,
    Map<String, DateTime>? categoryProgress,
    this.streakDays = 0,
    this.lastStudyDate,
    this.currentGoal,
    List<QuizResult>? quizHistory,
    this.avatarUrl,
    this.university = '',
    this.faculty = '',
  }) :
        learnedCommands = learnedCommands ?? [],
        commandUsage = commandUsage ?? {},
        createdAt = createdAt ?? DateTime.now(),
        lastActiveAt = lastActiveAt ?? DateTime.now(),
        preferences = preferences ?? _defaultPreferences(),
        achievements = achievements ?? [],
        studyStats = studyStats ?? StudyStats(),
        favoriteCommands = favoriteCommands ?? [],
        categoryProgress = categoryProgress ?? {},
        quizHistory = quizHistory ?? [];

  static Map<String, dynamic> _defaultPreferences() {
    return {
      'darkMode': false,
      'notifications': true,
      'soundEnabled': true,
      'animationsEnabled': true,
      'autoSave': true,
      'defaultCategory': 'all',
      'studyReminder': true,
      'dailyGoal': 5,
    };
  }

  // Helper methods
  double get progressPercentage {
    const totalCommands = 50; // จำนวนคำสั่งทั้งหมดที่มีในระบบ
    return (learnedCommands.length / totalCommands * 100).clamp(0, 100);
  }

  int get experiencePoints {
    return totalInteractions * 10 +
        learnedCommands.length * 50 +
        achievements.length * 100 +
        quizHistory.where((q) => q.passed).length * 75;
  }

  UserLevel get calculatedLevel {
    final commandCount = learnedCommands.length;
    final exp = experiencePoints;

    if (commandCount >= 30 || exp >= 2000) {
      return UserLevel.expert;
    } else if (commandCount >= 20 || exp >= 1200) {
      return UserLevel.advanced;
    } else if (commandCount >= 10 || exp >= 600) {
      return UserLevel.intermediate;
    } else {
      return UserLevel.beginner;
    }
  }

  bool get isOnStreak {
    if (lastStudyDate == null) return false;
    final now = DateTime.now();
    final lastStudy = DateTime(lastStudyDate!.year, lastStudyDate!.month, lastStudyDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(lastStudy).inDays <= 1;
  }

  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastStudyDate == null) {
      streakDays = 1;
      lastStudyDate = today;
      return;
    }

    final lastStudy = DateTime(lastStudyDate!.year, lastStudyDate!.month, lastStudyDate!.day);
    final daysDiff = today.difference(lastStudy).inDays;

    if (daysDiff == 1) {
      // ติดต่อกัน
      streakDays++;
    } else if (daysDiff == 0) {
      // วันเดียวกัน - ไม่เปลี่ยนแปลง
      return;
    } else {
      // ขาด - เริ่มใหม่
      streakDays = 1;
    }

    lastStudyDate = today;
  }

  void addLearnedCommand(String command) {
    if (!learnedCommands.contains(command)) {
      learnedCommands.add(command);
      commandUsage[command] = (commandUsage[command] ?? 0) + 1;
      updateStreak();
      _checkAchievements();
    }
  }

  void incrementCommandUsage(String command) {
    commandUsage[command] = (commandUsage[command] ?? 0) + 1;
    totalInteractions++;
    lastActiveAt = DateTime.now();
  }

  void addQuizResult(QuizResult result) {
    quizHistory.add(result);
    studyStats.totalQuizzes++;
    if (result.passed) {
      studyStats.passedQuizzes++;
    }
    _checkAchievements();
  }

  void _checkAchievements() {
    // ตรวจสอบ achievement ต่างๆ
    _checkFirstCommandAchievement();
    _checkStreakAchievements();
    _checkCommandCountAchievements();
    _checkQuizAchievements();
  }

  void _checkFirstCommandAchievement() {
    if (learnedCommands.isNotEmpty && !hasAchievement('first_command')) {
      achievements.add(Achievement(
        id: 'first_command',
        title: 'คำสั่งแรก',
        description: 'เรียนรู้คำสั่ง Linux คำสั่งแรก',
        icon: '🎯',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  void _checkStreakAchievements() {
    if (streakDays >= 7 && !hasAchievement('week_streak')) {
      achievements.add(Achievement(
        id: 'week_streak',
        title: 'นักเรียนขยัน',
        description: 'เรียนติดต่อกัน 7 วัน',
        icon: '🔥',
        unlockedAt: DateTime.now(),
      ));
    }

    if (streakDays >= 30 && !hasAchievement('month_streak')) {
      achievements.add(Achievement(
        id: 'month_streak',
        title: 'ผู้อุทิศตน',
        description: 'เรียนติดต่อกัน 30 วัน',
        icon: '👑',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  void _checkCommandCountAchievements() {
    final commandCount = learnedCommands.length;

    if (commandCount >= 10 && !hasAchievement('ten_commands')) {
      achievements.add(Achievement(
        id: 'ten_commands',
        title: 'ผู้เชี่ยวชาญใหม่',
        description: 'เรียนรู้คำสั่ง 10 คำสั่ง',
        icon: '⭐',
        unlockedAt: DateTime.now(),
      ));
    }

    if (commandCount >= 25 && !hasAchievement('master_commands')) {
      achievements.add(Achievement(
        id: 'master_commands',
        title: 'ปรมาจารย์ Linux',
        description: 'เรียนรู้คำสั่ง 25 คำสั่ง',
        icon: '🏆',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  void _checkQuizAchievements() {
    final passedQuizzes = quizHistory.where((q) => q.passed).length;

    if (passedQuizzes >= 5 && !hasAchievement('quiz_master')) {
      achievements.add(Achievement(
        id: 'quiz_master',
        title: 'นักสอบเก่ง',
        description: 'ผ่านแบบทดสอบ 5 ครั้ง',
        icon: '📝',
        unlockedAt: DateTime.now(),
      ));
    }
  }

  bool hasAchievement(String achievementId) {
    return achievements.any((a) => a.id == achievementId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'level': level.index,
      'learnedCommands': learnedCommands,
      'commandUsage': commandUsage,
      'totalInteractions': totalInteractions,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'preferences': preferences,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'studyStats': studyStats.toJson(),
      'favoriteCommands': favoriteCommands,
      'categoryProgress': categoryProgress.map((k, v) => MapEntry(k, v.toIso8601String())),
      'streakDays': streakDays,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'currentGoal': currentGoal?.toJson(),
      'quizHistory': quizHistory.map((q) => q.toJson()).toList(),
      'avatarUrl': avatarUrl,
      'university': university,
      'faculty': faculty,
    };
  }
}

@HiveType(typeId: 3)
enum UserLevel {
  @HiveField(0)
  beginner,
  @HiveField(1)
  intermediate,
  @HiveField(2)
  advanced,
  @HiveField(3)
  expert,
}

extension UserLevelExtension on UserLevel {
  String get displayName {
    switch (this) {
      case UserLevel.beginner:
        return 'ผู้เริ่มต้น';
      case UserLevel.intermediate:
        return 'ระดับกลาง';
      case UserLevel.advanced:
        return 'ระดับสูง';
      case UserLevel.expert:
        return 'ผู้เชี่ยวชาญ';
    }
  }

  String get emoji {
    switch (this) {
      case UserLevel.beginner:
        return '🌱';
      case UserLevel.intermediate:
        return '🌿';
      case UserLevel.advanced:
        return '🌳';
      case UserLevel.expert:
        return '🏆';
    }
  }

  Color get color {
    switch (this) {
      case UserLevel.beginner:
        return const Color(0xFF4CAF50);
      case UserLevel.intermediate:
        return const Color(0xFFFF9800);
      case UserLevel.advanced:
        return const Color(0xFFE91E63);
      case UserLevel.expert:
        return const Color(0xFF9C27B0);
    }
  }
}

@HiveType(typeId: 4)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String icon;

  @HiveField(4)
  DateTime unlockedAt;

  @HiveField(5)
  int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    this.points = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlockedAt': unlockedAt.toIso8601String(),
      'points': points,
    };
  }
}

@HiveType(typeId: 5)
class StudyStats extends HiveObject {
  @HiveField(0)
  int totalStudyTime; // ในนาที

  @HiveField(1)
  int totalQuizzes;

  @HiveField(2)
  int passedQuizzes;

  @HiveField(3)
  Map<String, int> categoryTime;

  @HiveField(4)
  DateTime? lastStudySession;

  @HiveField(5)
  int longestStreak;

  StudyStats({
    this.totalStudyTime = 0,
    this.totalQuizzes = 0,
    this.passedQuizzes = 0,
    Map<String, int>? categoryTime,
    this.lastStudySession,
    this.longestStreak = 0,
  }) : categoryTime = categoryTime ?? {};

  double get quizPassRate {
    if (totalQuizzes == 0) return 0.0;
    return passedQuizzes / totalQuizzes * 100;
  }

  String get totalStudyTimeFormatted {
    final hours = totalStudyTime ~/ 60;
    final minutes = totalStudyTime % 60;
    return '${hours}h ${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudyTime': totalStudyTime,
      'totalQuizzes': totalQuizzes,
      'passedQuizzes': passedQuizzes,
      'categoryTime': categoryTime,
      'lastStudySession': lastStudySession?.toIso8601String(),
      'longestStreak': longestStreak,
    };
  }
}

@HiveType(typeId: 6)
class StudyGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int targetValue;

  @HiveField(4)
  int currentValue;

  @HiveField(5)
  DateTime deadline;

  @HiveField(6)
  GoalType type;

  @HiveField(7)
  bool isCompleted;

  StudyGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.deadline,
    required this.type,
    this.isCompleted = false,
  });

  double get progress => currentValue / targetValue;
  bool get isOverdue => DateTime.now().isAfter(deadline) && !isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'deadline': deadline.toIso8601String(),
      'type': type.index,
      'isCompleted': isCompleted,
    };
  }
}

@HiveType(typeId: 7)
enum GoalType {
  @HiveField(0)
  commandsLearned,
  @HiveField(1)
  quizzesPassed,
  @HiveField(2)
  studyTime,
  @HiveField(3)
  streakDays,
}

@HiveType(typeId: 8)
class QuizResult extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String quizId;

  @HiveField(2)
  String title;

  @HiveField(3)
  int score;

  @HiveField(4)
  int totalQuestions;

  @HiveField(5)
  DateTime completedAt;

  @HiveField(6)
  int timeSpent; // ในวินาที

  @HiveField(7)
  String difficulty;

  @HiveField(8)
  List<String> incorrectAnswers;

  QuizResult({
    required this.id,
    required this.quizId,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    required this.timeSpent,
    required this.difficulty,
    List<String>? incorrectAnswers,
  }) : incorrectAnswers = incorrectAnswers ?? [];

  double get percentage => (score / totalQuestions) * 100;
  bool get passed => percentage >= 60; // ผ่าน 60%

  String get grade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quizId': quizId,
      'title': title,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
      'timeSpent': timeSpent,
      'difficulty': difficulty,
      'incorrectAnswers': incorrectAnswers,
    };
  }
}