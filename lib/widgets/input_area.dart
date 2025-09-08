import 'package:flutter/material.dart';
import '../utils/themes.dart';

class InputArea extends StatefulWidget {
  final Function(String) onMessageSent;
  final bool isEnabled;

  const InputArea({
    Key? key,
    required this.onMessageSent,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late AnimationController _suggestionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _suggestionAnimation;

  bool _isComposing = false;
  bool _showSuggestions = false;
  bool _isVoiceListening = false;

  final List<String> _quickSuggestions = [
    'ls คืออะไร',
    'แนะนำคำสั่งพื้นฐาน',
    'วิธีจัดการไฟล์',
    'ค้นหาไฟล์',
    'chmod ใช้อย่างไร',
    'ทดสอบความรู้',
    'สถิติของฉัน',
    'ช่วยเหลือ',
    'grep สำหรับค้นหา',
    'sudo คืออะไร',
    'tar บีบอัดไฟล์',
    'ps ดูกระบวนการ',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _suggestionController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _suggestionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeOutBack,
    ));

    _messageController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = _messageController.text.isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
        if (isComposing) {
          _showSuggestions = false;
          _suggestionController.reverse();
        }
      });

      if (isComposing) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        if (_focusNode.hasFocus) {
          _showSuggestions = true;
          _suggestionController.forward();
        }
      }
    }
  }

  void _onFocusChanged() {
    setState(() {
      if (_focusNode.hasFocus && _messageController.text.isEmpty) {
        _showSuggestions = true;
        _suggestionController.forward();
      } else {
        _showSuggestions = false;
        _suggestionController.reverse();
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty && widget.isEnabled) {
      final message = _messageController.text.trim();

      // Add haptic feedback
      _hapticFeedback();

      widget.onMessageSent(message);
      _messageController.clear();

      setState(() {
        _isComposing = false;
        _showSuggestions = false;
      });

      _animationController.reverse();
      _suggestionController.reverse();
      _focusNode.unfocus();
    }
  }

  void _onSuggestionTapped(String suggestion) {
    _messageController.text = suggestion;
    setState(() {
      _showSuggestions = false;
      _isComposing = true;
    });

    _animationController.forward();
    _suggestionController.reverse();
    _focusNode.unfocus();

    // Auto-send suggestion after short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_messageController.text == suggestion) {
        _sendMessage();
      }
    });
  }

  void _hapticFeedback() {
    // Add haptic feedback for better UX
    // HapticFeedback.lightImpact();
  }

  void _startVoiceInput() {
    setState(() {
      _isVoiceListening = true;
    });

    // Simulate voice input (in real app, integrate with speech_to_text package)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVoiceListening = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Text('ฟีเจอร์เสียงจะเปิดใช้งานในอนาคต'),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.infoBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
        ),
      );
    });
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: AppConstants.lg),

            Text(
              'ตัวเลือกเพิ่มเติม',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppConstants.md),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                ),
              ),
              title: const Text('ถ่ายภาพคำสั่ง'),
              subtitle: const Text('ส่งภาพหน้าจอเทอร์มินัล'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon('การถ่ายภาพ');
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: AppColors.successGreen,
                ),
              ),
              title: const Text('แนบไฟล์'),
              subtitle: const Text('ส่งไฟล์ log หรือ script'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon('การแนบไฟล์');
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.terminal,
                  color: AppColors.warningOrange,
                ),
              ),
              title: const Text('Terminal จำลอง'),
              subtitle: const Text('ทดลองคำสั่งในเทอร์มินัล'),
              onTap: () {
                Navigator.pop(context);
                _showFeatureComingSoon('Terminal จำลอง');
              },
            ),

            const SizedBox(height: AppConstants.lg),
          ],
        ),
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature จะเปิดใช้งานในเวอร์ชันถัดไป'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.infoBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Suggestions
            AnimatedBuilder(
              animation: _suggestionAnimation,
              builder: (context, child) {
                if (!_showSuggestions) return const SizedBox.shrink();

                return Transform.translate(
                  offset: Offset(0, (1 - _suggestionAnimation.value) * 50),
                  child: Opacity(
                    opacity: _suggestionAnimation.value,
                    child: _buildSuggestions(),
                  ),
                );
              },
            ),

            // Input area
            Padding(
              padding: const EdgeInsets.all(AppConstants.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Voice input button
                  AnimatedContainer(
                    duration: AppConstants.shortAnimation,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isVoiceListening
                          ? AppColors.errorRed.withOpacity(0.1)
                          : AppColors.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: AppConstants.shortAnimation,
                        child: Icon(
                          _isVoiceListening ? Icons.mic : Icons.mic_none,
                          key: ValueKey(_isVoiceListening),
                          color: _isVoiceListening
                              ? AppColors.errorRed
                              : AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      onPressed: widget.isEnabled ? _startVoiceInput : null,
                    ),
                  ),

                  const SizedBox(width: AppConstants.sm),

                  // Text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 44,
                        maxHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? AppColors.primaryBlue
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
                              enabled: widget.isEnabled,
                              decoration: InputDecoration(
                                hintText: 'ถามเกี่ยวกับคำสั่ง Linux...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.md,
                                  vertical: AppConstants.sm,
                                ),
                              ),
                              textInputAction: TextInputAction.newline,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                              maxLines: null,
                              minLines: 1,
                              maxLength: AppConstants.maxMessageLength,
                              buildCounter: (context, {currentLength, maxLength, isFocused}) {
                                if (currentLength! > maxLength! * 0.8) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: AppConstants.sm),
                                    child: Text(
                                      '$currentLength/$maxLength',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: currentLength > maxLength
                                            ? AppColors.errorRed
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),

                          // Clear button
                          if (_isComposing)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onPressed: () {
                                _messageController.clear();
                                setState(() {
                                  _isComposing = false;
                                  _showSuggestions = _focusNode.hasFocus;
                                });
                                _animationController.reverse();
                                if (_showSuggestions) {
                                  _suggestionController.forward();
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: AppConstants.sm),

                  // Send button or more options
                  Row(
                    children: [
                      // More options button
                      if (!_isComposing)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.secondaryBlue,
                              size: 20,
                            ),
                            onPressed: widget.isEnabled ? _showMoreOptions : null,
                          ),
                        ),

                      if (!_isComposing) const SizedBox(width: AppConstants.sm),

                      // Send button
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _isComposing && widget.isEnabled
                                ? AppColors.primaryBlue
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            boxShadow: _isComposing && widget.isEnabled
                                ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: _isComposing && widget.isEnabled
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: _isComposing && widget.isEnabled ? _sendMessage : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppConstants.xs),
              Text(
                'คำถามที่แนะนำ',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.sm),

          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quickSuggestions.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 100 + (index * 50)),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: const EdgeInsets.only(right: AppConstants.sm),
                        child: ActionChip(
                          label: Text(
                            _quickSuggestions[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () => _onSuggestionTapped(_quickSuggestions[index]),
                          backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                          side: BorderSide(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                          ),
                          labelStyle: const TextStyle(
                            color: AppColors.primaryBlue,
                          ),
                          avatar: Icon(
                            _getSuggestionIcon(_quickSuggestions[index]),
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSuggestionIcon(String suggestion) {
    if (suggestion.contains('ls')) return Icons.list;
    if (suggestion.contains('แนะนำ')) return Icons.recommend;
    if (suggestion.contains('ไฟล์')) return Icons.folder;
    if (suggestion.contains('ค้นหา')) return Icons.search;
    if (suggestion.contains('chmod')) return Icons.security;
    if (suggestion.contains('ทดสอบ')) return Icons.quiz;
    if (suggestion.contains('สถิติ')) return Icons.analytics;
    if (suggestion.contains('ช่วยเหลือ')) return Icons.help;
    if (suggestion.contains('grep')) return Icons.find_in_page;
    if (suggestion.contains('sudo')) return Icons.admin_panel_settings;
    if (suggestion.contains('tar')) return Icons.archive;
    if (suggestion.contains('ps')) return Icons.memory;
    return Icons.terminal;
  }
}