class SleepData {
  final int? id;
  final String date; // Format: 'YYYY-MM-DD'
  final double hours;
  final int quality; // 0-100
  final double deepSleep;
  final String bedtime; // Format: 'HH:MM'
  final String wakeTime; // Format: 'HH:MM'
  final DateTime createdAt;

  SleepData({
    this.id,
    required this.date,
    required this.hours,
    required this.quality,
    required this.deepSleep,
    required this.bedtime,
    required this.wakeTime,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'hours': hours,
      'quality': quality,
      'deepSleep': deepSleep,
      'bedtime': bedtime,
      'wakeTime': wakeTime,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SleepData.fromMap(Map<String, dynamic> map) {
    return SleepData(
      id: map['id']?.toInt(),
      date: map['date'] ?? '',
      hours: map['hours']?.toDouble() ?? 0.0,
      quality: map['quality']?.toInt() ?? 0,
      deepSleep: map['deepSleep']?.toDouble() ?? 0.0,
      bedtime: map['bedtime'] ?? '',
      wakeTime: map['wakeTime'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  SleepData copyWith({
    int? id,
    String? date,
    double? hours,
    int? quality,
    double? deepSleep,
    String? bedtime,
    String? wakeTime,
    DateTime? createdAt,
  }) {
    return SleepData(
      id: id ?? this.id,
      date: date ?? this.date,
      hours: hours ?? this.hours,
      quality: quality ?? this.quality,
      deepSleep: deepSleep ?? this.deepSleep,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SleepSchedule {
  final int? id;
  final String bedtime; // Format: 'HH:MM'
  final String wakeTime; // Format: 'HH:MM'
  final int targetHours;
  final int targetMinutes;
  final DateTime updatedAt;

  SleepSchedule({
    this.id,
    required this.bedtime,
    required this.wakeTime,
    required this.targetHours,
    required this.targetMinutes,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bedtime': bedtime,
      'wakeTime': wakeTime,
      'targetHours': targetHours,
      'targetMinutes': targetMinutes,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory SleepSchedule.fromMap(Map<String, dynamic> map) {
    return SleepSchedule(
      id: map['id']?.toInt(),
      bedtime: map['bedtime'] ?? '',
      wakeTime: map['wakeTime'] ?? '',
      targetHours: map['targetHours']?.toInt() ?? 8,
      targetMinutes: map['targetMinutes']?.toInt() ?? 0,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  SleepSchedule copyWith({
    int? id,
    String? bedtime,
    String? wakeTime,
    int? targetHours,
    int? targetMinutes,
    DateTime? updatedAt,
  }) {
    return SleepSchedule(
      id: id ?? this.id,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
      targetHours: targetHours ?? this.targetHours,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
