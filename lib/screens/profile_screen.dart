import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/themes.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../models/user_profile.dart';
import '../widgets/achievement_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/progress_chart.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Mark achievements as viewed when profile screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().markAchievementAsViewed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(userProvider),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(userProvider),
                _buildStatsTab(userProvider),
                _buildAchievementsTab(userProvider),
                _buildSettingsTab(),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(UserProvider userProvider) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppConstants.xl),
                  _buildProfileHeader(userProvider),
                  const SizedBox(height: AppConstants.lg),
                  _buildQuickStats(userProvider),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        tabs: const [
          Tab(text: 'ภาพรวม'),
          Tab(text: 'สถิติ'),
          Tab(text: 'รางวัล'),
          Tab(text: 'ตั้งค่า'),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProvider userProvider) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Text(
              userProvider.userName.isNotEmpty
                  ? userProvider.userName[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppConstants.md),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userProvider.userName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppConstants.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.sm,
                  vertical: AppConstants.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userProvider.userLevel.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: AppConstants.xs),
                    Text(
                      userProvider.userLevel.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (userProvider.currentUser?.university.isNotEmpty ?? false) ...[
                const SizedBox(height: AppConstants.xs),
                Text(
                  userProvider.currentUser!.university,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Edit button
        IconButton(
          onPressed: () => _showEditProfileDialog(),
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(UserProvider userProvider) {
    return Row(
      children: [
    Expanded(
    child: _buildStatItem(
    '${userProvider.learnedCommandsCount}',
      'คำสั่งที่รู้',
      Icons.terminal,
    ),
    ),
    Expanded(
    child: _buildStatItem(
    '${userProvider.streakDays}',
    'วันติดต่อกัน',
    Icons.local_fire_department,
    ),
    ),
    Expanded(
    child: _buildStatItem(
    '${userProvider.experiencePoints}',
    'คะแนน XP',
    Icons.star,
    ),
    ),
    Expanded(
    child: _buildStatItem(
    '${userProvider.achievements.length}',
    'รางว