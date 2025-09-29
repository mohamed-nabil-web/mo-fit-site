import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../models/user_model.dart';

class CalorieProvider with ChangeNotifier {
  // Food database
  List<FoodModel> _foods = [];
  List<FoodModel> get foods => _foods;

  // Today's food entries
  List<FoodEntry> _todayEntries = [];
  List<FoodEntry> get todayEntries => _todayEntries;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Selected category filter
  String _selectedCategory = 'الكل';
  String get selectedCategory => _selectedCategory;

  CalorieProvider() {
    _initializeFoods();
  }

  // Initialize with default foods
  void _initializeFoods() {
    _foods = FoodDatabase.defaultFoods;
    notifyListeners();
  }

  // Get filtered foods based on search and category
  List<FoodModel> get filteredFoods {
    List<FoodModel> filtered = _foods;

    // Filter by category
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((food) => food.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((food) =>
          food.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          food.nameEn.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Add custom food
  Future<void> addCustomFood(FoodModel food) async {
    _setLoading(true);
    
    try {
      final customFood = food.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isCustom: true,
        createdAt: DateTime.now(),
      );
      
      _foods.add(customFood);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding custom food: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Add food entry
  Future<void> addFoodEntry({
    required String foodId,
    required String foodName,
    required double quantity,
    required int calories,
    required String userId,
  }) async {
    _setLoading(true);
    
    try {
      final entry = FoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        foodId: foodId,
        foodName: foodName,
        quantity: quantity,
        calories: calories,
        consumedAt: DateTime.now(),
        userId: userId,
      );
      
      _todayEntries.add(entry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding food entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Remove food entry
  Future<void> removeFoodEntry(String entryId) async {
    _setLoading(true);
    
    try {
      _todayEntries.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing food entry: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get total calories consumed today
  int get totalCaloriesToday {
    return _todayEntries.fold<int>(0, (sum, entry) => sum + entry.calories);
  }

  // Get remaining calories for user
  int getRemainingCalories(UserModel? user) {
    if (user?.dailyCalorieGoal == null) return 0;
    return (user!.dailyCalorieGoal! - totalCaloriesToday).clamp(0, double.infinity).toInt();
  }

  // Get progress percentage
  double getProgressPercentage(UserModel? user) {
    if (user?.dailyCalorieGoal == null || user!.dailyCalorieGoal! == 0) return 0.0;
    return (totalCaloriesToday / user.dailyCalorieGoal!).clamp(0.0, 1.0);
  }

  // Check if over calorie limit
  bool isOverLimit(UserModel? user) {
    if (user?.dailyCalorieGoal == null) return false;
    return totalCaloriesToday > user!.dailyCalorieGoal!;
  }

  // Get food by ID
  FoodModel? getFoodById(String foodId) {
    try {
      return _foods.firstWhere((food) => food.id == foodId);
    } catch (e) {
      return null;
    }
  }

  // Get entries by date
  List<FoodEntry> getEntriesByDate(DateTime date) {
    return _todayEntries.where((entry) {
      final entryDate = entry.consumedAt;
      return entryDate.year == date.year &&
             entryDate.month == date.month &&
             entryDate.day == date.day;
    }).toList();
  }

  // Clear today's entries
  void clearTodayEntries() {
    _todayEntries.clear();
    notifyListeners();
  }

  // Load entries for specific date
  Future<void> loadEntriesForDate(DateTime date, String userId) async {
    _setLoading(true);
    
    try {
      // In a real app, you would load from database
      // For now, we'll just filter existing entries
      _todayEntries = getEntriesByDate(date);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading entries: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Get categories with food count
  Map<String, int> get categoriesWithCount {
    final Map<String, int> categoryCount = {'الكل': _foods.length};
    
    for (final category in FoodDatabase.categories) {
      final count = _foods.where((food) => food.category == category).length;
      if (count > 0) {
        categoryCount[category] = count;
      }
    }
    
    return categoryCount;
  }

  // Calculate calories for specific food and quantity
  int calculateCalories(FoodModel food, double quantityInGrams) {
    return food.calculateCalories(quantityInGrams);
  }

  // Get nutrition summary for today
  Map<String, dynamic> getTodayNutritionSummary() {
    final totalCalories = totalCaloriesToday;
    final totalEntries = _todayEntries.length;
    final averageCaloriesPerMeal = totalEntries > 0 ? totalCalories / totalEntries : 0;
    
    // Group by category
    final Map<String, int> caloriesByCategory = {};
    for (final entry in _todayEntries) {
      final food = getFoodById(entry.foodId);
      if (food != null) {
        caloriesByCategory[food.category] = 
            (caloriesByCategory[food.category] ?? 0) + entry.calories;
      }
    }
    
    return {
      'totalCalories': totalCalories,
      'totalEntries': totalEntries,
      'averageCaloriesPerMeal': averageCaloriesPerMeal.round(),
      'caloriesByCategory': caloriesByCategory,
    };
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Reset all data
  void reset() {
    _foods = FoodDatabase.defaultFoods;
    _todayEntries.clear();
    _searchQuery = '';
    _selectedCategory = 'الكل';
    notifyListeners();
  }
}

