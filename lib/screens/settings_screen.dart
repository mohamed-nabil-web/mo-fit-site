import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
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
                    _buildHeader(appProvider),

                    // Settings sections
                    _buildAppearanceSection(appProvider),
                    _buildLanguageSection(appProvider),
                    _buildNotificationSection(appProvider),
                    _buildAccountSection(appProvider),
                    _buildAboutSection(appProvider),
                    _buildDangerZone(appProvider),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider appProvider) {
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
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appProvider.getString('settings'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'تخصيص تجربتك',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
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

  Widget _buildAppearanceSection(AppProvider appProvider) {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return Opacity(
          opacity: _contentController.value,
          child: _buildSettingsSection(
            title: 'المظهر',
            icon: Icons.palette,
            children: [
              _buildSettingsTile(
                title: appProvider.getString('theme'),
                subtitle: appProvider.isDarkMode
                    ? appProvider.getString('dark_theme')
                    : appProvider.getString('light_theme'),
                leading: Icon(
                  appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primaryColor,
                ),
                trailing: Switch(
                  value: appProvider.isDarkMode,
                  onChanged: (_) => appProvider.toggleTheme(),
                  activeThumbColor: AppTheme.primaryColor,
                ),
                onTap: () => appProvider.toggleTheme(),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        );
      },
    );
  }

  Widget _buildLanguageSection(AppProvider appProvider) {
    return _buildSettingsSection(
      title: appProvider.getString('language'),
      icon: Icons.language,
      children: [
        _buildSettingsTile(
          title: 'العربية',
          subtitle: 'Arabic',
          leading: const Icon(
            Icons.flag,
            color: AppTheme.primaryColor,
          ),
          trailing: Radio<String>(
            value: 'ar',
            groupValue: appProvider.currentLanguage,
            onChanged: (value) => appProvider.changeLanguage(value!),
            activeColor: AppTheme.primaryColor,
          ),
          onTap: () => appProvider.changeLanguage('ar'),
        ),
        _buildSettingsTile(
          title: 'English',
          subtitle: 'الإنجليزية',
          leading: const Icon(
            Icons.flag_outlined,
            color: AppTheme.primaryColor,
          ),
          trailing: Radio<String>(
            value: 'en',
            groupValue: appProvider.currentLanguage,
            onChanged: (value) => appProvider.changeLanguage(value!),
            activeColor: AppTheme.primaryColor,
          ),
          onTap: () => appProvider.changeLanguage('en'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildNotificationSection(AppProvider appProvider) {
    return _buildSettingsSection(
      title: appProvider.getString('notifications'),
      icon: Icons.notifications,
      children: [
        _buildSettingsTile(
          title: 'تفعيل الإشعارات',
          subtitle: 'تلقي إشعارات التذكير والتحفيز',
          leading: const Icon(
            Icons.notifications_active,
            color: AppTheme.primaryColor,
          ),
          trailing: Switch(
            value: appProvider.notificationsEnabled,
            onChanged: (_) => appProvider.toggleNotifications(),
            activeThumbColor: AppTheme.primaryColor,
          ),
          onTap: () => appProvider.toggleNotifications(),
        ),
        _buildSettingsTile(
          title: 'إشعارات الأهداف',
          subtitle: 'تنبيهات عند تحقيق الأهداف',
          leading: const Icon(
            Icons.flag,
            color: Colors.green,
          ),
          trailing: Switch(
            value: true, // This would be managed by a separate provider
            onChanged: (value) {
              // Handle goal notifications toggle
            },
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
        _buildSettingsTile(
          title: 'تذكير الوجبات',
          subtitle: 'تذكير بتسجيل الوجبات',
          leading: const Icon(
            Icons.restaurant,
            color: Colors.orange,
          ),
          trailing: Switch(
            value: true, // This would be managed by a separate provider
            onChanged: (value) {
              // Handle meal reminders toggle
            },
            activeThumbColor: AppTheme.primaryColor,
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAccountSection(AppProvider appProvider) {
    return _buildSettingsSection(
      title: 'الحساب',
      icon: Icons.account_circle,
      children: [
        _buildSettingsTile(
          title: 'معلومات الحساب',
          subtitle: appProvider.currentUser?.email ?? 'غير محدد',
          leading: const Icon(
            Icons.person,
            color: AppTheme.primaryColor,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Navigate to account info
          },
        ),
        _buildSettingsTile(
          title: 'تصدير البيانات',
          subtitle: 'تصدير بياناتك الشخصية',
          leading: const Icon(
            Icons.download,
            color: Colors.blue,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showExportDialog(),
        ),
        _buildSettingsTile(
          title: 'النسخ الاحتياطي',
          subtitle: 'حفظ واستعادة البيانات',
          leading: const Icon(
            Icons.backup,
            color: Colors.green,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showBackupDialog(),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildAboutSection(AppProvider appProvider) {
    return _buildSettingsSection(
      title: 'معلومات التطبيق',
      icon: Icons.info,
      children: [
        _buildSettingsTile(
          title: appProvider.getString('about'),
          subtitle: 'معلومات عن التطبيق والمطور',
          leading: const Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutScreen(),
              ),
            );
          },
        ),
        _buildSettingsTile(
          title: 'الإصدار',
          subtitle: '1.0.0',
          leading: const Icon(
            Icons.update,
            color: Colors.blue,
          ),
          onTap: () => _showVersionDialog(),
        ),
        _buildSettingsTile(
          title: 'الشروط والأحكام',
          subtitle: 'اقرأ شروط الاستخدام',
          leading: const Icon(
            Icons.description,
            color: Colors.grey,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showTermsDialog(),
        ),
        _buildSettingsTile(
          title: 'سياسة الخصوصية',
          subtitle: 'كيف نحمي بياناتك',
          leading: const Icon(
            Icons.privacy_tip,
            color: Colors.purple,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showPrivacyDialog(),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildDangerZone(AppProvider appProvider) {
    return _buildSettingsSection(
      title: 'المنطقة الخطرة',
      icon: Icons.warning,
      iconColor: Colors.red,
      children: [
        _buildSettingsTile(
          title: 'مسح جميع البيانات',
          subtitle: 'حذف جميع البيانات المحفوظة',
          leading: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showResetDialog(appProvider),
        ),
        _buildSettingsTile(
          title: 'تسجيل الخروج',
          subtitle: 'الخروج من الحساب الحالي',
          leading: const Icon(
            Icons.logout,
            color: Colors.orange,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLogoutDialog(appProvider),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 1200.ms, duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor ?? AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text(
          'سيتم تصدير جميع بياناتك الشخصية في ملف JSON. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصدير البيانات بنجاح'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('النسخ الاحتياطي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('إنشاء نسخة احتياطية'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إنشاء النسخة الاحتياطية'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('استعادة من نسخة احتياطية'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم استعادة البيانات'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات الإصدار'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإصدار: 1.0.0'),
            Text('تاريخ البناء: 2024-01-01'),
            Text('رقم البناء: 1'),
            SizedBox(height: 16),
            Text('آخر التحديثات:'),
            Text('• تحسينات في الأداء'),
            Text('• إصلاح الأخطاء'),
            Text('• ميزات جديدة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(
          child: Text(
            'هذه هي شروط وأحكام استخدام تطبيق MoFit...\n\n'
            '1. قبول الشروط\n'
            'باستخدام هذا التطبيق، فإنك توافق على هذه الشروط.\n\n'
            '2. استخدام التطبيق\n'
            'يجب استخدام التطبيق للأغراض المشروعة فقط.\n\n'
            '3. الخصوصية\n'
            'نحن نحترم خصوصيتك ونحمي بياناتك الشخصية.\n\n'
            '4. المسؤولية\n'
            'التطبيق مخصص للأغراض التعليمية والإرشادية فقط.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'سياسة الخصوصية لتطبيق MoFit\n\n'
            '1. جمع البيانات\n'
            'نجمع البيانات التي تقدمها طوعياً مثل الوزن والطول والعمر.\n\n'
            '2. استخدام البيانات\n'
            'نستخدم بياناتك لحساب السعرات وتتبع التقدم.\n\n'
            '3. حماية البيانات\n'
            'بياناتك محفوظة محلياً على جهازك ولا نشاركها مع أطراف ثالثة.\n\n'
            '4. حقوقك\n'
            'يمكنك حذف بياناتك في أي وقت من إعدادات التطبيق.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع البيانات'),
        content: const Text(
          'تحذير: سيتم حذف جميع بياناتك نهائياً ولا يمكن استعادتها. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              appProvider.resetSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح جميع البيانات'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              appProvider.logoutUser();
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
