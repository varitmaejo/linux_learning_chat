import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/themes.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/input_area.dart';
import '../widgets/quick_actions.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showQuickActions = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    // Start study session when chat screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().startStudySession();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // End study session when leaving chat
    context.read<UserProvider>().endStudySession();
    super.dispose();
  }

  void _handleMessageSent() {
    setState(() {
      _showQuickActions = false;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('คัดลอกแล้ว!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                message.isStarred ? Icons.star : Icons.star_border,
                color: AppColors.warningOrange,
              ),
              title: Text(message.isStarred ? 'ยกเลิกดาว' : 'ใส่ดาว'),
              onTap: () {
                context.read<ChatProvider>().toggleMessageStar(message.id);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.primaryBlue),
              title: const Text('คัดลอก'),
              onTap: () {
                _copyToClipboard(message.text);
                Navigator.pop(context);
              },
            ),
            if (!message.isUser)
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.successGreen),
                title: const Text('แชร์'),
                onTap: () {
                  // Implement share functionality
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.errorRed),
              title: const Text('ลบ'),
              onTap: () {
                context.read<ChatProvider>().deleteMessage(message.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!chatProvider.hasMessages) {
                  return _buildEmptyState();
                }

                return _buildMessagesList(chatProvider);
              },
            ),
          ),

          // Quick actions (show when no messages or minimal interaction)
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (_showQuickActions && chatProvider.userMessages < 3) {
                return QuickActionsWidget(
                  onActionSelected: (action) {
                    chatProvider.sendQuickMessage(action);
                    _handleMessageSent();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Typing indicator
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.isTyping) {
                return const TypingIndicator();
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area
          InputArea(
            onMessageSent: (message) {
              context.read<ChatProvider>().sendMessage(message);
              _handleMessageSent();
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Linux Assistant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (userProvider.isInStudySession)
                Text(
                  'เรียนมาแล้ว ${_formatDuration(userProvider.getCurrentSessionDuration())}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        // User level indicator
        Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Container(
              margin: const EdgeInsets.only(right: AppConstants.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.sm,
                vertical: AppConstants.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
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
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Menu button
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('ล้างการสนทนา'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'starred',
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('ข้อความที่ติดดาว'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('ส่งออกการสนทนา'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help),
                title: Text('ช่วยเหลือ'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppConstants.lg),
            Text(
              'เริ่มการสนทนา',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.sm),
            Text(
              'ถามคำถามเกี่ยวกับคำสั่ง Linux\nหรือขอแนะนำการเรียนรู้',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider) {
    return ListView.builder(
      controller: chatProvider.scrollController,
      padding: const EdgeInsets.all(AppConstants.md),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return MessageBubble(
          message: message,
          onLongPress: () => _showMessageOptions(message),
          onCopy: () => _copyToClipboard(message.text),
          animation: _animationController,
        );
      },
    );
  }

  void _handleMenuAction(String action) {
    final chatProvider = context.read<ChatProvider>();

    switch (action) {
      case 'clear':
        _showClearConfirmation();
        break;
      case 'starred':
        _showStarredMessages();
        break;
      case 'export':
        _exportChat();
        break;
      case 'help':
        chatProvider.requestHelp();
        break;
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างการสนทนา'),
        content: const Text('คุณต้องการล้างประวัติการสนทนาทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatProvider>().clearAllMessages();
              Navigator.pop(context);
            },
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
  }

  void _showStarredMessages() {
    final starredMessages = context.read<ChatProvider>().getStarredMessages();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(AppConstants.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ข้อความที่ติดดาว',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppConstants.md),
            Expanded(
              child: starredMessages.isEmpty
                  ? const Center(
                child: Text('ไม่มีข้อความที่ติดดาว'),
              )
                  : ListView.builder(
                itemCount: starredMessages.length,
                itemBuilder: (context, index) {
                  final message = starredMessages[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        message.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(message.displayTime),
                      trailing: IconButton(
                        icon: const Icon(Icons.star, color: AppColors.warningOrange),
                        onPressed: () {
                          context.read<ChatProvider>().toggleMessageStar(message.id);
                          Navigator.pop(context);
                        },
                      ),
                      onTap: () {
                        _copyToClipboard(message.text);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportChat() async {
    try {
      final chatData = await context.read<ChatProvider>().exportChatHistory();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ส่งออกการสนทนาสำเร็จ'),
          backgroundColor: AppColors.successGreen,
        ),
      );

      // In a real app, you would save or share the file
      print('Chat exported: ${chatData['totalMessages']} messages');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการส่งออก'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0 นาที';

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes นาที';
    } else {
      return '$seconds วินาที';
    }
  }
}