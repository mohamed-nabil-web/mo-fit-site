import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/step_model.dart';
import '../models/user_model.dart';

class StepProvider with ChangeNotifier {
  // Current step data
  StepData? _todaySteps;
  StepData? get todaySteps => _todaySteps;

  // Step stream
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  // Current status
  String _status = 'unknown';
  String get status => _status;

  // Permission status
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Goal
  int _dailyGoal = 10000;
  int get dailyGoal => _dailyGoal;

  // Historical data
  final List<StepData> _weeklyData = [];
  List<StepData> get weeklyData => _weeklyData;

  // Goal achievement notification
  bool _goalNotificationShown = false;

  StepProvider() {
    _initializePedometer();
  }

  // Initialize pedometer
  Future<void> _initializePedometer() async {
    await _requestPermissions();
    if (_hasPermission) {
      await _startListening();
    }
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    try {
      final status = await Permission.activityRecognition.request();
      _hasPermission = status.isGranted;

      if (!_hasPermission) {
        // Try alternative permission for older Android versions
        final altStatus = await Permission.sensors.request();
        _hasPermission = altStatus.isGranted;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      _hasPermission = false;
    }
  }

  // Start listening to step count
  Future<void> _startListening() async {
    if (!_hasPermission) return;

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

      _stepCountStream?.listen(
        _onStepCount,
        onError: _onStepCountError,
      );

      _pedestrianStatusStream?.listen(
        _onPedestrianStatusChanged,
        onError: _onPedestrianStatusError,
      );
    } catch (e) {
      debugPrint('Error starting pedometer: $e');
    }
  }

  // Handle step count updates
  void _onStepCount(StepCount event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if this is a new day
    if (_todaySteps?.date.day != today.day) {
      _resetDailySteps();
    }

    // Update today's steps
    _updateTodaySteps(event.steps, today);
  }

  // Handle step count errors
  void _onStepCountError(error) {
    debugPrint('Step count error: $error');
    _status = 'Step count not available';
    notifyListeners();
  }

  // Handle pedestrian status changes
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    _status = event.status;
    notifyListeners();
  }

  // Handle pedestrian status errors
  void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian status error: $error');
    _status = 'Pedestrian status not available';
    notifyListeners();
  }

  // Update today's step data
  void _updateTodaySteps(int totalSteps, DateTime date) {
    // Calculate steps for today (assuming we start from 0 each day)
    final todayStepCount = totalSteps;

    // Get user weight for calorie calculation
    const userWeight = 70.0; // Default weight, should come from user profile

    _todaySteps = StepData.fromStepCount(
      id: 'today_${date.millisecondsSinceEpoch}',
      steps: todayStepCount,
      userId: 'current_user', // Should come from auth
      userWeight: userWeight,
      goal: _dailyGoal,
      date: date,
    );

    // Check for goal achievement
    _checkGoalAchievement();

    notifyListeners();
  }

  // Reset daily steps for new day
  void _resetDailySteps() {
    _goalNotificationShown = false;
    // Save yesterday's data to history if it exists
    if (_todaySteps != null) {
      _addToHistory(_todaySteps!);
    }
  }

  // Add step data to history
  void _addToHistory(StepData stepData) {
    _weeklyData.add(stepData);

    // Keep only last 7 days
    if (_weeklyData.length > 7) {
      _weeklyData.removeAt(0);
    }
  }

  // Check if daily goal is achieved
  void _checkGoalAchievement() {
    if (_todaySteps != null &&
        _todaySteps!.isGoalAchieved &&
        !_goalNotificationShown) {
      _goalNotificationShown = true;
      // Trigger goal achievement notification
      _showGoalAchievementNotification();
    }
  }

  // Show goal achievement notification
  void _showGoalAchievementNotification() {
    // This would trigger a notification or celebration animation
    debugPrint('🎉 Daily step goal achieved! ${_todaySteps?.steps} steps');
  }

  // Set daily goal
  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;

    // Update today's step data with new goal
    if (_todaySteps != null) {
      _todaySteps = _todaySteps!.copyWith(
        goal: goal,
        goalAchieved: _todaySteps!.steps >= goal,
      );
    }

    notifyListeners();

    // Save to preferences
    // In a real app, you would save this to SharedPreferences or database
  }

  // Get progress percentage
  double get progressPercentage {
    if (_todaySteps == null) return 0.0;
    return _todaySteps!.progressPercentage;
  }

  // Get remaining steps to goal
  int get remainingSteps {
    if (_todaySteps == null) return _dailyGoal;
    return (_dailyGoal - _todaySteps!.steps).clamp(0, double.infinity).toInt();
  }

  // Check if goal is achieved
  bool get isGoalAchieved {
    return _todaySteps?.isGoalAchieved ?? false;
  }

  // Get weekly summary
  WeeklyStepSummary get weeklySummary {
    return WeeklyStepSummary.fromDailySteps(_weeklyData);
  }

  // Manually add steps (for testing or manual entry)
  void addSteps(int steps) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final currentSteps = _todaySteps?.steps ?? 0;
    _updateTodaySteps(currentSteps + steps, today);
  }

  // Reset today's steps
  void resetTodaySteps() {
    _todaySteps = null;
    _goalNotificationShown = false;
    notifyListeners();
  }

  // Load historical data
  Future<void> loadHistoricalData(String userId) async {
    _setLoading(true);

    try {
      // In a real app, you would load from database
      // For now, we'll generate some sample data
      _generateSampleData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading historical data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Generate sample data for demonstration
  void _generateSampleData() {
    _weeklyData.clear();
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final steps = 5000 + (i * 1000) + (DateTime.now().millisecond % 3000);

      final stepData = StepData.fromStepCount(
        id: 'day_${date.millisecondsSinceEpoch}',
        steps: steps,
        userId: 'current_user',
        userWeight: 70.0,
        goal: _dailyGoal,
        date: date,
      );

      _weeklyData.add(stepData);
    }
  }

  // Get average steps for the week
  double get weeklyAverageSteps {
    if (_weeklyData.isEmpty) return 0.0;
    final totalSteps =
        _weeklyData.fold<int>(0, (sum, data) => sum + data.steps);
    return totalSteps / _weeklyData.length;
  }

  // Get total steps for the week
  int get weeklyTotalSteps {
    return _weeklyData.fold<int>(0, (sum, data) => sum + data.steps);
  }

  // Get goals achieved this week
  int get weeklyGoalsAchieved {
    return _weeklyData.where((data) => data.goalAchieved).length;
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    // Cancel stream subscriptions if needed
    super.dispose();
  }
}
