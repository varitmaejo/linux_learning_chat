import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/user_profile.dart';

class StorageService {
  static late Box<Message> _messageBox;
  static late Box<UserProfile> _userBox;
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters - ในการใช้งานจริงต้องสร้าง .g.dart files ด้วย build_runner
    // Hive.registerAdapter(MessageAdapter());
    // Hive.registerAdapter(MessageTypeAdapter());
    // Hive.registerAdapter(UserProfileAdapter());
    // Hive.registerAdapter(UserLevelAdapter());
    // Hive.registerAdapter(AchievementAdapter());
    // Hive.registerAdapter(StudyStatsAdapter());
    // Hive.registerAdapter(StudyGoalAdapter());
    // Hive.registerAdapter(GoalTypeAdapter());
    // Hive.registerAdapter(QuizResultAdapter());

    // Open boxes
    _messageBox = await Hive.openBox<Message>('messages');
    _userBox = await Hive.openBox<UserProfile>('users');

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }

  // Message operations
  static Future<void> saveMessage(Message message) async {
    try {
      await _messageBox.put(message.id, message);
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  static List<Message> getAllMessages() {
    try {
      final messages = _messageBox.values.toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  static Future<void> deleteMessage(String messageId) async {
    try {
      await _messageBox.delete(messageId);
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  static Future<void> clearAllMessages() async {
    try {
      await _messageBox.clear();
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }

  static List<Message> getStarredMessages() {
    try {
      return _messageBox.values.where((message) => message.isStarred).toList();
    } catch (e) {
      print('Error getting starred messages: $e');
      return [];
    }
  }

  static Future<void> toggleMessageStar(String messageId) async {
    try {
      final message = _messageBox.get(messageId);
      if (message != null) {
        final updatedMessage = message.copyWith(isStarred: !message.isStarred);
        await _messageBox.put(messageId, updatedMessage);
      }
    } catch (e) {
      print('Error toggling message star: $e');
    }
  }

  static List<Message> searchMessages(String query) {
    try {
      query = query.toLowerCase();
      return _messageBox.values.where((message) =>
      message.text.toLowerCase().contains(query) ||
          (message.command?.toLowerCase().contains(query) ?? false)
      ).toList();
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  static List<Message> getMessagesByType(MessageType type) {
    try {
      return _messageBox.values.where((message) => message.type == type).toList();
    } catch (e) {
      print('Error getting messages by type: $e');
      return [];
    }
  }

  static List<Message> getRecentMessages({int limit = 50}) {
    try {
      final messages = getAllMessages();
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return messages.take(limit).toList();
    } catch (e) {
      print('Error getting recent messages: $e');
      return [];
    }
  }

  // User Profile operations
  static Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _userBox.put(profile.id, profile);
      await _saveProfileToPrefs(profile);
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  static UserProfile? getUserProfile(String id) {
    try {
      return _userBox.get(id);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static UserProfile getOrCreateDefaultProfile() {
    const defaultId = 'default_user';
    try {
      UserProfile? profile = _userBox.get(defaultId);

      if (profile == null) {
        profile = UserProfile(id: defaultId);
        _userBox.put(defaultId, profile);
        _saveProfileToPrefs(profile);
      }

      return profile;
    } catch (e) {
      print('Error getting/creating default profile: $e');
      return UserProfile(id: defaultId);
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    try {
      profile.lastActiveAt = DateTime.now();
      await saveUserProfile(profile);
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  static Future<void> deleteUserProfile(String id) async {
    try {
      await _userBox.delete(id);
      await _removeProfileFromPrefs(id);
    } catch (e) {
      print('Error deleting user profile: $e');
    }
  }

  static List<UserProfile> getAllUserProfiles() {
    try {
      return _userBox.values.toList();
    } catch (e) {
      print('Error getting all user profiles: $e');
      return [];
    }
  }

  // SharedPreferences operations for app settings
  static Future<void> _saveProfileToPrefs(UserProfile profile) async {
    try {
      await _prefs.setString('current_user_id', profile.id);
      await _prefs.setString('user_name', profile.name);
      await _prefs.setString('user_level', profile.level.name);
      await _prefs.setInt('total_interactions', profile.totalInteractions);
      await _prefs.setStringList('learned_commands', profile.learnedCommands);
    } catch (e) {
      print('Error saving profile to prefs: $e');
    }
  }

  static Future<void> _removeProfileFromPrefs(String id) async {
    try {
      final currentId = _prefs.getString('current_user_id');
      if (currentId == id) {
        await _prefs.remove('current_user_id');
        await _prefs.remove('user_name');
        await _prefs.remove('user_level');
        await _prefs.remove('total_interactions');
        await _prefs.remove('learned_commands');
      }
    } catch (e) {
      print('Error removing profile from prefs: $e');
    }
  }

  // App Settings
  static Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString('theme_mode', themeMode);
  }

  static String getThemeMode() {
    return _prefs.getString('theme_mode') ?? 'system';
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool('sound_enabled', enabled);
  }

  static bool getSoundEnabled() {
    return _prefs.getBool('sound_enabled') ?? true;
  }

  static Future<void> setAnimationsEnabled(bool enabled) async {
    await _prefs.setBool('animations_enabled', enabled);
  }

  static bool getAnimationsEnabled() {
    return _prefs.getBool('animations_enabled') ?? true;
  }

  static Future<void> setAutoSaveEnabled(bool enabled) async {
    await _prefs.setBool('auto_save_enabled', enabled);
  }

  static bool getAutoSaveEnabled() {
    return _prefs.getBool('auto_save_enabled') ?? true;
  }

  static Future<void> setDailyGoal(int goal) async {
    await _prefs.setInt('daily_goal', goal);
  }

  static int getDailyGoal() {
    return _prefs.getInt('daily_goal') ?? 5;
  }

  static Future<void> setStudyReminderEnabled(bool enabled) async {
    await _prefs.setBool('study_reminder_enabled', enabled);
  }

  static bool getStudyReminderEnabled() {
    return _prefs.getBool('study_reminder_enabled') ?? true;
  }

  static Future<void> setFirstTimeUser(bool isFirstTime) async {
    await _prefs.setBool('first_time_user', isFirstTime);
  }

  static bool isFirstTimeUser() {
    return _prefs.getBool('first_time_user') ?? true;
  }

  static Future<void> setLastBackupDate(DateTime date) async {
    await _prefs.setString('last_backup_date', date.toIso8601String());
  }

  static DateTime? getLastBackupDate() {
    final dateString = _prefs.getString('last_backup_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Statistics and Analytics
  static Future<void> incrementAppOpenCount() async {
    final count = _prefs.getInt('app_open_count') ?? 0;
    await _prefs.setInt('app_open_count', count + 1);
  }

  static int getAppOpenCount() {
    return _prefs.getInt('app_open_count') ?? 0;
  }

  static Future<void> setTotalStudyTime(int minutes) async {
    await _prefs.setInt('total_study_time', minutes);
  }

  static int getTotalStudyTime() {
    return _prefs.getInt('total_study_time') ?? 0;
  }

  static Future<void> addStudySession(int durationMinutes) async {
    final currentTotal = getTotalStudyTime();
    await setTotalStudyTime(currentTotal + durationMinutes);

    // Update last study date
    await _prefs.setString('last_study_date', DateTime.now().toIso8601String());
  }

  static DateTime? getLastStudyDate() {
    final dateString = _prefs.getString('last_study_date');
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Export/Import functionality
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final profile = getUserProfile(userId);
      final userMessages = _messageBox.values
          .where((message) => message.id.startsWith(userId))
          .toList();

      return {
        'profile': profile?.toJson(),
        'messages': userMessages.map((m) => m.toJson()).toList(),
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  static Future<bool> importUserData(Map<String, dynamic> data) async {
    try {
      // Validate data structure
      if (!data.containsKey('profile') || !data.containsKey('messages')) {
        return false;
      }

      // Import profile
      final profileData = data['profile'] as Map<String, dynamic>?;
      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        await saveUserProfile(profile);
      }

      // Import messages
      final messagesData = data['messages'] as List<dynamic>?;
      if (messagesData != null) {
        for (final messageData in messagesData) {
          final message = Message.fromJson(messageData as Map<String, dynamic>);
          await saveMessage(message);
        }
      }

      return true;
    } catch (e) {
      print('Error importing user data: $e');
      return false;
    }
  }

  // Backup and Restore
  static Future<bool> createBackup() async {
    try {
      final allProfiles = getAllUserProfiles();
      final allMessages = getAllMessages();

      final backupData = {
        'profiles': allProfiles.map((p) => p.toJson()).toList(),
        'messages': allMessages.map((m) => m.toJson()).toList(),
        'settings': await _getAllSettings(),
        'backupDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

      // In a real app, you would save this to a file or upload to cloud
      await _prefs.setString('backup_data', backupData.toString());
      await setLastBackupDate(DateTime.now());

      return true;
    } catch (e) {
      print('Error creating backup: $e');
      return false;
    }
  }

  static Future<bool> restoreFromBackup(Map<String, dynamic> backupData) async {
    try {
      // Clear existing data
      await clearAllMessages();
      await _userBox.clear();

      // Restore profiles
      final profilesData = backupData['profiles'] as List<dynamic>?;
      if (profilesData != null) {
        for (final profileData in profilesData) {
          final profile = UserProfile.fromJson(profileData as Map<String, dynamic>);
          await saveUserProfile(profile);
        }
      }

      // Restore messages
      final messagesData = backupData['messages'] as List<dynamic>?;
      if (messagesData != null) {
        for (final messageData in messagesData) {
          final message = Message.fromJson(messageData as Map<String, dynamic>);
          await saveMessage(message);
        }
      }

      // Restore settings
      final settingsData = backupData['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        await _restoreSettings(settingsData);
      }

      return true;
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> _getAllSettings() async {
    return {
      'theme_mode': getThemeMode(),
      'notifications_enabled': getNotificationsEnabled(),
      'sound_enabled': getSoundEnabled(),
      'animations_enabled': getAnimationsEnabled(),
      'auto_save_enabled': getAutoSaveEnabled(),
      'daily_goal': getDailyGoal(),
      'study_reminder_enabled': getStudyReminderEnabled(),
      'total_study_time': getTotalStudyTime(),
      'app_open_count': getAppOpenCount(),
    };
  }

  static Future<void> _restoreSettings(Map<String, dynamic> settings) async {
    await setThemeMode(settings['theme_mode'] ?? 'system');
    await setNotificationsEnabled(settings['notifications_enabled'] ?? true);
    await setSoundEnabled(settings['sound_enabled'] ?? true);
    await setAnimationsEnabled(settings['animations_enabled'] ?? true);
    await setAutoSaveEnabled(settings['auto_save_enabled'] ?? true);
    await setDailyGoal(settings['daily_goal'] ?? 5);
    await setStudyReminderEnabled(settings['study_reminder_enabled'] ?? true);
    await setTotalStudyTime(settings['total_study_time'] ?? 0);
    await _prefs.setInt('app_open_count', settings['app_open_count'] ?? 0);
  }

  // Cleanup and maintenance
  static Future<void> cleanupOldData() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));

      // Remove old messages (older than 90 days)
      final messagesToDelete = <String>[];
      for (final message in _messageBox.values) {
        if (message.timestamp.isBefore(cutoffDate)) {
          messagesToDelete.add(message.id);
        }
      }

      for (final id in messagesToDelete) {
        await _messageBox.delete(id);
      }

      print('Cleaned up ${messagesToDelete.length} old messages');
    } catch (e) {
      print('Error during cleanup: $e');
    }
  }

  static Future<void> compactDatabase() async {
    try {
      await _messageBox.compact();
      await _userBox.compact();
      print('Database compacted successfully');
    } catch (e) {
      print('Error compacting database: $e');
    }
  }

  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      return {
        'total_messages': _messageBox.length,
        'total_users': _userBox.length,
        'starred_messages': getStarredMessages().length,
        'app_opens': getAppOpenCount(),
        'study_time_minutes': getTotalStudyTime(),
      };
    } catch (e) {
      print('Error getting database stats: $e');
      return {};
    }
  }

  // Close databases (call when app is terminated)
  static Future<void> close() async {
    try {
      await _messageBox.close();
      await _userBox.close();
      await Hive.close();
    } catch (e) {
      print('Error closing databases: $e');
    }
  }
}