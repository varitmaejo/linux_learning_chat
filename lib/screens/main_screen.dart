import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/themes.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'quiz_screen.dart';
import 'command_reference_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>();
      context.read<UserProvider>().loadUserProfile();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          ChatScreen(),
          CommandReferenceScreen(),
          QuizScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.chat_bubble_outline, 0),
                activeIcon: _buildNavIcon(Icons.chat_bubble, 0),
                label: 'แชท',
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.book_outlined, 1),
                activeIcon: _buildNavIcon(Icons.book, 1),
                label: 'คำสั่ง',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    _buildNavIcon(Icons.quiz_outlined, 2),
                    if (userProvider.hasUncompletedQuiz)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: _buildNavIcon(Icons.quiz, 2),
                label: 'ทดสอบ',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    _buildNavIcon(Icons.person_outline, 3),
                    if (userProvider.hasNewAchievement)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.successGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                activeIcon: _buildNavIcon(Icons.person, 3),
                label: 'โปรไฟล์',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return Container(
      padding: const EdgeInsets.all(AppConstants.xs),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryBlue.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Icon(
        icon,
        size: 24,
        color: isSelected
            ? AppColors.primaryBlue
            : Colors.grey.shade600,
      ),
    );
  }
}