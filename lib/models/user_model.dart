class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final double? weight;
  final double? height;
  final int? age;
  final String? gender;
  final double? activityLevel;
  final int? dailyCalorieGoal;
  final int? dailyStepGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.activityLevel,
    this.dailyCalorieGoal,
    this.dailyStepGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      age: json['age'],
      gender: json['gender'],
      activityLevel: json['activityLevel']?.toDouble(),
      dailyCalorieGoal: json['dailyCalorieGoal'],
      dailyStepGoal: json['dailyStepGoal'] ?? 10000,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyStepGoal': dailyStepGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    double? weight,
    double? height,
    int? age,
    String? gender,
    double? activityLevel,
    int? dailyCalorieGoal,
    int? dailyStepGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate BMR (Basal Metabolic Rate)
  double? calculateBMR() {
    if (weight == null || height == null || age == null || gender == null) {
      return null;
    }

    if (gender == 'male') {
      return 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      return 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double? calculateTDEE() {
    final bmr = calculateBMR();
    if (bmr == null || activityLevel == null) return null;
    return bmr * activityLevel!;
  }

  // Calculate BMI
  double? calculateBMI() {
    if (weight == null || height == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  // Get BMI Category
  String getBMICategory() {
    final bmi = calculateBMI();
    if (bmi == null) return 'غير محدد';
    
    if (bmi < 18.5) return 'نقص في الوزن';
    if (bmi < 25) return 'وزن طبيعي';
    if (bmi < 30) return 'زيادة في الوزن';
    return 'سمنة';
  }
}

