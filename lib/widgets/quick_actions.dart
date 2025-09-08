import 'package:flutter/material.dart';
import '../utils/themes.dart';

class QuickActionsWidget extends StatefulWidget {
  final Function(String) onActionSelected;

  const QuickActionsWidget({
    Key? key,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  State<QuickActionsWidget> createState() => _QuickActionsWidgetState();
}

class _QuickActionsWidgetState extends State<QuickActionsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<QuickAction> _actions = [
    QuickAction(
      title: 'เริ่มต้น',
      subtitle: 'คำสั่งพื้นฐาน',
      icon: Icons.play_arrow,
      color: AppColors.successGreen,
      action: 'แนะนำคำสั่งพื้นฐาน',
    ),
    QuickAction(
      title: 'จัดการไฟล์',
      subtitle: 'ls, cp, mv, rm',
      icon: Icons.folder,
      color: AppColors.primaryBlue,
      action: 'วิธีจัดการไฟล์',
    ),
    QuickAction(
      title: 'ค้นหา',
      subtitle: 'grep, find',
      icon: Icons.search,
      color: AppColors.warningOrange,
      action: 'วิธีค้นหาไฟล์',
    ),
    QuickAction(
      title: 'ทดสอบ',
      subtitle: 'แบบทดสอบ',
      icon: Icons.quiz,
      color: AppColors.infoBlue,
      action: 'ทดสอบความรู้',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppConstants.xs),
                      Text(
                        'เริ่มต้นด้วยคำถามเหล่านี้',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.md),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: AppConstants.sm,
                      mainAxisSpacing: AppConstants.sm,
                    ),
                    itemCount: _actions.length,
                    itemBuilder: (context, index) {
                      return _buildActionCard(_actions[index], index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(QuickAction action, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: () => widget.onActionSelected(action.action),
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.sm),
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(
                  color: action.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: action.color,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Icon(
                      action.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          action.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: action.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          action.subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String action;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
  });
}