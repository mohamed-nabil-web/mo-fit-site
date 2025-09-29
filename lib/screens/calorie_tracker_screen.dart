import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/calorie_provider.dart';
import '../constants/app_theme.dart';
import '../models/food_model.dart';

class CalorieTrackerScreen extends StatefulWidget {
  const CalorieTrackerScreen({super.key});

  @override
  State<CalorieTrackerScreen> createState() => _CalorieTrackerScreenState();
}

class _CalorieTrackerScreenState extends State<CalorieTrackerScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);

    _startAnimations();
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, CalorieProvider>(
      builder: (context, appProvider, calorieProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header with daily summary
                  _buildHeader(appProvider, calorieProvider),

                  // Tab bar
                  _buildTabBar(appProvider),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCalculatorTab(appProvider, calorieProvider),
                        _buildFoodListTab(appProvider, calorieProvider),
                        _buildTodayLogTab(appProvider, calorieProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _showAddCustomFoodDialog(appProvider, calorieProvider),
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    final user = appProvider.currentUser;
    final dailyGoal = user?.calculateTDEE()?.round() ?? 2000;
    final consumed = calorieProvider.totalCaloriesToday;
    final remaining = (dailyGoal - consumed).clamp(0, double.infinity).toInt();
    final progress = dailyGoal > 0 ? consumed / dailyGoal : 0.0;

    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _headerController.value)),
          child: Opacity(
            opacity: _headerController.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Title
                  Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          appProvider.getString('calorie_tracker'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Daily summary card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        // Progress circle
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: progress.clamp(0.0, 1.0),
                                    strokeWidth: 8,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      progress > 1.0
                                          ? Colors.red
                                          : AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$consumed',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: progress > 1.0
                                            ? Colors.red
                                            : AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'من $dailyGoal',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              title: 'المستهلك',
                              value: '$consumed',
                              color: AppTheme.primaryColor,
                            ),
                            _buildStatItem(
                              title: 'المتبقي',
                              value: '$remaining',
                              color: remaining > 0 ? Colors.green : Colors.red,
                            ),
                            _buildStatItem(
                              title: 'الوجبات',
                              value: '${calorieProvider.todayEntries.length}',
                              color: Colors.orange,
                            ),
                          ],
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

  Widget _buildStatItem({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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

  Widget _buildTabBar(AppProvider appProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          gradient: AppTheme.primaryGradient,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.primaryColor,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'حاسبة السعرات'),
          Tab(text: 'قائمة الأطعمة'),
          Tab(text: 'سجل اليوم'),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentController.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // BMR Calculator Card
                _buildBMRCalculatorCard(appProvider),

                const SizedBox(height: 20),

                // Quick add calories card
                _buildQuickAddCard(appProvider, calorieProvider),

                const SizedBox(height: 20),

                // Nutrition tips card
                _buildNutritionTipsCard(appProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBMRCalculatorCard(AppProvider appProvider) {
    final user = appProvider.currentUser;
    final bmr = user?.calculateBMR();
    final tdee = user?.calculateTDEE();
    final bmi = user?.calculateBMI();

    return Container(
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
                Icons.calculate,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'حاسبة معدل الأيض',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (bmr != null && tdee != null) ...[
            _buildMetricRow(
                'معدل الأيض الأساسي (BMR)', '${bmr.round()} سعر/يوم'),
            _buildMetricRow(
                'إجمالي الطاقة المطلوبة (TDEE)', '${tdee.round()} سعر/يوم'),
            if (bmi != null) ...[
              _buildMetricRow('مؤشر كتلة الجسم (BMI)', bmi.toStringAsFixed(1)),
              _buildMetricRow('تصنيف الوزن', user!.getBMICategory()),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يرجى تحديث معلوماتك الشخصية لحساب احتياجاتك من السعرات',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddCard(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    final quickCalories = [100, 200, 300, 500];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إضافة سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickCalories.map((calories) {
              return ElevatedButton(
                onPressed: () {
                  _addQuickCalories(calorieProvider, calories, appProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                  ),
                ),
                child: Text('+$calories سعر'),
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildNutritionTipsCard(AppProvider appProvider) {
    final tips = [
      'اشرب 8 أكواب من الماء يومياً',
      'تناول 5 حصص من الفواكه والخضروات',
      'اختر الحبوب الكاملة بدلاً من المكررة',
      'قلل من السكريات المضافة',
    ];

    return Container(
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
                Icons.lightbulb_outline,
                color: Colors.orange,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'نصائح غذائية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildFoodListTab(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    return Column(
      children: [
        // Search and filter
        _buildSearchAndFilter(appProvider, calorieProvider),

        // Food list
        Expanded(
          child: _buildFoodList(appProvider, calorieProvider),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: calorieProvider.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'ابحث عن طعام...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: calorieProvider.categoriesWithCount.length,
              itemBuilder: (context, index) {
                final category =
                    calorieProvider.categoriesWithCount.keys.elementAt(index);
                final count = calorieProvider.categoriesWithCount[category]!;
                final isSelected = calorieProvider.selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('$category ($count)'),
                    selected: isSelected,
                    onSelected: (_) =>
                        calorieProvider.setSelectedCategory(category),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppTheme.primaryColor : Colors.grey[700],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    final foods = calorieProvider.filteredFoods;

    if (foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد أطعمة مطابقة للبحث',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return _buildFoodItem(food, appProvider, calorieProvider);
      },
    );
  }

  Widget _buildFoodItem(FoodModel food, AppProvider appProvider,
      CalorieProvider calorieProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.fastfood,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${food.caloriesPer100g} سعر/100جم • ${food.category}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
          onPressed: () =>
              _showAddFoodDialog(food, appProvider, calorieProvider),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildTodayLogTab(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    final entries = calorieProvider.todayEntries;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لم تضف أي وجبات اليوم',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('أضف وجبة'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildFoodEntryItem(entry, appProvider, calorieProvider);
      },
    );
  }

  Widget _buildFoodEntryItem(FoodEntry entry, AppProvider appProvider,
      CalorieProvider calorieProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(
            Icons.restaurant,
            color: Colors.orange,
          ),
        ),
        title: Text(
          entry.foodName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${entry.quantity.toStringAsFixed(0)}جم • ${entry.calories} سعر',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDeleteEntry(entry, calorieProvider),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, end: 0);
  }

  void _addQuickCalories(
      CalorieProvider calorieProvider, int calories, AppProvider appProvider) {
    calorieProvider.addFoodEntry(
      foodId: 'quick_${DateTime.now().millisecondsSinceEpoch}',
      foodName: 'إضافة سريعة',
      quantity: 100,
      calories: calories,
      userId: appProvider.currentUser?.id ?? '',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة $calories سعر حراري'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showAddFoodDialog(FoodModel food, AppProvider appProvider,
      CalorieProvider calorieProvider) {
    final quantityController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(food.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${food.caloriesPer100g} سعر حراري لكل 100 جرام'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية (جرام)',
                border: OutlineInputBorder(),
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
              final quantity = double.tryParse(quantityController.text) ?? 0;
              if (quantity > 0) {
                final calories = food.calculateCalories(quantity);
                calorieProvider.addFoodEntry(
                  foodId: food.id,
                  foodName: food.name,
                  quantity: quantity,
                  calories: calories,
                  userId: appProvider.currentUser?.id ?? '',
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إضافة ${food.name}'),
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

  void _showAddCustomFoodDialog(
      AppProvider appProvider, CalorieProvider calorieProvider) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String selectedCategory = 'أخرى';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة طعام مخصص'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الطعام',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعرات لكل 100 جرام',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                ),
                items: FoodDatabase.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
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
                final name = nameController.text.trim();
                final calories = int.tryParse(caloriesController.text) ?? 0;

                if (name.isNotEmpty && calories > 0) {
                  final customFood = FoodModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    nameEn: name,
                    caloriesPer100g: calories,
                    category: selectedCategory,
                    isCustom: true,
                    createdAt: DateTime.now(),
                  );

                  calorieProvider.addCustomFood(customFood);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إضافة $name إلى قائمة الأطعمة'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteEntry(FoodEntry entry, CalorieProvider calorieProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الوجبة'),
        content: Text('هل تريد حذف ${entry.foodName} من سجل اليوم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              calorieProvider.removeFoodEntry(entry.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف ${entry.foodName}'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
