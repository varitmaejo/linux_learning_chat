import 'package:flutter/material.dart';
import '../providers/user_provider.dart';
import '../utils/themes.dart';

class ProgressChart extends StatefulWidget {
  final UserProvider userProvider;

  const ProgressChart({
    Key? key,
    required this.userProvider,
  }) : super(key: key);

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(
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
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 200),
          painter: ProgressChartPainter(
            userProvider: widget.userProvider,
            animation: _animation.value,
          ),
        );
      },
    );
  }
}

class ProgressChartPainter extends CustomPainter {
  final UserProvider userProvider;
  final double animation;

  ProgressChartPainter({
    required this.userProvider,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Generate mock data for the last 7 days
    final data = _generateWeeklyData();

    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Calculate dimensions
    final chartWidth = size.width - 60;
    final chartHeight = size.height - 60;
    final chartLeft = 40.0;
    final chartTop = 20.0;

    // Find max value for scaling
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final scaledMaxValue = (maxValue * 1.2).ceilToDouble();

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      final y = chartTop + (chartHeight / 5) * i;
      canvas.drawLine(
        Offset(chartLeft, y),
        Offset(chartLeft + chartWidth, y),
        gridPaint,
      );

      // Draw Y-axis labels
      final value = scaledMaxValue - (scaledMaxValue / 5) * i;
      textPainter.text = TextSpan(
        text: value.toInt().toString(),
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - textPainter.height / 2));
    }

    // Calculate points
    final points = <Offset>[];
    final fillPoints = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = chartLeft + (chartWidth / (data.length - 1)) * i;
      final normalizedValue = data[i].value / scaledMaxValue;
      final y = chartTop + chartHeight - (chartHeight * normalizedValue * animation);

      points.add(Offset(x, y));
    }

    // Create fill path
    if (points.isNotEmpty) {
      final fillPath = Path();
      fillPath.moveTo(chartLeft, chartTop + chartHeight);

      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }

      fillPath.lineTo(chartLeft + chartWidth, chartTop + chartHeight);
      fillPath.close();

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw point border
      canvas.drawCircle(point, 6, pointBorderPaint);
      // Draw point
      canvas.drawCircle(point, 4, pointPaint);

      // Draw X-axis labels
      textPainter.text = TextSpan(
        text: data[i].label,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(point.dx - textPainter.width / 2, chartTop + chartHeight + 10),
      );
    }
  }

  List<ChartData> _generateWeeklyData() {
    final now = DateTime.now();
    final data = <ChartData>[];

    // Generate data for the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);

      // Mock data based on user's actual progress
      // In a real app, this would come from stored daily statistics
      final baseValue = userProvider.learnedCommandsCount.toDouble();
      final randomVariation = (i * 0.5) + (date.day % 3);
      final value = (baseValue * 0.1) + randomVariation;

      data.add(ChartData(
        label: dayName,
        value: value.clamp(0, double.infinity),
        date: date,
      ));
    }

    return data;
  }

  String _getDayName(int weekday) {
    const days = ['', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
    return days[weekday];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ChartData {
  final String label;
  final double value;
  final DateTime date;

  ChartData({
    required this.label,
    required this.value,
    required this.date,
  });
}