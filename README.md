# MoFit - تطبيق حاسبة السعرات الحرارية وتتبع اللياقة البدنية

![MoFit Logo](assets/images/logo.png)

## نظرة عامة

MoFit هو تطبيق شامل لتتبع الصحة واللياقة البدنية، مصمم خصيصاً لمساعدتك في تحقيق أهدافك الصحية. يوفر التطبيق مجموعة متكاملة من الأدوات لتتبع السعرات الحرارية، مراقبة النشاط البدني، وتلقي نصائح غذائية مخصصة.

## المميزات الرئيسية

### 🍎 تتبع السعرات الحرارية
- قاعدة بيانات شاملة للأطعمة العربية والعالمية
- حساب دقيق للسعرات الحرارية
- إمكانية إضافة أطعمة مخصصة
- تتبع الوجبات اليومية

### 🚶‍♂️ تتبع الخطوات والنشاط
- تتبع الخطوات باستخدام مستشعرات الهاتف
- حساب المسافة المقطوعة
- تقدير السعرات المحروقة
- تحديد أهداف يومية قابلة للتخصيص

### 🤖 نصائح ذكية بالذكاء الاصطناعي
- تكامل مع Google Gemini AI
- نصائح غذائية مخصصة
- اقتراحات وجبات صحية
- تحليل النظام الغذائي

### 📊 تقارير وإحصائيات
- رسوم بيانية تفاعلية
- تتبع التقدم الأسبوعي والشهري
- تحليل الأنماط الغذائية
- مؤشرات الصحة العامة

### 🌍 دعم متعدد اللغات
- واجهة باللغة العربية والإنجليزية
- تبديل سهل بين اللغات
- محتوى مناسب للثقافة العربية

### 🎨 تصميم عصري
- واجهة مستخدم حديثة وجذابة
- أنيميشن متقدم وسلس
- دعم الثيم الفاتح والداكن
- تصميم متجاوب لجميع أحجام الشاشات

## متطلبات النظام

- **Android**: 5.0 (API level 21) أو أحدث
- **iOS**: 11.0 أو أحدث
- **Flutter**: 3.1.0 أو أحدث
- **Dart**: 3.0.0 أو أحدث

## التثبيت والتشغيل

### 1. استنساخ المشروع
\`\`\`bash
git clone https://github.com/your-username/mofit_app.git
cd mofit_app
\`\`\`

### 2. تثبيت التبعيات
\`\`\`bash
flutter pub get
\`\`\`

### 3. إعداد مفتاح Gemini AI (اختياري)
1. احصل على مفتاح API من [Google AI Studio](https://makersuite.google.com/app/apikey)
2. أضف المفتاح في ملف \`lib/services/ai_service.dart\`:
\`\`\`dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY';
\`\`\`

### 4. تشغيل التطبيق
\`\`\`bash
# للتشغيل في وضع التطوير
flutter run

# لبناء APK للإنتاج
flutter build apk --release

# لبناء AAB للنشر في Google Play
flutter build appbundle --release
\`\`\`

## هيكل المشروع

\`\`\`
lib/
├── constants/          # الثوابت والإعدادات
│   ├── app_theme.dart
│   └── app_strings.dart
├── models/            # نماذج البيانات
│   ├── user_model.dart
│   ├── food_model.dart
│   └── step_model.dart
├── providers/         # إدارة الحالة
│   ├── app_provider.dart
│   ├── calorie_provider.dart
│   └── step_provider.dart
├── screens/          # شاشات التطبيق
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── calorie_tracker_screen.dart
│   ├── step_tracker_screen.dart
│   ├── settings_screen.dart
│   └── about_screen.dart
├── services/         # الخدمات الخارجية
│   └── ai_service.dart
└── main.dart        # نقطة البداية
\`\`\`

## الأذونات المطلوبة

### Android
- \`ACTIVITY_RECOGNITION\`: لتتبع الخطوات
- \`ACCESS_FINE_LOCATION\`: لحساب المسافة
- \`CAMERA\`: لالتقاط صور الملف الشخصي
- \`INTERNET\`: للتكامل مع AI
- \`VIBRATE\`: للإشعارات

### iOS
- \`NSMotionUsageDescription\`: لتتبع الخطوات
- \`NSCameraUsageDescription\`: لالتقاط الصور
- \`NSLocationWhenInUseUsageDescription\`: لحساب المسافة

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء فرع جديد (\`git checkout -b feature/amazing-feature\`)
3. Commit التغييرات (\`git commit -m 'Add amazing feature'\`)
4. Push إلى الفرع (\`git push origin feature/amazing-feature\`)
5. فتح Pull Request

## المطور

**Mohamed Nabil**
- 📧 Email: mohamed.nabil.11@outlook.com
- 💼 متخصص في تطوير تطبيقات Flutter
- 🌟 خبرة في حلول الصحة الرقمية

## الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## الدعم

إذا واجهت أي مشاكل أو لديك اقتراحات، يرجى:
- فتح Issue في GitHub
- التواصل عبر البريد الإلكتروني
- مراجعة قسم الأسئلة الشائعة في التطبيق

## الشكر والتقدير

- شكر خاص لمجتمع Flutter
- Google Gemini AI للنصائح الذكية
- جميع المساهمين في المشروع

---

**تم تطوير هذا التطبيق بـ ❤️ في مصر**

