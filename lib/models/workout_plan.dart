class WorkoutPlan {
  final String id;
  final String gymId;
  final String memberId;
  final String memberName;
  final String planId;
  final DateTime startDate;
  final String status;
  final Plan plan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;

  WorkoutPlan({
    required this.id,
    required this.gymId,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.startDate,
    required this.status,
    required this.plan,
    required this.createdAt,
    required this.updatedAt,
    this.notes = '',
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['_id'] ?? '',
      gymId: json['gymId'] ?? '',
      memberId: json['memberId'] ?? '',
      memberName: json['memberName'] ?? '',
      planId: json['planId'] ?? '',
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      plan: Plan.fromJson(json['plan'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'gymId': gymId,
      'memberId': memberId,
      'memberName': memberName,
      'planId': planId,
      'startDate': startDate.toIso8601String(),
      'status': status,
      'plan': plan.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

class Plan {
  final String name;
  final String goal;
  final String level;
  final int duration;
  final List<Week> weeks;

  Plan({
    required this.name,
    required this.goal,
    required this.level,
    required this.duration,
    required this.weeks,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      name: json['name'] ?? '',
      goal: json['goal'] ?? '',
      level: json['level'] ?? '',
      duration: json['duration'] ?? 0,
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((w) => Week.fromJson(w))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goal': goal,
      'level': level,
      'duration': duration,
      'weeks': weeks.map((w) => w.toJson()).toList(),
    };
  }
}

class Week {
  final int weekNumber;
  final List<Day> days;

  Week({
    required this.weekNumber,
    required this.days,
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      weekNumber: json['weekNumber'] ?? 0,
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => Day.fromJson(d))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}

class Day {
  final int dayNumber;
  final String muscleGroups;
  final List<Exercise> exercises;

  Day({
    required this.dayNumber,
    this.muscleGroups = '',
    required this.exercises,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      dayNumber: json['dayNumber'] ?? 0,
      muscleGroups: json['muscleGroups'] ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'muscleGroups': muscleGroups,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class Exercise {
  final String name;
  final String type;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String instructions;
  final int sets;
  final int reps;
  final int? weight;
  final int? duration;
  final int? restTime;
  final String? notes;

  Exercise({
    required this.name,
    required this.type,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.instructions,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.restTime,
    this.notes,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      muscle: json['muscle'] ?? '',
      equipment: json['equipment'] ?? '',
      difficulty: json['difficulty'] ?? '',
      instructions: json['instructions'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight'],
      duration: json['duration'],
      restTime: json['restTime'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'muscle': muscle,
      'equipment': equipment,
      'difficulty': difficulty,
      'instructions': instructions,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'restTime': restTime,
      'notes': notes,
    };
  }
}

class WorkoutDay {
  final String assignedId;
  final String planId;
  final PlanMeta planMeta;
  final int weekNumber;
  final int dayNumber;
  final String muscleGroups;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.assignedId,
    required this.planId,
    required this.planMeta,
    required this.weekNumber,
    required this.dayNumber,
    this.muscleGroups = '',
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      assignedId: json['assignedId'] ?? '',
      planId: json['planId'] ?? '',
      planMeta: PlanMeta.fromJson(json['planMeta'] ?? {}),
      weekNumber: json['weekNumber'] ?? 0,
      dayNumber: json['dayNumber'] ?? 0,
      muscleGroups: json['muscleGroups'] ?? '',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class PlanMeta {
  final String name;
  final String goal;
  final String level;
  final int duration;

  PlanMeta({
    required this.name,
    required this.goal,
    required this.level,
    required this.duration,
  });

  factory PlanMeta.fromJson(Map<String, dynamic> json) {
    return PlanMeta(
      name: json['name'] ?? '',
      goal: json['goal'] ?? '',
      level: json['level'] ?? '',
      duration: json['duration'] ?? 0,
    );
  }
}
