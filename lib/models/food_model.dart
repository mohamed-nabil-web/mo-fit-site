class FoodModel {
  final String id;
  final String name;
  final String nameEn;
  final int caloriesPer100g;
  final String category;
  final String? description;
  final bool isCustom;
  final DateTime createdAt;

  FoodModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.caloriesPer100g,
    required this.category,
    this.description,
    this.isCustom = false,
    required this.createdAt,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      caloriesPer100g: json['caloriesPer100g'] ?? 0,
      category: json['category'] ?? '',
      description: json['description'],
      isCustom: json['isCustom'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'caloriesPer100g': caloriesPer100g,
      'category': category,
      'description': description,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? nameEn,
    int? caloriesPer100g,
    String? category,
    String? description,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      category: category ?? this.category,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate calories for specific weight
  int calculateCalories(double weightInGrams) {
    return ((caloriesPer100g * weightInGrams) / 100).round();
  }
}

class FoodEntry {
  final String id;
  final String foodId;
  final String foodName;
  final double quantity; // in grams
  final int calories;
  final DateTime consumedAt;
  final String userId;

  FoodEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.calories,
    required this.consumedAt,
    required this.userId,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] ?? '',
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      quantity: json['quantity']?.toDouble() ?? 0.0,
      calories: json['calories'] ?? 0,
      consumedAt: DateTime.parse(json['consumedAt'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'calories': calories,
      'consumedAt': consumedAt.toIso8601String(),
      'userId': userId,
    };
  }
}

// Pre-defined food database
class FoodDatabase {
  static List<FoodModel> get defaultFoods => [
    // Grains & Cereals
    FoodModel(
      id: '1',
      name: 'أرز أبيض مطبوخ',
      nameEn: 'Cooked White Rice',
      caloriesPer100g: 130,
      category: 'حبوب',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '2',
      name: 'خبز أبيض',
      nameEn: 'White Bread',
      caloriesPer100g: 265,
      category: 'حبوب',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '3',
      name: 'خبز أسمر',
      nameEn: 'Brown Bread',
      caloriesPer100g: 247,
      category: 'حبوب',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '4',
      name: 'مكرونة مطبوخة',
      nameEn: 'Cooked Pasta',
      caloriesPer100g: 131,
      category: 'حبوب',
      createdAt: DateTime.now(),
    ),
    
    // Proteins
    FoodModel(
      id: '5',
      name: 'دجاج مشوي بدون جلد',
      nameEn: 'Grilled Chicken Breast',
      caloriesPer100g: 165,
      category: 'بروتين',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '6',
      name: 'لحم بقري مطبوخ',
      nameEn: 'Cooked Beef',
      caloriesPer100g: 250,
      category: 'بروتين',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '7',
      name: 'سمك مشوي',
      nameEn: 'Grilled Fish',
      caloriesPer100g: 206,
      category: 'بروتين',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '8',
      name: 'بيض مسلوق',
      nameEn: 'Boiled Egg',
      caloriesPer100g: 155,
      category: 'بروتين',
      createdAt: DateTime.now(),
    ),
    
    // Dairy
    FoodModel(
      id: '9',
      name: 'حليب كامل الدسم',
      nameEn: 'Whole Milk',
      caloriesPer100g: 61,
      category: 'ألبان',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '10',
      name: 'جبن أبيض',
      nameEn: 'White Cheese',
      caloriesPer100g: 264,
      category: 'ألبان',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '11',
      name: 'زبادي طبيعي',
      nameEn: 'Plain Yogurt',
      caloriesPer100g: 59,
      category: 'ألبان',
      createdAt: DateTime.now(),
    ),
    
    // Fruits
    FoodModel(
      id: '12',
      name: 'تفاح',
      nameEn: 'Apple',
      caloriesPer100g: 52,
      category: 'فواكه',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '13',
      name: 'موز',
      nameEn: 'Banana',
      caloriesPer100g: 89,
      category: 'فواكه',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '14',
      name: 'برتقال',
      nameEn: 'Orange',
      caloriesPer100g: 47,
      category: 'فواكه',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '15',
      name: 'عنب',
      nameEn: 'Grapes',
      caloriesPer100g: 62,
      category: 'فواكه',
      createdAt: DateTime.now(),
    ),
    
    // Vegetables
    FoodModel(
      id: '16',
      name: 'طماطم',
      nameEn: 'Tomato',
      caloriesPer100g: 18,
      category: 'خضروات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '17',
      name: 'خيار',
      nameEn: 'Cucumber',
      caloriesPer100g: 16,
      category: 'خضروات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '18',
      name: 'جزر',
      nameEn: 'Carrot',
      caloriesPer100g: 41,
      category: 'خضروات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '19',
      name: 'بطاطس مسلوقة',
      nameEn: 'Boiled Potato',
      caloriesPer100g: 87,
      category: 'خضروات',
      createdAt: DateTime.now(),
    ),
    
    // Nuts & Seeds
    FoodModel(
      id: '20',
      name: 'لوز',
      nameEn: 'Almonds',
      caloriesPer100g: 579,
      category: 'مكسرات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '21',
      name: 'جوز',
      nameEn: 'Walnuts',
      caloriesPer100g: 654,
      category: 'مكسرات',
      createdAt: DateTime.now(),
    ),
    
    // Beverages
    FoodModel(
      id: '22',
      name: 'عصير برتقال طبيعي',
      nameEn: 'Fresh Orange Juice',
      caloriesPer100g: 45,
      category: 'مشروبات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '23',
      name: 'شاي بدون سكر',
      nameEn: 'Tea without Sugar',
      caloriesPer100g: 1,
      category: 'مشروبات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '24',
      name: 'قهوة بدون سكر',
      nameEn: 'Coffee without Sugar',
      caloriesPer100g: 2,
      category: 'مشروبات',
      createdAt: DateTime.now(),
    ),
    
    // Sweets & Desserts
    FoodModel(
      id: '25',
      name: 'شوكولاتة داكنة',
      nameEn: 'Dark Chocolate',
      caloriesPer100g: 546,
      category: 'حلويات',
      createdAt: DateTime.now(),
    ),
    FoodModel(
      id: '26',
      name: 'آيس كريم',
      nameEn: 'Ice Cream',
      caloriesPer100g: 207,
      category: 'حلويات',
      createdAt: DateTime.now(),
    ),
  ];

  static List<String> get categories => [
    'حبوب',
    'بروتين',
    'ألبان',
    'فواكه',
    'خضروات',
    'مكسرات',
    'مشروبات',
    'حلويات',
    'أخرى',
  ];
}

