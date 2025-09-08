import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../utils/themes.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final VoidCallback? onLongPress;
  final VoidCallback? onCopy;
  final AnimationController? animation;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onLongPress,
    this.onCopy,
    this.animation,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.message.isUser
          ? const Offset(1.0, 0.0)
          : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutBack,
    ));

    // Start animation
    _bubbleController.forward();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.xs,
            horizontal: AppConstants.sm,
          ),
          child: Row(
            mainAxisAlignment: widget.message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.message.isUser) ...[
                _buildAvatar(),
                const SizedBox(width: AppConstants.sm),
              ],

              Flexible(
                child: GestureDetector(
                  onLongPress: widget.onLongPress,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.messageBubbleMaxWidth,
                    ),
                    padding: const EdgeInsets.all(AppConstants.md),
                    decoration: _buildBubbleDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message type indicator
                        if (widget.message.type != MessageType.text)
                          _buildTypeIndicator(),

                        // Message content
                        _buildMessageContent(),

                        // Message footer
                        _buildMessageFooter(),
                      ],
                    ),
                  ),
                ),
              ),

              if (widget.message.isUser) ...[
                const SizedBox(width: AppConstants.sm),
                _buildAvatar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: AppConstants.avatarRadius * 2,
      height: AppConstants.avatarRadius * 2,
      decoration: BoxDecoration(
        color: widget.message.isUser
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: widget.message.isUser
              ? AppColors.successGreen
              : AppColors.primaryBlue,
          width: 2,
        ),
      ),
      child: Icon(
        widget.message.isUser ? Icons.person : Icons.smart_toy,
        size: 16,
        color: widget.message.isUser
            ? AppColors.successGreen
            : AppColors.primaryBlue,
      ),
    );
  }

  BoxDecoration _buildBubbleDecoration() {
    Color backgroundColor;
    Color borderColor;

    if (widget.message.isUser) {
      backgroundColor = AppColors.userMessageBg;
      borderColor = AppColors.userMessageBg;
    } else {
      switch (widget.message.type) {
        case MessageType.success:
          backgroundColor = AppColors.successGreen.withOpacity(0.1);
          borderColor = AppColors.successGreen;
          break;
        case MessageType.warning:
          backgroundColor = AppColors.warningOrange.withOpacity(0.1);
          borderColor = AppColors.warningOrange;
          break;
        case MessageType.error:
          backgroundColor = AppColors.errorRed.withOpacity(0.1);
          borderColor = AppColors.errorRed;
          break;
        case MessageType.command:
          backgroundColor = AppColors.commandHighlight;
          borderColor = AppColors.primaryBlue;
          break;
        case MessageType.quiz:
          backgroundColor = AppColors.infoBlue.withOpacity(0.1);
          borderColor = AppColors.infoBlue;
          break;
        default:
          backgroundColor = AppColors.botMessageBg;
          borderColor = Colors.grey.shade300;
      }
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(AppConstants.radiusLarge),
        topRight: const Radius.circular(AppConstants.radiusLarge),
        bottomLeft: Radius.circular(
          widget.message.isUser ? AppConstants.radiusLarge : AppConstants.radiusSmall,
        ),
        bottomRight: Radius.circular(
          widget.message.isUser ? AppConstants.radiusSmall : AppConstants.radiusLarge,
        ),
      ),
      border: Border.all(color: borderColor.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildTypeIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.sm,
        vertical: AppConstants.xs,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message.type.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: AppConstants.xs),
          Text(
            widget.message.type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getTypeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.message.type) {
      case MessageType.success:
        return AppColors.successGreen;
      case MessageType.warning:
        return AppColors.warningOrange;
      case MessageType.error:
        return AppColors.errorRed;
      case MessageType.command:
        return AppColors.primaryBlue;
      case MessageType.quiz:
        return AppColors.infoBlue;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildMessageContent() {
    String text = widget.message.text;

    // Check if message contains code blocks
    if (text.contains('```') || text.contains('`')) {
      return _buildFormattedText(text);
    }

    // Regular text
    return SelectableText(
      text,
      style: TextStyle(
        fontSize: 14,
        color: widget.message.isUser
            ? Colors.white
            : AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final parts = <Widget>[];
    final codeBlockRegex = RegExp(r'```(.*?)```', dotAll: true);
    final inlineCodeRegex = RegExp(r'`([^`]+)`');

    int lastIndex = 0;

    // Handle code blocks
    for (final match in codeBlockRegex.allMatches(text)) {
      // Add text before code block
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        parts.add(_buildRegularText(beforeText));
      }

      // Add code block
      parts.add(_buildCodeBlock(match.group(1) ?? ''));
      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      parts.add(_buildRegularText(remainingText));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }

  Widget _buildRegularText(String text) {
    // Handle inline code
    final inlineCodeRegex = RegExp(r'`([^`]+)`');
    final spans = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in inlineCodeRegex.allMatches(text)) {
      // Add text before inline code
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        spans.addAll(_parseMarkdownText(beforeText));
      }

      // Add inline code
      spans.add(WidgetSpan(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.codeBackground.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            match.group(1) ?? '',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ));
      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      spans.addAll(_parseMarkdownText(remainingText));
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: 14,
          color: widget.message.isUser
              ? Colors.white
              : AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  List<InlineSpan> _parseMarkdownText(String text) {
    final spans = <InlineSpan>[];

    // Handle bold text **text**
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldRegex.allMatches(text)) {
      // Add text before bold
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.message.isUser
              ? Colors.white
              : AppColors.primaryBlue,
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }

    // If no bold text found, return original text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppConstants.sm),
      padding: const EdgeInsets.all(AppConstants.md),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.codeBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Stack(
        children: [
          SelectableText(
            code.trim(),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.copy,
                size: 16,
                color: Colors.white70,
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code.trim()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('คัดลอกโค้ดแล้ว!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timestamp
          Text(
            widget.message.displayTime,
            style: TextStyle(
              fontSize: 11,
              color: widget.message.isUser
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.textSecondary,
            ),
          ),

          // Star indicator
          if (widget.message.isStarred) ...[
            const SizedBox(width: AppConstants.xs),
            Icon(
              Icons.star,
              size: 12,
              color: widget.message.isUser
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.warningOrange,
            ),
          ],

          // Command indicator
          if (widget.message.hasCommand) ...[
            const SizedBox(width: AppConstants.xs),
            Icon(
              Icons.code,
              size: 12,
              color: widget.message.isUser
                  ? Colors.white.withOpacity(0.7)
                  : AppColors.primaryBlue,
            ),
          ],

          const Spacer(),

          // Action buttons for bot messages
          if (!widget.message.isUser) ...[
            InkWell(
              onTap: widget.onCopy,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.xs),
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // Toggle star
                // This would be handled by the parent widget
              },
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.xs),
                child: Icon(
                  widget.message.isStarred ? Icons.star : Icons.star_border,
                  size: 14,
                  color: widget.message.isStarred
                      ? AppColors.warningOrange
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}