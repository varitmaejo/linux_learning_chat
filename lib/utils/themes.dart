import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      fontFamily: 'Kanit',
      scaffoldBackgroundColor: AppColors.backgroundLight,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Kanit',
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.1), // ใช้ Color แทน .withOpacity()
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kanit',
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 16,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          fontFamily: 'Kanit',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          fontFamily: 'Kanit',
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Kanit',
      scaffoldBackgroundColor: AppColors.backgroundDark,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Kanit',
        ),
      ),

      cardTheme: const CardThemeData(
        elevation: 4,
        shadowColor: Color.fromRGBO(0, 0, 0, 0.1), // ใช้ Color แทน .withOpacity()
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Kanit',
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 16,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color secondaryBlue = Color(0xFF64B5F6);
  static const Color accentBlue = Color(0xFF1976D2);

  // Success & Error Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color infoBlue = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Message Colors
  static const Color userMessageBg = Color(0xFF2196F3);
  static const Color botMessageBg = Color(0xFFF5F5F5);
  static const Color commandHighlight = Color(0xFFE3F2FD);
  static const Color codeBackground = Color(0xFF263238);

  // Input Colors
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color inputBorder = Color(0xFFE0E0E0);

  // Level Colors
  static const Color beginnerColor = Color(0xFF4CAF50);
  static const Color intermediateColor = Color(0xFFFF9800);
  static const Color advancedColor = Color(0xFFE91E63);
  static const Color expertColor = Color(0xFF9C27B0);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'file_management': Color(0xFF2196F3),
    'navigation': Color(0xFF4CAF50),
    'text_processing': Color(0xFFFF9800),
    'permissions': Color(0xFFE91E63),
    'system_admin': Color(0xFF9C27B0),
    'process_management': Color(0xFF607D8B),
    'networking': Color(0xFF795548),
    'archive': Color(0xFF00BCD4),
    'automation': Color(0xFFFF5722),
  };
}

class AppConstants {
  static const String appName = 'Linux Learning Assistant';
  static const String appVersion = '1.0.0';
  static const String defaultUserName = 'นักเรียน';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  static const Duration typingAnimation = Duration(milliseconds: 1500);

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Chat Configuration
  static const int maxMessageLength = 500;
  static const int messagesPerPage = 50;
  static const Duration autoSaveInterval = Duration(seconds: 30);

  // Learning Progress
  static const int beginnerThreshold = 5;
  static const int intermediateThreshold = 12;
  static const int advancedThreshold = 20;
  static const int expertThreshold = 30;

  // UI Constants
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double messageBubbleMaxWidth = 280.0;
  static const double avatarRadius = 20.0;

  // Default Messages
  static const String welcomeMessage = '''
🎓 ยินดีต้อนรับสู่ระบบเรียนรู้คำสั่ง Linux สำหรับนักศึกษา!

ผมเป็น AI Assistant ที่จะช่วยให้คุณเรียนรู้คำสั่ง Linux อย่างมีประสิทธิภาพ โดยปรับการสอนตามระดับความสามารถของคุณ

🚀 **คุณสามารถเริ่มต้นได้โดย:**
• ถามเกี่ยวกับคำสั่งที่สนใจ เช่น "ls คืออะไร"
• ขอแนะนำคำสั่งสำหรับมือใหม่
• ทดสอบความรู้ของคุณ

พิมพ์ "help" หรือ "ช่วยเหลือ" เพื่อดูคำแนะนำเพิ่มเติม!
''';

  static const String helpMessage = '''
📚 **คำแนะนำการใช้งาน**

**วิธีการถามคำถาม:**
• `ls คืออะไร` - เรียนรู้คำสั่งเฉพาะ
• `แนะนำคำสั่งพื้นฐาน` - รับคำแนะนำตามระดับ
• `วิธีจัดการไฟล์` - เรียนรู้ตามหมวดหมู่
• `ทดสอบความรู้` - ประเมินความเข้าใจ

**ฟีเจอร์พิเศษ:**
🎯 ระบบปรับการเรียนรู้ตามบุคคล
📊 ติดตามความก้าวหน้า
💡 เคล็ดลับและตัวอย่างใช้งานจริง
⚡ ฝึกฝนด้วยแบบทดสอบ

**คำสั่งพิเศษ:**
• `สถิติ` - ดูความก้าวหน้าของคุณ
• `รีเซ็ต` - เริ่มต้นใหม่
• `ออกแบบทดสอบ` - สร้างข้อสอบ
''';
}