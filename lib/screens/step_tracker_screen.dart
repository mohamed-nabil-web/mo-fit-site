import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/step_provider.dart';
import '../constants/app_theme.dart';
import '../models/step_model.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _progressController;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimations();
    _loadStepData();
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  void _loadStepData() {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    stepProvider.loadHistoricalData(appProvider.currentUser?.id ?? '');
  }

  @override
  void dispose() {
    _headerController.dispose();
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, StepProvider>(
      builder: (context, appProvider, stepProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    _buildHeader(appProvider, stepProvider),

                    // Main progress circle
                    _buildProgressSection(appProvider, stepProvider),

                    // Stats cards
                    _buildStatsCards(appProvider, stepProvider),

                    // Weekly chart
                    _buildWeeklyChart(appProvider, stepProvider),

                    // Achievement section
                    _buildAchievementSection(appProvider, stepProvider),

                    // Goal setting
                    _buildGoalSetting(appProvider, stepProvider),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showManualStepDialog(stepProvider),
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider appProvider, StepProvider stepProvider) {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerController.value)),
          child: Opacity(
            opacity: _headerController.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appProvider.getString('step_tracker'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'تتبع نشاطك اليومي',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Permission status indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stepProvider.hasPermission
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stepProvider.hasPermission
                              ? Icons.check_circle
                              : Icons.error,
                          color: stepProvider.hasPermission
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stepProvider.hasPermission ? 'متصل' : 'غير متصل',
                          style: TextStyle(
                            color: stepProvider.hasPermission
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildProgressSection(
      AppProvider appProvider, StepProvider stepProvider) {
    final todaySteps = stepProvider.todaySteps;
    final steps = todaySteps?.steps ?? 0;
    final goal = stepProvider.dailyGoal;
    final progress = stepProvider.progressPercentage;
    final isGoalAchieved = stepProvider.isGoalAchieved;

    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Main progress circle
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress * _progressController.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isGoalAchieved ? Colors.green : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      if (isGoalAchieved) ...[
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 32,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .scale(
                              duration: 1000.ms,
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.2, 1.2),
                            )
                            .then()
                            .scale(
                              duration: 1000.ms,
                              begin: const Offset(1.2, 1.2),
                              end: const Offset(0.8, 0.8),
                            ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        '$steps',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isGoalAchieved
                              ? Colors.green
                              : AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        appProvider.getString('steps'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'من $goal',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress text
              if (isGoalAchieved) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        appProvider.getString('goal_achieved'),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  '${stepProvider.remainingSteps} خطوة متبقية',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(AppProvider appProvider, StepProvider stepProvider) {
    final todaySteps = stepProvider.todaySteps;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Distance card
          Expanded(
            child: _buildStatCard(
              icon: Icons.straighten,
              title: 'المسافة',
              value: (todaySteps?.distance ?? 0).toStringAsFixed(1),
              unit: 'كم',
              color: Colors.blue,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideX(begin: -0.3, end: 0),
          ),

          const SizedBox(width: 16),

          // Calories card
          Expanded(
            child: _buildStatCard(
              icon: Icons.local_fire_department,
              title: 'السعرات المحروقة',
              value: '${todaySteps?.caloriesBurned ?? 0}',
              unit: 'سعر',
              color: Colors.orange,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideX(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(AppProvider appProvider, StepProvider stepProvider) {
    final weeklyData = stepProvider.weeklyData;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'الأسبوع الماضي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Simple bar chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.asMap().entries.map((entry) {
                final index = entry.key;
                final stepData = entry.value;
                final dayNames = [
                  'الأحد',
                  'الاثنين',
                  'الثلاثاء',
                  'الأربعاء',
                  'الخميس',
                  'الجمعة',
                  'السبت'
                ];
                final maxSteps = weeklyData.isNotEmpty
                    ? weeklyData
                        .map((e) => e.steps)
                        .reduce((a, b) => a > b ? a : b)
                    : 1;
                final height =
                    (stepData.steps / maxSteps * 80).clamp(10.0, 80.0);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        color: stepData.goalAchieved
                            ? Colors.green
                            : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (index * 100).ms, duration: 600.ms)
                        .slideY(begin: 1, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      dayNames[index % 7],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${stepData.steps}',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Weekly summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeeklyStat(
                'المتوسط',
                '${stepProvider.weeklyAverageSteps.round()}',
                Colors.blue,
              ),
              _buildWeeklyStat(
                'الإجمالي',
                '${stepProvider.weeklyTotalSteps}',
                Colors.green,
              ),
              _buildWeeklyStat(
                'الأهداف المحققة',
                '${stepProvider.weeklyGoalsAchieved}/7',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildWeeklyStat(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementSection(
      AppProvider appProvider, StepProvider stepProvider) {
    final achievements = [
      {
        'title': 'أول 1000 خطوة',
        'achieved': true,
        'icon': Icons.directions_walk
      },
      {
        'title': 'هدف يومي',
        'achieved': stepProvider.isGoalAchieved,
        'icon': Icons.flag
      },
      {
        'title': '10,000 خطوة',
        'achieved': (stepProvider.todaySteps?.steps ?? 0) >= 10000,
        'icon': Icons.emoji_events
      },
      {
        'title': 'أسبوع كامل',
        'achieved': stepProvider.weeklyGoalsAchieved >= 7,
        'icon': Icons.calendar_today
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'الإنجازات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              final isAchieved = achievement['achieved'] as bool;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAchieved
                      ? Colors.amber.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  border: Border.all(
                    color: isAchieved ? Colors.amber : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      achievement['icon'] as IconData,
                      color: isAchieved ? Colors.amber : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement['title'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAchieved ? Colors.amber[700] : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (index * 100).ms, duration: 600.ms)
                  .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0));
            }).toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildGoalSetting(AppProvider appProvider, StepProvider stepProvider) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.flag,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'هدف الخطوات اليومي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'الهدف الحالي: ${stepProvider.dailyGoal} خطوة',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showGoalDialog(stepProvider),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل الهدف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => stepProvider.addSteps(100),
                icon: const Icon(Icons.add),
                label: const Text('إضافة خطوات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _showGoalDialog(StepProvider stepProvider) {
    final goalController = TextEditingController(
      text: stepProvider.dailyGoal.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الهدف اليومي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر هدفك اليومي من الخطوات'),
            const SizedBox(height: 16),
            TextField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عدد الخطوات',
                border: OutlineInputBorder(),
                suffixText: 'خطوة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGoal = int.tryParse(goalController.text) ?? 10000;
              if (newGoal > 0) {
                stepProvider.setDailyGoal(newGoal);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث الهدف إلى $newGoal خطوة'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showManualStepDialog(StepProvider stepProvider) {
    final stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة خطوات يدوياً'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أضف خطوات إضافية لليوم'),
            const SizedBox(height: 16),
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'عدد الخطوات',
                border: OutlineInputBorder(),
                suffixText: 'خطوة',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(stepsController.text) ?? 0;
              if (steps > 0) {
                stepProvider.addSteps(steps);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إضافة $steps خطوة'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
