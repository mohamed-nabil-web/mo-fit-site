class StepData {
  final String id;
  final int steps;
  final double distance; // in kilometers
  final int caloriesBurned;
  final DateTime date;
  final String userId;
  final int goal;
  final bool goalAchieved;

  StepData({
    required this.id,
    required this.steps,
    required this.distance,
    required this.caloriesBurned,
    required this.date,
    required this.userId,
    required this.goal,
    required this.goalAchieved,
  });

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      id: json['id'] ?? '',
      steps: json['steps'] ?? 0,
      distance: json['distance']?.toDouble() ?? 0.0,
      caloriesBurned: json['caloriesBurned'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
      goal: json['goal'] ?? 10000,
      goalAchieved: json['goalAchieved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'steps': steps,
      'distance': distance,
      'caloriesBurned': caloriesBurned,
      'date': date.toIso8601String(),
      'userId': userId,
      'goal': goal,
      'goalAchieved': goalAchieved,
    };
  }

  StepData copyWith({
    String? id,
    int? steps,
    double? distance,
    int? caloriesBurned,
    DateTime? date,
    String? userId,
    int? goal,
    bool? goalAchieved,
  }) {
    return StepData(
      id: id ?? this.id,
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      date: date ?? this.date,
      userId: userId ?? this.userId,
      goal: goal ?? this.goal,
      goalAchieved: goalAchieved ?? this.goalAchieved,
    );
  }

  // Calculate progress percentage
  double get progressPercentage {
    if (goal == 0) return 0.0;
    return (steps / goal).clamp(0.0, 1.0);
  }

  // Check if goal is achieved
  bool get isGoalAchieved => steps >= goal;

  // Calculate estimated calories burned based on steps
  static int calculateCaloriesBurned(int steps, double weightKg) {
    // Average: 0.04 calories per step per kg of body weight
    return (steps * 0.04 * weightKg).round();
  }

  // Calculate distance based on steps
  static double calculateDistance(int steps) {
    // Average step length: 0.762 meters
    const double averageStepLength = 0.000762; // in kilometers
    return steps * averageStepLength;
  }

  // Create StepData from step count and user weight
  static StepData fromStepCount({
    required String id,
    required int steps,
    required String userId,
    required double userWeight,
    required int goal,
    DateTime? date,
  }) {
    final distance = calculateDistance(steps);
    final caloriesBurned = calculateCaloriesBurned(steps, userWeight);
    final goalAchieved = steps >= goal;

    return StepData(
      id: id,
      steps: steps,
      distance: distance,
      caloriesBurned: caloriesBurned,
      date: date ?? DateTime.now(),
      userId: userId,
      goal: goal,
      goalAchieved: goalAchieved,
    );
  }
}

class WeeklyStepSummary {
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<StepData> dailySteps;
  final int totalSteps;
  final double totalDistance;
  final int totalCaloriesBurned;
  final int goalsAchieved;
  final double averageSteps;

  WeeklyStepSummary({
    required this.weekStart,
    required this.weekEnd,
    required this.dailySteps,
    required this.totalSteps,
    required this.totalDistance,
    required this.totalCaloriesBurned,
    required this.goalsAchieved,
    required this.averageSteps,
  });

  factory WeeklyStepSummary.fromDailySteps(List<StepData> steps) {
    if (steps.isEmpty) {
      return WeeklyStepSummary(
        weekStart: DateTime.now(),
        weekEnd: DateTime.now(),
        dailySteps: [],
        totalSteps: 0,
        totalDistance: 0.0,
        totalCaloriesBurned: 0,
        goalsAchieved: 0,
        averageSteps: 0.0,
      );
    }

    final sortedSteps = List<StepData>.from(steps)
      ..sort((a, b) => a.date.compareTo(b.date));

    final weekStart = sortedSteps.first.date;
    final weekEnd = sortedSteps.last.date;
    final totalSteps = sortedSteps.fold<int>(0, (sum, step) => sum + step.steps);
    final totalDistance = sortedSteps.fold<double>(0, (sum, step) => sum + step.distance);
    final totalCaloriesBurned = sortedSteps.fold<int>(0, (sum, step) => sum + step.caloriesBurned);
    final goalsAchieved = sortedSteps.where((step) => step.goalAchieved).length;
    final averageSteps = steps.isNotEmpty ? totalSteps / steps.length : 0.0;

    return WeeklyStepSummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      dailySteps: sortedSteps,
      totalSteps: totalSteps,
      totalDistance: totalDistance,
      totalCaloriesBurned: totalCaloriesBurned,
      goalsAchieved: goalsAchieved,
      averageSteps: averageSteps,
    );
  }
}

class StepGoal {
  final String id;
  final int dailyStepGoal;
  final int weeklyStepGoal;
  final int monthlyStepGoal;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  StepGoal({
    required this.id,
    required this.dailyStepGoal,
    required this.weeklyStepGoal,
    required this.monthlyStepGoal,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StepGoal.fromJson(Map<String, dynamic> json) {
    return StepGoal(
      id: json['id'] ?? '',
      dailyStepGoal: json['dailyStepGoal'] ?? 10000,
      weeklyStepGoal: json['weeklyStepGoal'] ?? 70000,
      monthlyStepGoal: json['monthlyStepGoal'] ?? 300000,
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dailyStepGoal': dailyStepGoal,
      'weeklyStepGoal': weeklyStepGoal,
      'monthlyStepGoal': monthlyStepGoal,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  StepGoal copyWith({
    String? id,
    int? dailyStepGoal,
    int? weeklyStepGoal,
    int? monthlyStepGoal,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StepGoal(
      id: id ?? this.id,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      weeklyStepGoal: weeklyStepGoal ?? this.weeklyStepGoal,
      monthlyStepGoal: monthlyStepGoal ?? this.monthlyStepGoal,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

