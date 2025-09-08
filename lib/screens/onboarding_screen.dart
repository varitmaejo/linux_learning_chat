import 'package:flutter/material.dart';
import '../utils/themes.dart';
import '../services/storage_service.dart';
import '../models/user_profile.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  UserLevel _selectedLevel = UserLevel.beginner;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'ยินดีต้อนรับสู่\nLinux Learning Assistant',
      description: 'ระบบเรียนรู้คำสั่ง Linux ที่ปรับเปลี่ยนตามระดับความสามารถของคุณ เพื่อการเรียนรู้ที่มีประสิทธิภาพสูงสุด',
      icon: Icons.terminal,
      color: AppColors.primaryBlue,
    ),
    OnboardingPage(
      title: 'เรียนรู้แบบ\nเฉพาะบุคคล',
      description: 'ระบบจะติดตามความก้าวหน้าและแนะนำคำสั่งที่เหมาะกับระดับของคุณ พร้อมระบบรางวัลและความสำเร็จ',
      icon: Icons.psychology,
      color: AppColors.successGreen,
    ),
    OnboardingPage(
      title: 'ฝึกฝนและ\nทดสอบความรู้',
      description: 'แบบทดสอบอัจฉริยะ ตัวอย่างการใช้งานจริง และเคล็ดลับจากผู้เชี่ยวชาญ เพื่อเสริมสร้างทักษะอย่างแข็งแกร่ง',
      icon: Icons.quiz,
      color: AppColors.warningOrange,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('กรุณากรอกชื่อของคุณ');
      return;
    }

    try {
      // Create user profile
      final profile = UserProfile(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        level: _selectedLevel,
        university: _universityController.text.trim(),
        faculty: _facultyController.text.trim(),
      );

      // Save profile
      await StorageService.saveUserProfile(profile);
      await StorageService.setFirstTimeUser(false);

      if (!mounted) return;

      // Navigate to main screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      _showSnackBar('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundLight, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length + 1, // +1 for profile setup page
                  itemBuilder: (context, index) {
                    if (index < _pages.length) {
                      return _buildOnboardingPage(_pages[index]);
                    } else {
                      return _buildProfileSetupPage();
                    }
                  },
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.md),
      child: Row(
        children: List.generate(
          _pages.length + 1,
              (index) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(
                right: index < _pages.length ? AppConstants.sm : 0,
              ),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? AppColors.primaryBlue
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),

          const SizedBox(height: AppConstants.xl),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.lg),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSetupPage() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConstants.lg),

            // Title
            Text(
              'ตั้งค่าโปรไฟล์',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppConstants.sm),

            Text(
              'กรอกข้อมูลเพื่อปรับแต่งการเรียนรู้ให้เหมาะกับคุณ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppConstants.xl),

            // Name field
            _buildTextField(
              controller: _nameController,
              label: 'ชื่อของคุณ *',
              hint: 'เช่น สมชาย ใจดี',
              icon: Icons.person,
            ),

            const SizedBox(height: AppConstants.lg),

            // University field
            _buildTextField(
              controller: _universityController,
              label: 'มหาวิทยาลัย',
              hint: 'เช่น มหาวิทยาลัยเชียงใหม่',
              icon: Icons.school,
            ),

            const SizedBox(height: AppConstants.lg),

            // Faculty field
            _buildTextField(
              controller: _facultyController,
              label: 'คณะ/สาขา',
              hint: 'เช่น วิทยาการคอมพิวเตอร์',
              icon: Icons.book,
            ),

            const SizedBox(height: AppConstants.lg),

            // Level selection
            Text(
              'ระดับความรู้ Linux ของคุณ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppConstants.md),

            ...UserLevel.values.map((level) => _buildLevelOption(level)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.sm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelOption(UserLevel level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.sm),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLevel = level;
          });
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            color: _selectedLevel == level
                ? AppColors.primaryBlue.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: _selectedLevel == level
                  ? AppColors.primaryBlue
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedLevel == level
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  border: Border.all(
                    color: _selectedLevel == level
                        ? AppColors.primaryBlue
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _selectedLevel == level
                    ? const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                )
                    : null,
              ),
              const SizedBox(width: AppConstants.md),
              Text(
                level.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppConstants.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getLevelDescription(level),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLevelDescription(UserLevel level) {
    switch (level) {
      case UserLevel.beginner:
        return 'ไม่เคยใช้ Linux หรือใช้น้อยมาก';
      case UserLevel.intermediate:
        return 'ใช้คำสั่งพื้นฐานได้บ้าง เช่น ls, cd, mkdir';
      case UserLevel.advanced:
        return 'ใช้คำสั่งขั้นกลางได้ เช่น grep, find, chmod';
      case UserLevel.expert:
        return 'ใช้คำสั่งขั้นสูงได้ scripting และ system admin';
    }
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Row(
        children: [
          // Back button
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppConstants.md),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: const Text(
                  'ย้อนกลับ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_currentPage > 0) const SizedBox(width: AppConstants.md),

          // Next/Complete button
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _currentPage < _pages.length ? _nextPage : _completeOnboarding,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppConstants.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              child: Text(
                _currentPage < _pages.length ? 'ถัดไป' : 'เริ่มใช้งาน',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}