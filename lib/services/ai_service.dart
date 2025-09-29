import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _apiKey =
      'YOUR_GEMINI_API_KEY'; // يجب استبدالها بالمفتاح الحقيقي

  static Future<String> getNutritionAdvice({
    required UserModel user,
    required List<Map<String, dynamic>> recentMeals,
    required int todaySteps,
    required String language,
  }) async {
    try {
      final prompt =
          _buildNutritionPrompt(user, recentMeals, todaySteps, language);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return content;
      } else {
        throw Exception(
            'فشل في الحصول على النصائح من AI: ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackAdvice(language);
    }
  }

  static String _buildNutritionPrompt(
    UserModel user,
    List<Map<String, dynamic>> recentMeals,
    int todaySteps,
    String language,
  ) {
    final isArabic = language == 'ar';

    final userInfo = '''
${isArabic ? 'معلومات المستخدم:' : 'User Information:'}
${isArabic ? '- العمر:' : '- Age:'} ${user.age ?? 'غير محدد'}
${isArabic ? '- الجنس:' : '- Gender:'} ${user.gender == 'male' ? (isArabic ? 'ذكر' : 'Male') : (isArabic ? 'أنثى' : 'Female')}
${isArabic ? '- الوزن:' : '- Weight:'} ${user.weight ?? 'غير محدد'} ${isArabic ? 'كيلو' : 'kg'}
${isArabic ? '- الطول:' : '- Height:'} ${user.height ?? 'غير محدد'} ${isArabic ? 'سم' : 'cm'}
${isArabic ? '- مستوى النشاط:' : '- Activity Level:'} ${_getActivityLevelText(user.activityLevel ?? 1.2, isArabic)}
${isArabic ? '- الهدف اليومي للسعرات:' : '- Daily Calorie Goal:'} ${user.calculateTDEE()?.round() ?? 2000}
''';

    final mealsInfo = recentMeals.isNotEmpty
        ? '''
${isArabic ? 'الوجبات الأخيرة:' : 'Recent Meals:'}
${recentMeals.map((meal) => '- ${meal['name']}: ${meal['calories']} ${isArabic ? 'سعر' : 'calories'}').join('\n')}
'''
        : isArabic
            ? 'لم يتم تسجيل وجبات اليوم'
            : 'No meals recorded today';

    final activityInfo = '''
${isArabic ? 'النشاط اليوم:' : 'Today\'s Activity:'}
${isArabic ? '- الخطوات:' : '- Steps:'} $todaySteps
''';

    final requestText = isArabic
        ? '''
بناءً على المعلومات أعلاه، قدم نصائح غذائية مخصصة ومفيدة باللغة العربية. يجب أن تتضمن النصائح:

1. تقييم النظام الغذائي الحالي
2. اقتراحات لتحسين التغذية
3. أطعمة مُوصى بها
4. أطعمة يُفضل تجنبها أو تقليلها
5. نصائح للوصول للهدف اليومي من السعرات
6. نصائح عامة للصحة واللياقة

اجعل النصائح عملية وقابلة للتطبيق، ومناسبة للثقافة العربية.
'''
        : '''
Based on the information above, provide personalized and helpful nutrition advice in English. The advice should include:

1. Assessment of current diet
2. Suggestions for improving nutrition
3. Recommended foods
4. Foods to avoid or limit
5. Tips for reaching daily calorie goals
6. General health and fitness tips

Make the advice practical and actionable.
''';

    return '$userInfo\n$mealsInfo\n$activityInfo\n$requestText';
  }

  static String _getActivityLevelText(double level, bool isArabic) {
    if (level <= 1.2) {
      return isArabic ? 'قليل الحركة' : 'Sedentary';
    } else if (level <= 1.375) {
      return isArabic ? 'نشاط خفيف' : 'Light Activity';
    } else if (level <= 1.55) {
      return isArabic ? 'نشاط متوسط' : 'Moderate Activity';
    } else if (level <= 1.725) {
      return isArabic ? 'نشاط عالي' : 'High Activity';
    } else {
      return isArabic ? 'نشاط عالي جداً' : 'Very High Activity';
    }
  }

  static String _getFallbackAdvice(String language) {
    final isArabic = language == 'ar';

    if (isArabic) {
      return '''
نصائح غذائية عامة:

🥗 التنويع في الطعام
• تناول مجموعة متنوعة من الفواكه والخضروات الملونة
• اختر الحبوب الكاملة بدلاً من المكررة
• أدرج مصادر البروتين الصحية في وجباتك

💧 الترطيب
• اشرب 8-10 أكواب من الماء يومياً
• قلل من المشروبات السكرية والغازية
• تناول الفواكه الغنية بالماء

⚖️ التوازن
• لا تفوت الوجبات الرئيسية
• تناول وجبات صغيرة ومتكررة
• استمع لإشارات الجوع والشبع من جسمك

🏃‍♂️ النشاط البدني
• امشِ 10,000 خطوة يومياً على الأقل
• مارس التمارين الرياضية بانتظام
• اختر الأنشطة التي تستمتع بها

⏰ التوقيت
• تناول وجبة الإفطار خلال ساعة من الاستيقاظ
• تجنب الأكل قبل النوم بـ 3 ساعات
• حافظ على مواعيد ثابتة للوجبات
''';
    } else {
      return '''
General Nutrition Tips:

🥗 Variety in Diet
• Eat a variety of colorful fruits and vegetables
• Choose whole grains over refined ones
• Include healthy protein sources in your meals

💧 Hydration
• Drink 8-10 glasses of water daily
• Reduce sugary and carbonated drinks
• Eat water-rich fruits

⚖️ Balance
• Don't skip main meals
• Eat small, frequent meals
• Listen to your body's hunger and satiety signals

🏃‍♂️ Physical Activity
• Walk at least 10,000 steps daily
• Exercise regularly
• Choose activities you enjoy

⏰ Timing
• Eat breakfast within an hour of waking up
• Avoid eating 3 hours before bedtime
• Maintain consistent meal times
''';
    }
  }

  static Future<String> getMealSuggestions({
    required UserModel user,
    required String mealType, // breakfast, lunch, dinner, snack
    required int remainingCalories,
    required String language,
  }) async {
    try {
      final prompt = _buildMealSuggestionPrompt(
          user, mealType, remainingCalories, language);

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 512,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        return content;
      } else {
        throw Exception('فشل في الحصول على اقتراحات الوجبات');
      }
    } catch (e) {
      return _getFallbackMealSuggestions(mealType, remainingCalories, language);
    }
  }

  static String _buildMealSuggestionPrompt(
    UserModel user,
    String mealType,
    int remainingCalories,
    String language,
  ) {
    final isArabic = language == 'ar';
    final mealTypeArabic = {
      'breakfast': 'الإفطار',
      'lunch': 'الغداء',
      'dinner': 'العشاء',
      'snack': 'وجبة خفيفة',
    };

    return isArabic
        ? '''
اقترح 3 خيارات صحية لوجبة ${mealTypeArabic[mealType]} تحتوي على حوالي $remainingCalories سعر حراري.

معلومات المستخدم:
- العمر: ${user.age ?? 'غير محدد'}
- الجنس: ${user.gender == 'male' ? 'ذكر' : 'أنثى'}
- الوزن: ${user.weight ?? 'غير محدد'} كيلو

يجب أن تكون الاقتراحات:
- صحية ومتوازنة
- مناسبة للثقافة العربية
- سهلة التحضير
- تحتوي على تقدير دقيق للسعرات

اكتب كل اقتراح في سطر منفصل مع السعرات.
'''
        : '''
Suggest 3 healthy options for $mealType containing approximately $remainingCalories calories.

User information:
- Age: ${user.age ?? 'Not specified'}
- Gender: ${user.gender == 'male' ? 'Male' : 'Female'}
- Weight: ${user.weight ?? 'Not specified'} kg

The suggestions should be:
- Healthy and balanced
- Easy to prepare
- Include accurate calorie estimates

Write each suggestion on a separate line with calories.
''';
  }

  static String _getFallbackMealSuggestions(
      String mealType, int calories, String language) {
    final isArabic = language == 'ar';

    final suggestions = {
      'breakfast': {
        'ar': [
          'شوفان بالفواكه والمكسرات (~300 سعر)',
          'بيض مسلوق مع خبز أسمر وخضار (~250 سعر)',
          'زبادي يوناني بالعسل والتوت (~200 سعر)',
        ],
        'en': [
          'Oatmeal with fruits and nuts (~300 calories)',
          'Boiled eggs with whole wheat bread and vegetables (~250 calories)',
          'Greek yogurt with honey and berries (~200 calories)',
        ],
      },
      'lunch': {
        'ar': [
          'سلطة الدجاج المشوي (~400 سعر)',
          'أرز بني مع الخضار والسمك (~450 سعر)',
          'شوربة العدس مع الخبز الأسمر (~350 سعر)',
        ],
        'en': [
          'Grilled chicken salad (~400 calories)',
          'Brown rice with vegetables and fish (~450 calories)',
          'Lentil soup with whole wheat bread (~350 calories)',
        ],
      },
      'dinner': {
        'ar': [
          'سمك مشوي مع الخضار (~300 سعر)',
          'سلطة كينوا بالخضار (~250 سعر)',
          'شوربة الخضار مع قطعة دجاج (~200 سعر)',
        ],
        'en': [
          'Grilled fish with vegetables (~300 calories)',
          'Quinoa salad with vegetables (~250 calories)',
          'Vegetable soup with chicken piece (~200 calories)',
        ],
      },
      'snack': {
        'ar': [
          'تفاحة مع ملعقة زبدة لوز (~150 سعر)',
          'حفنة مكسرات مشكلة (~100 سعر)',
          'زبادي قليل الدسم (~80 سعر)',
        ],
        'en': [
          'Apple with almond butter (~150 calories)',
          'Mixed nuts handful (~100 calories)',
          'Low-fat yogurt (~80 calories)',
        ],
      },
    };

    final mealSuggestions =
        suggestions[mealType]?[isArabic ? 'ar' : 'en'] ?? [];

    return mealSuggestions.join('\n');
  }

  static Future<String> getWorkoutSuggestions({
    required UserModel user,
    required int todaySteps,
    required String language,
  }) async {
    final isArabic = language == 'ar';

    // This would normally call Gemini API, but for now return fallback
    return _getFallbackWorkoutSuggestions(user, todaySteps, isArabic);
  }

  static String _getFallbackWorkoutSuggestions(
      UserModel user, int todaySteps, bool isArabic) {
    final goalSteps = user.dailyStepGoal ?? 10000;
    final remainingSteps = (goalSteps - todaySteps).clamp(0, goalSteps);

    if (isArabic) {
      if (remainingSteps > 5000) {
        return '''
🚶‍♂️ تحتاج إلى $remainingSteps خطوة إضافية

اقتراحات للنشاط:
• امشِ لمدة 30-45 دقيقة
• اصعد الدرج بدلاً من المصعد
• امشِ أثناء المكالمات الهاتفية
• اذهب للتسوق مشياً على الأقدام
• العب مع الأطفال في الحديقة
''';
      } else if (remainingSteps > 2000) {
        return '''
🚶‍♂️ تحتاج إلى $remainingSteps خطوة إضافية

اقتراحات سريعة:
• امشِ لمدة 15-20 دقيقة
• تجول في المنزل أثناء مشاهدة التلفاز
• امشِ إلى المتجر القريب
• اركن السيارة بعيداً عن الوجهة
''';
      } else if (remainingSteps > 0) {
        return '''
🎉 أنت قريب من هدفك! $remainingSteps خطوة فقط

اقتراحات بسيطة:
• امشِ حول المنزل لـ 5-10 دقائق
• اصعد ونزل الدرج عدة مرات
• امشِ في المكان أثناء انتظار شيء ما
''';
      } else {
        return '''
🏆 تهانينا! لقد حققت هدفك اليومي

للحفاظ على النشاط:
• تمارين الإطالة لمدة 10 دقائق
• تمارين التنفس العميق
• يوجا خفيفة قبل النوم
• استعد لتحدي الغد!
''';
      }
    } else {
      if (remainingSteps > 5000) {
        return '''
🚶‍♂️ You need $remainingSteps more steps

Activity suggestions:
• Walk for 30-45 minutes
• Take stairs instead of elevator
• Walk during phone calls
• Walk to the store
• Play with kids in the park
''';
      } else if (remainingSteps > 2000) {
        return '''
🚶‍♂️ You need $remainingSteps more steps

Quick suggestions:
• Walk for 15-20 minutes
• Walk around while watching TV
• Walk to nearby store
• Park farther from destination
''';
      } else if (remainingSteps > 0) {
        return '''
🎉 You're close to your goal! Only $remainingSteps steps

Simple suggestions:
• Walk around home for 5-10 minutes
• Go up and down stairs several times
• Walk in place while waiting
''';
      } else {
        return '''
🏆 Congratulations! You've reached your daily goal

To stay active:
• 10-minute stretching exercises
• Deep breathing exercises
• Light yoga before bed
• Get ready for tomorrow's challenge!
''';
      }
    }
  }
}
