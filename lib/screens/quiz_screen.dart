import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/themes.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';
import '../models/linux_command.dart';
import '../widgets/quiz_question_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {

  PageController? _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  List<QuizQuestion> _questions = [];
  Map<String, int> _answers = {};
  bool _isQuizStarted = false;
  bool _isQuizCompleted = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  DateTime? _quizStartTime;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Mark quiz as viewed when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().markQuizAsCompleted();
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _generateQuiz() {
    final userProvider = context.read<UserProvider>();
    final userLevel = userProvider.userLevel;

    // Generate questions based on user level
    _questions = _getQuestionsForLevel(userLevel);
    _questions.shuffle(); // Randomize question order

    setState(() {
      _isQuizStarted = true;
      _quizStartTime = DateTime.now();
      _currentQuestionIndex = 0;
      _answers.clear();
      _score = 0;
      _isQuizCompleted = false;
    });

    _pageController = PageController();
    _updateProgress();
  }

  List<QuizQuestion> _getQuestionsForLevel(UserLevel level) {
    // This would normally come from a database or service
    final allQuestions = [
      QuizQuestion(
        id: 'q1',
        question: 'คำสั่งใดใช้สำหรับแสดงรายการไฟล์ในไดเรกทอรี?',
        options: ['ls', 'cd', 'pwd', 'mkdir'],
        correctAnswer: 0,
        explanation: 'ls (list) ใช้สำหรับแสดงรายการไฟล์และโฟลเดอร์ในไดเรกทอรี',
        difficulty: CommandLevel.beginner,
        relatedCommand: 'ls',
      ),
      QuizQuestion(
        id: 'q2',
        question: 'คำสั่งใดใช้สำหรับเปลี่ยนไดเรกทอรี?',
        options: ['ls', 'cd', 'pwd', 'mkdir'],
        correctAnswer: 1,
        explanation: 'cd (change directory) ใช้สำหรับเปลี่ยนไดเรกทอรีปัจจุบัน',
        difficulty: CommandLevel.beginner,
        relatedCommand: 'cd',
      ),
      QuizQuestion(
        id: 'q3',
        question: 'option -r ใน rm มีความหมายว่าอย่างไร?',
        options: ['read-only', 'recursive', 'reverse', 'restore'],
        correctAnswer: 1,
        explanation: '-r หมายถึง recursive คือลบไดเรกทอรีและไฟล์ข้างในทั้งหมด',
        difficulty: CommandLevel.intermediate,
        relatedCommand: 'rm',
      ),
      QuizQuestion(
        id: 'q4',
        question: 'คำสั่งใดใช้สำหรับค้นหาข้อความในไฟล์?',
        options: ['find', 'grep', 'locate', 'search'],
        correctAnswer: 1,
        explanation: 'grep ใช้สำหรับค้นหาข้อความหรือ pattern ในไฟล์',
        difficulty: CommandLevel.intermediate,
        relatedCommand: 'grep',
      ),
      QuizQuestion(
        id: 'q5',
        question: 'chmod 755 หมายถึงอะไร?',
        options: ['rwxr-xr-x', 'rw-rw-rw-', 'rwxrwxrwx', 'r--r--r--'],
        correctAnswer: 0,
        explanation: '755 = rwxr-xr-x หมายถึง เจ้าของทำทุกอย่างได้ (rwx), กลุ่มและอื่นๆ อ่านและรันได้ (r-x)',
        difficulty: CommandLevel.advanced,
        relatedCommand: 'chmod',
      ),
      QuizQuestion(
        id: 'q6',
        question: 'คำสั่งใดใช้สำหรับแสดงกระบวนการที่ทำงานอยู่?',
        options: ['ps', 'top', 'jobs', 'proc'],
        correctAnswer: 0,
        explanation: 'ps (process status) ใช้สำหรับแสดงรายการกระบวนการที่ทำงานอยู่',
        difficulty: CommandLevel.intermediate,
        relatedCommand: 'ps',
      ),
      QuizQuestion(
        id: 'q7',
        question: 'sudo ย่อมาจากอะไร?',
        options: ['super do', 'substitute user do', 'system user do', 'secure do'],
        correctAnswer: 1,
        explanation: 'sudo ย่อมาจาก "substitute user do" หรือ "switch user do"',
        difficulty: CommandLevel.intermediate,
        relatedCommand: 'sudo',
      ),
      QuizQuestion(
        id: 'q8',
        question: 'คำสั่งใดใช้สำหรับบีบอัดไฟล์?',
        options: ['zip', 'tar', 'compress', 'gzip'],
        correctAnswer: 1,
        explanation: 'tar ใช้สำหรับรวมและบีบอัดไฟล์หลายไฟล์เป็นไฟล์เดียว',
        difficulty: CommandLevel.intermediate,
        relatedCommand: 'tar',
      ),
    ];

    // Filter questions based on user level
    List<QuizQuestion> filteredQuestions;
    switch (level) {
      case UserLevel.beginner:
        filteredQuestions = allQuestions.where((q) =>
        q.difficulty == CommandLevel.beginner
        ).toList();
        break;
      case UserLevel.intermediate:
        filteredQuestions = allQuestions.where((q) =>
        q.difficulty == CommandLevel.beginner ||
            q.difficulty == CommandLevel.intermediate
        ).toList();
        break;
      case UserLevel.advanced:
      case UserLevel.expert:
        filteredQuestions = allQuestions;
        break;
    }

    // Return 5 random questions
    filteredQuestions.shuffle();
    return filteredQuestions.take(5).toList();
  }

  void _answerQuestion(int selectedAnswer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex].id] = selectedAnswer;
    });

    // Auto-advance after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _completeQuiz();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController?.nextPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController?.previousPage(
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = (_currentQuestionIndex + 1) / _questions.length;
    _progressController.animateTo(progress);
  }

  void _completeQuiz() {
    // Calculate score
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _answers[question.id];
      if (userAnswer == question.correctAnswer) {
        correctAnswers++;
      }
    }

    final timeSpent = _quizStartTime != null
        ? DateTime.now().difference(_quizStartTime!).inSeconds
        : 0;

    setState(() {
      _score = correctAnswers;
      _isQuizCompleted = true;
    });

    // Save quiz result
    final userProvider = context.read<UserProvider>();
    final quizResult = QuizResult(
      id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      quizId: 'linux_basics',
      title: 'แบบทดสอบ Linux พื้นฐาน',
      score: correctAnswers,
      totalQuestions: _questions.length,
      completedAt: DateTime.now(),
      timeSpent: timeSpent,
      difficulty: userProvider.userLevel.name,
      incorrectAnswers: _getIncorrectAnswers(),
    );

    userProvider.addQuizResult(quizResult);
  }

  List<String> _getIncorrectAnswers() {
    final incorrect = <String>[];
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final userAnswer = _answers[question.id];
      if (userAnswer != question.correctAnswer) {
        incorrect.add(question.question);
      }
    }
    return incorrect;
  }

  void _resetQuiz() {
    setState(() {
      _isQuizStarted = false;
      _isQuizCompleted = false;
      _currentQuestionIndex = 0;
      _questions.clear();
      _answers.clear();
      _score = 0;
      _quizStartTime = null;
    });
    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isQuizStarted ? _buildQuizAppBar() : _buildDefaultAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildDefaultAppBar() {
    return AppBar(
      title: const Text('แบบทดสอบ'),
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
    );
  }

  PreferredSizeWidget _buildQuizAppBar() {
    return AppBar(
      title: Text('คำถามที่ ${_currentQuestionIndex + 1}/${_questions.length}'),
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => _showExitConfirmation(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (!_isQuizStarted) {
      return _buildQuizIntro();
    } else if (_isQuizCompleted) {
      return _buildQuizResults();
    } else {
      return _buildQuizContent();
    }
  }

  Widget _buildQuizIntro() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.1),
                      AppColors.secondaryBlue.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.quiz,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: AppConstants.md),
                    Text(
                      'แบบทดสอบ Linux',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: AppConstants.sm),
                    Text(
                      'ทดสอบความรู้ของคุณเกี่ยวกับคำสั่ง Linux',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.xl),

              // Quiz info
              Text(
                'ข้อมูลแบบทดสอบ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppConstants.md),

              _buildInfoCard(
                Icons.person,
                'ระดับของคุณ',
                '${userProvider.userLevel.emoji} ${userProvider.userLevel.displayName}',
                userProvider.userLevel.color,
              ),

              const SizedBox(height: AppConstants.sm),

              _buildInfoCard(
                Icons.quiz,
                'จำนวนคำถาม',
                '5 ข้อ',
                AppColors.infoBlue,
              ),

              const SizedBox(height: AppConstants.sm),

              _buildInfoCard(
                Icons.timer,
                'เวลาที่ใช้',
                'ไม่จำกัดเวลา',
                AppColors.successGreen,
              ),

              const SizedBox(height: AppConstants.sm),

              _buildInfoCard(
                Icons.grade,
                'เกณฑ์ผ่าน',
                '60% (3/5 ข้อ)',
                AppColors.warningOrange,
              ),

              const SizedBox(height: AppConstants.xl),

              // Previous quiz results
              if (userProvider.getRecentQuizResults().isNotEmpty) ...[
                Text(
                  'ผลการทดสอบล่าสุด',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.md),
                ...userProvider.getRecentQuizResults(limit: 3).map((result) {
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: result.passed
                              ? AppColors.successGreen.withOpacity(0.1)
                              : AppColors.errorRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          result.passed ? Icons.check : Icons.close,
                          color: result.passed
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                        ),
                      ),
                      title: Text(
                        '${result.score}/${result.totalQuestions} (${result.percentage.toInt()}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'เกรด ${result.grade} • ${_formatDate(result.completedAt)}',
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.sm,
                          vertical: AppConstants.xs,
                        ),
                        decoration: BoxDecoration(
                          color: result.passed
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                        ),
                        child: Text(
                          result.passed ? 'ผ่าน' : 'ไม่ผ่าน',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: AppConstants.xl),
              ],

              // Start quiz button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateQuiz,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow),
                      const SizedBox(width: AppConstants.sm),
                      Text(
                        'เริ่มทำแบบทดสอบ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppConstants.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return QuizQuestionCard(
                question: _questions[index],
                questionNumber: index + 1,
                totalQuestions: _questions.length,
                selectedAnswer: _answers[_questions[index].id],
                onAnswerSelected: _answerQuestion,
                isAnswered: _answers.containsKey(_questions[index].id),
              );
            },
          ),
        ),

        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(AppConstants.md),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: const Text('ย้อนกลับ'),
                  ),
                ),

              if (_currentQuestionIndex > 0)
                const SizedBox(width: AppConstants.md),

              if (_currentQuestionIndex < _questions.length - 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answers.containsKey(_questions[_currentQuestionIndex].id)
                        ? _nextQuestion
                        : null,
                    child: const Text('ถัดไป'),
                  ),
                ),

              if (_currentQuestionIndex == _questions.length - 1)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answers.containsKey(_questions[_currentQuestionIndex].id)
                        ? _completeQuiz
                        : null,
                    child: const Text('ส่งคำตอบ'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResults() {
    final percentage = (_score / _questions.length * 100).round();
    final passed = percentage >= 60;
    final grade = _getGrade(percentage);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.lg),
      child: Column(
        children: [
          // Results header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppConstants.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: passed
                    ? [
                  AppColors.successGreen.withOpacity(0.1),
                  AppColors.successGreen.withOpacity(0.05),
                ]
                    : [
                  AppColors.errorRed.withOpacity(0.1),
                  AppColors.errorRed.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
            ),
            child: Column(
              children: [
                Icon(
                  passed ? Icons.celebration : Icons.sentiment_dissatisfied,
                  size: 64,
                  color: passed ? AppColors.successGreen : AppColors.errorRed,
                ),
                const SizedBox(height: AppConstants.md),
                Text(
                  passed ? 'ยินดีด้วย!' : 'เสียใจด้วย',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: passed ? AppColors.successGreen : AppColors.errorRed,
                  ),
                ),
                const SizedBox(height: AppConstants.sm),
                Text(
                  passed
                      ? 'คุณผ่านการทดสอบแล้ว!'
                      : 'คุณยังไม่ผ่านการทดสอบ',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.xl),

          // Score details
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'คะแนน',
                  '$_score/${ _questions.length}',
                  Icons.grade,
                  AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: _buildScoreCard(
                  'เปอร์เซ็นต์',
                  '$percentage%',
                  Icons.percent,
                  AppColors.infoBlue,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.md),

          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'เกรด',
                  grade,
                  Icons.school,
                  _getGradeColor(grade),
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: _buildScoreCard(
                  'สถานะ',
                  passed ? 'ผ่าน' : 'ไม่ผ่าน',
                  passed ? Icons.check_circle : Icons.cancel,
                  passed ? AppColors.successGreen : AppColors.errorRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.xl),

          // Question review
          Text(
            'รายละเอียดคำตอบ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppConstants.md),

          ...List.generate(_questions.length, (index) {
            final question = _questions[index];
            final userAnswer = _answers[question.id];
            final isCorrect = userAnswer == question.correctAnswer;

            return Card(
              margin: const EdgeInsets.only(bottom: AppConstants.sm),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCorrect
                                ? AppColors.successGreen
                                : AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppConstants.sm),
                        Expanded(
                          child: Text(
                            'คำถามที่ ${index + 1}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.sm),

                    Text(
                      question.question,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: AppConstants.sm),

                    if (userAnswer != null) ...[
                      Text(
                        'คำตอบของคุณ: ${question.options[userAnswer]}',
                        style: TextStyle(
                          color: isCorrect
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    if (!isCorrect) ...[
                      Text(
                        'คำตอบที่ถูก: ${question.options[question.correctAnswer]}',
                        style: const TextStyle(
                          color: AppColors.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.sm),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.sm),
                      decoration: BoxDecoration(
                        color: AppColors.infoBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                      ),
                      child: Text(
                        question.explanation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: AppConstants.xl),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetQuiz,
                  child: const Text('ทำใหม่'),
                ),
              ),
              const SizedBox(width: AppConstants.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to chat screen for learning
                    DefaultTabController.of(context)?.animateTo(0);
                  },
                  child: const Text('เรียนรู้เพิ่ม'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.md),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGrade(int percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return AppColors.successGreen;
      case 'B':
        return AppColors.infoBlue;
      case 'C':
        return AppColors.warningOrange;
      case 'D':
        return AppColors.warningOrange;
      case 'F':
        return AppColors.errorRed;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'วันนี้';
    } else if (difference.inDays == 1) {
      return 'เมื่อวาน';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากการทดสอบ'),
        content: const Text(
          'คุณต้องการออกจากการทดสอบหรือไม่? '
              'ความคืบหน้าทั้งหมดจะหายไป',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetQuiz();
            },
            child: const Text('ออก'),
          ),
        ],
      ),
    );
  }
}