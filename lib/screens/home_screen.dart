import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/calorie_provider.dart';
import '../providers/step_provider.dart';
import '../constants/app_theme.dart';
import 'calorie_tracker_screen.dart';
import 'step_tracker_screen.dart';
import 'update_profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    const HomeTab(),
    const CalorieTrackerScreen(),
    const StepTrackerScreen(),
    const UpdateProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Animate FAB
    _fabController.forward().then((_) {
      _fabController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(appProvider),
          floatingActionButton:
              _currentIndex == 0 ? _buildFloatingActionButton() : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(AppProvider appProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.largeRadius),
          topRight: Radius.circular(AppTheme.largeRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: appProvider.getString('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_outlined),
            activeIcon: const Icon(Icons.restaurant),
            label: appProvider.getString('calorie_tracker'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_walk_outlined),
            activeIcon: const Icon(Icons.directions_walk),
            label: appProvider.getString('step_tracker'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outlined),
            activeIcon: const Icon(Icons.person),
            label: appProvider.getString('profile'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: appProvider.getString('settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_fabController.value * 0.1),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            elevation: 8,
            child: const Icon(Icons.info_outline, size: 28),
          ),
        );
      },
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _cardsController;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _startAnimations();
  }

  void _startAnimations() {
    _greetingController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _greetingController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AppProvider, CalorieProvider, StepProvider>(
      builder: (context, appProvider, calorieProvider, stepProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting section
                    _buildGreetingSection(appProvider),

                    const SizedBox(height: 30),

                    // Quick stats cards
                    _buildQuickStatsCards(
                        appProvider, calorieProvider, stepProvider),

                    const SizedBox(height: 30),

                    // Today's summary
                    _buildTodaySummary(
                        appProvider, calorieProvider, stepProvider),

                    const SizedBox(height: 30),

                    // Quick actions
                    _buildQuickActions(appProvider),

                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingSection(AppProvider appProvider) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'صباح الخير';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'مساء الخير';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'مساء الخير';
      greetingIcon = Icons.nights_stay;
    }

    return AnimatedBuilder(
      animation: _greetingController,
      builder: (context, child) {
        return Opacity(
          opacity: _greetingController.value,
          child: Transform.translate(
            offset: Offset(0, -30 * (1 - _greetingController.value)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    greetingIcon,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        appProvider.currentUser?.name ?? 'مستخدم',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Show notifications or menu
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsCards(AppProvider appProvider,
      CalorieProvider calorieProvider, StepProvider stepProvider) {
    return AnimatedBuilder(
      animation: _cardsController,
      builder: (context, child) {
        return Opacity(
          opacity: _cardsController.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - _cardsController.value)),
            child: Row(
              children: [
                // Calories card
                Expanded(
                  child: _buildStatCard(
                    title: 'السعرات اليوم',
                    value: '${calorieProvider.totalCaloriesToday}',
                    unit: 'سعر',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    progress: calorieProvider
                        .getProgressPercentage(appProvider.currentUser),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ),

                const SizedBox(width: 16),

                // Steps card
                Expanded(
                  child: _buildStatCard(
                    title: 'الخطوات اليوم',
                    value: '${stepProvider.todaySteps?.steps ?? 0}',
                    unit: 'خطوة',
                    icon: Icons.directions_walk,
                    color: Colors.green,
                    progress: stepProvider.progressPercentage,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(AppProvider appProvider,
      CalorieProvider calorieProvider, StepProvider stepProvider) {
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
                Icons.today,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'ملخص اليوم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary items
          _buildSummaryItem(
            icon: Icons.restaurant,
            title: 'وجبات اليوم',
            value: '${calorieProvider.todayEntries.length}',
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.local_fire_department,
            title: 'السعرات المحروقة',
            value: '${stepProvider.todaySteps?.caloriesBurned ?? 0}',
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.straighten,
            title: 'المسافة المقطوعة',
            value:
                '${(stepProvider.todaySteps?.distance ?? 0).toStringAsFixed(1)} كم',
            color: Colors.blue,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(AppProvider appProvider) {
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
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  title: 'أضف وجبة',
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to add food
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.fitness_center,
                  title: 'تمرين جديد',
                  color: Colors.green,
                  onTap: () {
                    // Navigate to workout
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.psychology,
                  title: 'نصائح AI',
                  color: Colors.purple,
                  onTap: () {
                    // Navigate to AI advice
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.analytics,
                  title: 'التقارير',
                  color: Colors.blue,
                  onTap: () {
                    // Navigate to reports
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
