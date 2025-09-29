import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_strings.dart';

class AppProvider with ChangeNotifier {
  // Theme
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Language
  String _currentLanguage = 'ar';
  String get currentLanguage => _currentLanguage;

  // User
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Authentication
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  // Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Notifications
  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  // First time launch
  bool _isFirstLaunch = true;
  bool get isFirstLaunch => _isFirstLaunch;

  AppProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentLanguage = prefs.getString('currentLanguage') ?? 'ar';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      
      // Load user data if authenticated
      if (_isAuthenticated) {
        final userJson = prefs.getString('currentUser');
        if (userJson != null) {
          // In a real app, you would parse the JSON here
          // _currentUser = UserModel.fromJson(jsonDecode(userJson));
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  // Change language
  Future<void> changeLanguage(String language) async {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
      
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentLanguage', language);
      } catch (e) {
        debugPrint('Error saving language: $e');
      }
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    } catch (e) {
      debugPrint('Error saving notifications setting: $e');
    }
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Login user
  Future<void> loginUser(UserModel user) async {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      // In a real app, you would save the user JSON here
      // await prefs.setString('currentUser', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);
      await prefs.remove('currentUser');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      // In a real app, you would save the updated user JSON here
      // await prefs.setString('currentUser', jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  // Mark first launch as complete
  Future<void> completeFirstLaunch() async {
    _isFirstLaunch = false;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);
    } catch (e) {
      debugPrint('Error saving first launch: $e');
    }
  }

  // Get localized string
  String getString(String key) {
    return AppStrings.get(key, _currentLanguage);
  }

  // Get text direction based on language
  TextDirection get textDirection {
    return _currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr;
  }

  // Check if current language is Arabic
  bool get isArabic => _currentLanguage == 'ar';

  // Reset all settings
  Future<void> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isDarkMode = false;
      _currentLanguage = 'ar';
      _notificationsEnabled = true;
      _isFirstLaunch = true;
      _isAuthenticated = false;
      _currentUser = null;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}

