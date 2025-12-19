class BodyCompositionModel {
  final String id;
  final double weight;
  final double bmi;
  final double muscleRate;
  final double fatFreeBodyWeight;
  final double bodyFat;
  final double subcutaneousFat;
  final double visceralFat;
  final double bodyWater;
  final double skeletalMuscle;
  final double muscleMass;
  final double boneMass;
  final double protein;
  final DateTime measurementDate;

  // Status categories for each metric
  final String weightStatus;
  final String bmiStatus;
  final String muscleRateStatus;
  final String fatFreeBodyWeightStatus;
  final String bodyFatStatus;
  final String subcutaneousFatStatus;
  final String visceralFatStatus;
  final String bodyWaterStatus;
  final String skeletalMuscleStatus;
  final String muscleMassStatus;
  final String boneMassStatus;
  final String proteinStatus;

  BodyCompositionModel({
    required this.id,
    required this.weight,
    required this.bmi,
    required this.muscleRate,
    required this.fatFreeBodyWeight,
    required this.bodyFat,
    required this.subcutaneousFat,
    required this.visceralFat,
    required this.bodyWater,
    required this.skeletalMuscle,
    required this.muscleMass,
    required this.boneMass,
    required this.protein,
    required this.measurementDate,
    required this.weightStatus,
    required this.bmiStatus,
    required this.muscleRateStatus,
    required this.fatFreeBodyWeightStatus,
    required this.bodyFatStatus,
    required this.subcutaneousFatStatus,
    required this.visceralFatStatus,
    required this.bodyWaterStatus,
    required this.skeletalMuscleStatus,
    required this.muscleMassStatus,
    required this.boneMassStatus,
    required this.proteinStatus,
  });

  // Factory constructor for JSON deserialization (for backend integration)
  factory BodyCompositionModel.fromJson(Map<String, dynamic> json) {
    return BodyCompositionModel(
      id: json['id'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      bmi: (json['bmi'] ?? 0).toDouble(),
      muscleRate: (json['muscleRate'] ?? 0).toDouble(),
      fatFreeBodyWeight: (json['fatFreeBodyWeight'] ?? 0).toDouble(),
      bodyFat: (json['bodyFat'] ?? 0).toDouble(),
      subcutaneousFat: (json['subcutaneousFat'] ?? 0).toDouble(),
      visceralFat: (json['visceralFat'] ?? 0).toDouble(),
      bodyWater: (json['bodyWater'] ?? 0).toDouble(),
      skeletalMuscle: (json['skeletalMuscle'] ?? 0).toDouble(),
      muscleMass: (json['muscleMass'] ?? 0).toDouble(),
      boneMass: (json['boneMass'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      measurementDate: json['measurementDate'] != null
          ? DateTime.parse(json['measurementDate'])
          : DateTime.now(),
      weightStatus: json['weightStatus'] ?? 'Standard',
      bmiStatus: json['bmiStatus'] ?? 'Standard',
      muscleRateStatus: json['muscleRateStatus'] ?? 'Standard',
      fatFreeBodyWeightStatus: json['fatFreeBodyWeightStatus'] ?? 'Standard',
      bodyFatStatus: json['bodyFatStatus'] ?? 'Standard',
      subcutaneousFatStatus: json['subcutaneousFatStatus'] ?? 'Standard',
      visceralFatStatus: json['visceralFatStatus'] ?? 'Standard',
      bodyWaterStatus: json['bodyWaterStatus'] ?? 'Standard',
      skeletalMuscleStatus: json['skeletalMuscleStatus'] ?? 'Standard',
      muscleMassStatus: json['muscleMassStatus'] ?? 'Standard',
      boneMassStatus: json['boneMassStatus'] ?? 'Standard',
      proteinStatus: json['proteinStatus'] ?? 'Standard',
    );
  }

  // Convert to JSON for backend integration
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'bmi': bmi,
      'muscleRate': muscleRate,
      'fatFreeBodyWeight': fatFreeBodyWeight,
      'bodyFat': bodyFat,
      'subcutaneousFat': subcutaneousFat,
      'visceralFat': visceralFat,
      'bodyWater': bodyWater,
      'skeletalMuscle': skeletalMuscle,
      'muscleMass': muscleMass,
      'boneMass': boneMass,
      'protein': protein,
      'measurementDate': measurementDate.toIso8601String(),
      'weightStatus': weightStatus,
      'bmiStatus': bmiStatus,
      'muscleRateStatus': muscleRateStatus,
      'fatFreeBodyWeightStatus': fatFreeBodyWeightStatus,
      'bodyFatStatus': bodyFatStatus,
      'subcutaneousFatStatus': subcutaneousFatStatus,
      'visceralFatStatus': visceralFatStatus,
      'bodyWaterStatus': bodyWaterStatus,
      'skeletalMuscleStatus': skeletalMuscleStatus,
      'muscleMassStatus': muscleMassStatus,
      'boneMassStatus': boneMassStatus,
      'proteinStatus': proteinStatus,
    };
  }

  // Copy with method for updates
  BodyCompositionModel copyWith({
    String? id,
    double? weight,
    double? bmi,
    double? muscleRate,
    double? fatFreeBodyWeight,
    double? bodyFat,
    double? subcutaneousFat,
    double? visceralFat,
    double? bodyWater,
    double? skeletalMuscle,
    double? muscleMass,
    double? boneMass,
    double? protein,
    DateTime? measurementDate,
    String? weightStatus,
    String? bmiStatus,
    String? muscleRateStatus,
    String? fatFreeBodyWeightStatus,
    String? bodyFatStatus,
    String? subcutaneousFatStatus,
    String? visceralFatStatus,
    String? bodyWaterStatus,
    String? skeletalMuscleStatus,
    String? muscleMassStatus,
    String? boneMassStatus,
    String? proteinStatus,
  }) {
    return BodyCompositionModel(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      muscleRate: muscleRate ?? this.muscleRate,
      fatFreeBodyWeight: fatFreeBodyWeight ?? this.fatFreeBodyWeight,
      bodyFat: bodyFat ?? this.bodyFat,
      subcutaneousFat: subcutaneousFat ?? this.subcutaneousFat,
      visceralFat: visceralFat ?? this.visceralFat,
      bodyWater: bodyWater ?? this.bodyWater,
      skeletalMuscle: skeletalMuscle ?? this.skeletalMuscle,
      muscleMass: muscleMass ?? this.muscleMass,
      boneMass: boneMass ?? this.boneMass,
      protein: protein ?? this.protein,
      measurementDate: measurementDate ?? this.measurementDate,
      weightStatus: weightStatus ?? this.weightStatus,
      bmiStatus: bmiStatus ?? this.bmiStatus,
      muscleRateStatus: muscleRateStatus ?? this.muscleRateStatus,
      fatFreeBodyWeightStatus:
          fatFreeBodyWeightStatus ?? this.fatFreeBodyWeightStatus,
      bodyFatStatus: bodyFatStatus ?? this.bodyFatStatus,
      subcutaneousFatStatus:
          subcutaneousFatStatus ?? this.subcutaneousFatStatus,
      visceralFatStatus: visceralFatStatus ?? this.visceralFatStatus,
      bodyWaterStatus: bodyWaterStatus ?? this.bodyWaterStatus,
      skeletalMuscleStatus: skeletalMuscleStatus ?? this.skeletalMuscleStatus,
      muscleMassStatus: muscleMassStatus ?? this.muscleMassStatus,
      boneMassStatus: boneMassStatus ?? this.boneMassStatus,
      proteinStatus: proteinStatus ?? this.proteinStatus,
    );
  }
}
