import 'package:flutter/material.dart';
import '../models/linux_command.dart';
import '../utils/themes.dart';

class QuizQuestionCard extends StatefulWidget {
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final Function(int) onAnswerSelected;
  final bool isAnswered;

  const QuizQuestionCard({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.onAnswerSelected,
    required this.isAnswered,
  }) : super(key: key);

  @override
  State<QuizQuestionCard> createState() => _QuizQuestionCardState();
}

class _QuizQuestionCardState extends State<QuizQuestionCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              _buildQuestionHeader(),

              const SizedBox(height: AppConstants.xl),

              // Question card
              _buildQuestionCard(),

              const SizedBox(height: AppConstants.xl),

              // Answer options
              _buildAnswerOptions(),

              if (widget.isAnswered) ...[
                const SizedBox(height: AppConstants.xl),
                _buildFeedback(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Row(
      children: [
        // Question number indicator
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
          child: Center(
            child: Text(
              '${widget.questionNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppConstants.md),

        // Question progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'คำถามที่ ${widget.questionNumber}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                'จาก ${widget.totalQuestions} คำถาม',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Difficulty indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.sm,
            vertical: AppConstants.xs,
          ),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getDifficultyIcon(),
                size: 16,
                color: _getDifficultyColor(),
              ),
              const SizedBox(width: AppConstants.xs),
              Text(
                widget.question.difficulty.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getDifficultyColor(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primaryBlue.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Icon(
                Icons.quiz,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),

            const SizedBox(height: AppConstants.md),

            // Question text
            Text(
              widget.question.question,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),

            // Related command hint
            if (widget.question.relatedCommand != null) ...[
              const SizedBox(height: AppConstants.md),
              Container(
                padding: const EdgeInsets.all(AppConstants.sm),
                decoration: BoxDecoration(
                  color: AppColors.commandHighlight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.terminal,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: AppConstants.xs),
                    Text(
                      'เกี่ยวกับคำสั่ง: ${widget.question.relatedCommand}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เลือกคำตอบที่ถูกต้อง:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: AppConstants.md),

        ...List.generate(widget.question.options.length, (index) {
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200 + (index * 100)),
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: _buildAnswerOption(index),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAnswerOption(int index) {
    final isSelected = widget.selectedAnswer == index;
    final isCorrect = index == widget.question.correctAnswer;
    final showResult = widget.isAnswered;

    Color borderColor;
    Color backgroundColor;
    Color textColor = AppColors.textPrimary;

    if (showResult) {
      if (isSelected && isCorrect) {
        // Selected and correct
        borderColor = AppColors.successGreen;
        backgroundColor = AppColors.successGreen.withOpacity(0.1);
        textColor = AppColors.successGreen;
      } else if (isSelected && !isCorrect) {
        // Selected but incorrect
        borderColor = AppColors.errorRed;
        backgroundColor = AppColors.errorRed.withOpacity(0.1);
        textColor = AppColors.errorRed;
      } else if (!isSelected && isCorrect) {
        // Not selected but correct (show correct answer)
        borderColor = AppColors.successGreen;
        backgroundColor = AppColors.successGreen.withOpacity(0.05);
        textColor = AppColors.successGreen;
      } else {
        // Default
        borderColor = Colors.grey.shade300;
        backgroundColor = Colors.transparent;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primaryBlue;
        backgroundColor = AppColors.primaryBlue.withOpacity(0.1);
        textColor = AppColors.primaryBlue;
      } else {
        borderColor = Colors.grey.shade300;
        backgroundColor = Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.sm),
      child: InkWell(
        onTap: widget.isAnswered ? null : () => widget.onAnswerSelected(index),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        child: AnimatedContainer(
          duration: AppConstants.shortAnimation,
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.md),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              // Option letter
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppConstants.md),

              // Option text
              Expanded(
                child: Text(
                  widget.question.options[index],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),

              // Status icon
              if (showResult) ...[
                const SizedBox(width: AppConstants.sm),
                if (isSelected && isCorrect)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.successGreen,
                    size: 24,
                  )
                else if (isSelected && !isCorrect)
                  Icon(
                    Icons.cancel,
                    color: AppColors.errorRed,
                    size: 24,
                  )
                else if (!isSelected && isCorrect)
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.successGreen,
                      size: 24,
                    ),
              ] else if (isSelected) ...[
                const SizedBox(width: AppConstants.sm),
                Icon(
                  Icons.radio_button_checked,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final isCorrect = widget.selectedAnswer == widget.question.correctAnswer;

    return AnimatedContainer(
      duration: AppConstants.mediumAnimation,
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.md),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.errorRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(
          color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                size: 24,
              ),
              const SizedBox(width: AppConstants.sm),
              Text(
                isCorrect ? 'ถูกต้อง!' : 'ไม่ถูกต้อง',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.sm),

          Text(
            widget.question.explanation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),

          if (widget.question.relatedCommand != null) ...[
            const SizedBox(height: AppConstants.sm),
            Container(
              padding: const EdgeInsets.all(AppConstants.sm),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.infoBlue,
                  ),
                  const SizedBox(width: AppConstants.xs),
                  Text(
                    'เรียนรู้เพิ่มเติมเกี่ยวกับคำสั่ง ${widget.question.relatedCommand}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.infoBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.question.difficulty) {
      case CommandLevel.beginner:
        return AppColors.successGreen;
      case CommandLevel.intermediate:
        return AppColors.warningOrange;
      case CommandLevel.advanced:
        return AppColors.errorRed;
      case CommandLevel.expert:
        return AppColors.infoBlue;
    }
  }

  IconData _getDifficultyIcon() {
    switch (widget.question.difficulty) {
      case CommandLevel.beginner:
        return Icons.sentiment_very_satisfied;
      case CommandLevel.intermediate:
        return Icons.sentiment_satisfied;
      case CommandLevel.advanced:
        return Icons.sentiment_neutral;
      case CommandLevel.expert:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}