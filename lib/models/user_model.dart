class UserProfile {
  final String id;
  final String? gymCode;
  final String? gymId;
  final DateTime? joinDate;
  final int? membershipDuration;
  final DateTime? membershipEndDate;
  final double? membershipFees;
  final DateTime? membershipStartDate;
  final String name;
  final String phone;
  final double? weight; // Weight in kg
  final double? height; // Height in cm
  final String? profileImage; // S3 key for profile image
  final DateTime? birthday; // Birthday date
  final String? gender; // Gender (e.g., 'Male', 'Female', 'Other')
  final String? dietPreference; // Diet preference (e.g., 'veg', 'non-veg')
  final String? lifestyle; // Lifestyle (e.g., 'sedentary', 'active', 'very-active')
  final String? goal; // Goal (e.g., 'weight-loss', 'muscle-gain', 'maintenance')

  UserProfile({
    required this.id,
    this.gymCode,
    this.gymId,
    this.joinDate,
    this.membershipDuration,
    this.membershipEndDate,
    this.membershipFees,
    this.membershipStartDate,
    required this.name,
    required this.phone,
    this.weight,
    this.height,
    this.profileImage,
    this.birthday,
    this.gender,
    this.dietPreference,
    this.lifestyle,
    this.goal,
  });

  // Helper function to normalize date to local midnight (date-only, no time component)
  // This prevents timezone issues when dates are stored/loaded
  // Creates a date in local timezone at midnight
  static DateTime _normalizeToLocalMidnight(DateTime date) {
    // If date is already in local timezone, extract components directly
    // Otherwise convert to local first
    final local = date.isUtc ? date.toLocal() : date;
    // Create new DateTime in local timezone at midnight
    return DateTime(local.year, local.month, local.day);
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Parse birthday and normalize to local midnight to avoid timezone issues
    DateTime? normalizedBirthday;
    if (json['birthday'] != null) {
      final birthdayValue = json['birthday'];
      DateTime parsedDate;
      
      // Handle both ISO8601 format and date-only format (YYYY-MM-DD)
      if (birthdayValue is String) {
        if (birthdayValue.contains('T') || birthdayValue.contains(' ')) {
          // ISO8601 format with time
          parsedDate = DateTime.parse(birthdayValue);
        } else {
          // Date-only format (YYYY-MM-DD) - parse as local date at midnight
          final parts = birthdayValue.split('-');
          if (parts.length == 3) {
            parsedDate = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          } else {
            parsedDate = DateTime.parse(birthdayValue);
          }
        }
      } else {
        parsedDate = DateTime.parse(birthdayValue.toString());
      }
      
      normalizedBirthday = _normalizeToLocalMidnight(parsedDate);
    }

    return UserProfile(
      id: json['_id'] ?? '',
      gymCode: json['gymCode'],
      gymId: json['gymId'],
      joinDate:
          json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
      membershipDuration: json['membershipDuration'],
      membershipEndDate: json['membershipEndDate'] != null
          ? DateTime.parse(json['membershipEndDate'])
          : null,
      membershipFees: json['membershipFees']?.toDouble(),
      membershipStartDate: json['membershipStartDate'] != null
          ? DateTime.parse(json['membershipStartDate'])
          : null,
      name: json['name'] ?? '',
      phone: json['phone']?.toString() ?? '', // Handle mixed type from backend
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      profileImage: json['profileImage'],
      birthday: normalizedBirthday,
      gender: json['gender'],
      dietPreference: json['dietPreference'],
      lifestyle: json['lifestyle'],
      goal: json['goal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'gymCode': gymCode,
      'gymId': gymId,
      'joinDate': joinDate?.toIso8601String(),
      'membershipDuration': membershipDuration,
      'membershipEndDate': membershipEndDate?.toIso8601String(),
      'membershipFees': membershipFees,
      'membershipStartDate': membershipStartDate?.toIso8601String(),
      'name': name,
      'phone': phone,
      'weight': weight,
      'height': height,
      'profileImage': profileImage,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'dietPreference': dietPreference,
      'lifestyle': lifestyle,
      'goal': goal,
    };
  }

  // Helper method to calculate BMI if both weight and height are available
  double? get bmi {
    if (weight != null && height != null && height! > 0) {
      final heightInMeters = height! / 100; // Convert cm to meters
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  // Helper method to get BMI category
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25.0) return 'Normal weight';
    if (bmiValue < 30.0) return 'Overweight';
    return 'Obese';
  }

  // Helper method to get profile image URL from S3 key
  String? get profileImageUrl {
    if (profileImage != null && profileImage!.isNotEmpty) {
      return 'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$profileImage';
    }
    return null;
  }
}
