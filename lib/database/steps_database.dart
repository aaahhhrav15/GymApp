// lib/database/steps_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class StepsDatabase {
  static Database? _database;
  static const String _tableName = 'weekly_steps';
  static const String _dailyHistoryTableName = 'daily_steps_history';

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'steps_database.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version for migration
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    // Weekly steps table (for backward compatibility)
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_name TEXT NOT NULL UNIQUE,
        step_count INTEGER NOT NULL,
        week_start_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Daily history table with hourly breakdown
    await db.execute('''
      CREATE TABLE $_dailyHistoryTableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        total_steps INTEGER NOT NULL DEFAULT 0,
        hourly_steps TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_date ON $_dailyHistoryTableName(date)
    ''');
  }

  // Handle database upgrade
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add daily history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_dailyHistoryTableName (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL UNIQUE,
          total_steps INTEGER NOT NULL DEFAULT 0,
          hourly_steps TEXT NOT NULL DEFAULT '[]',
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_date ON $_dailyHistoryTableName(date)
      ''');
    }
  }

  // Get current week start date (Monday of current week)
  static String _getCurrentWeekStart() {
    DateTime now = DateTime.now();
    int daysFromMonday = now.weekday - 1; // Monday = 1, so subtract 1
    DateTime monday = now.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day)
        .toIso8601String()
        .split('T')[0];
  }

  // Check if we need to reset for new week
  static Future<void> checkAndResetWeek() async {
    final db = await database;
    String currentWeekStart = _getCurrentWeekStart();

    // Check if we have data for current week
    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'week_start_date = ?',
      whereArgs: [currentWeekStart],
      limit: 1,
    );

    // If no data for current week, delete old week data
    if (result.isEmpty) {
      await db.delete(_tableName);
      print(
          'Cleared old week data, starting fresh week from $currentWeekStart');
    }
  }

  // Insert or update step count for a day
  static Future<void> insertOrUpdateSteps(String dayName, int stepCount) async {
    final db = await database;
    String currentWeekStart = _getCurrentWeekStart();
    String currentTime = DateTime.now().toIso8601String();

    await db.insert(
      _tableName,
      {
        'day_name': dayName,
        'step_count': stepCount,
        'week_start_date': currentWeekStart,
        'created_at': currentTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Saved steps for $dayName: $stepCount');
  }

  // Get step count for a specific day
  static Future<int> getStepsForDay(String dayName) async {
    final db = await database;
    String currentWeekStart = _getCurrentWeekStart();

    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'day_name = ? AND week_start_date = ?',
      whereArgs: [dayName, currentWeekStart],
    );

    if (result.isNotEmpty) {
      return result.first['step_count'] as int;
    }
    return 0; // Return 0 if no data found
  }

  // Get all weekly steps data
  static Future<Map<String, int>> getWeeklySteps() async {
    final db = await database;
    String currentWeekStart = _getCurrentWeekStart();

    List<Map<String, dynamic>> result = await db.query(
      _tableName,
      where: 'week_start_date = ?',
      whereArgs: [currentWeekStart],
    );

    Map<String, int> weeklySteps = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (var row in result) {
      String dayName = row['day_name'] as String;
      int stepCount = row['step_count'] as int;
      weeklySteps[dayName] = stepCount;
    }

    return weeklySteps;
  }

  // Get all data for debugging
  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query(_tableName);
  }

  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_tableName);
    await db.delete(_dailyHistoryTableName);
    print('Cleared all steps data');
  }

  // ========== Daily History Methods (30-day tracking) ==========

  // Get today's date string (YYYY-MM-DD)
  static String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Get date string for a specific date
  static String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Insert or update daily steps with hourly breakdown
  static Future<void> insertOrUpdateDailySteps(
    String date,
    int totalSteps,
    List<int> hourlySteps,
  ) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    await db.insert(
      _dailyHistoryTableName,
      {
        'date': date,
        'total_steps': totalSteps,
        'hourly_steps': jsonEncode(hourlySteps),
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('Saved daily steps for $date: $totalSteps steps');
  }

  // Get daily steps for a specific date
  static Future<Map<String, dynamic>?> getDailySteps(String date) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      _dailyHistoryTableName,
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final row = result.first;
      return {
        'date': row['date'] as String,
        'total_steps': row['total_steps'] as int,
        'hourly_steps': jsonDecode(row['hourly_steps'] as String) as List<dynamic>,
      };
    }
    return null;
  }

  // Get hourly steps for a specific date
  static Future<List<int>> getHourlyStepsForDate(String date) async {
    final dailyData = await getDailySteps(date);
    if (dailyData != null) {
      final hourlyList = dailyData['hourly_steps'] as List<dynamic>;
      return hourlyList.map((e) => e as int).toList();
    }
    return List.filled(24, 0);
  }

  // Get last 30 days of step history
  static Future<List<Map<String, dynamic>>> getLast30DaysHistory() async {
    final db = await database;
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));

    List<Map<String, dynamic>> result = await db.query(
      _dailyHistoryTableName,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        _getDateString(thirtyDaysAgo),
        _getDateString(today),
      ],
      orderBy: 'date ASC',
    );

    return result.map((row) {
      return {
        'date': row['date'] as String,
        'total_steps': row['total_steps'] as int,
        'hourly_steps': jsonDecode(row['hourly_steps'] as String) as List<dynamic>,
      };
    }).toList();
  }

  // Maintain 30-day history - remove oldest entries beyond 30 days
  static Future<void> maintain30DayHistory() async {
    final db = await database;
    final today = DateTime.now();
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));

    // Delete entries older than 30 days
    final deleted = await db.delete(
      _dailyHistoryTableName,
      where: 'date < ?',
      whereArgs: [_getDateString(thirtyDaysAgo)],
    );

    if (deleted > 0) {
      print('Removed $deleted old entries from daily history (keeping last 30 days)');
    }
  }

  // Update hourly steps for current hour
  static Future<void> updateCurrentHourSteps(int steps) async {
    final today = _getTodayString();
    final currentHour = DateTime.now().hour;

    // Get existing data
    final existing = await getDailySteps(today);
    List<int> hourlySteps;

    if (existing != null) {
      hourlySteps = (existing['hourly_steps'] as List<dynamic>)
          .map((e) => e as int)
          .toList();
    } else {
      hourlySteps = List.filled(24, 0);
    }

    // Update current hour
    hourlySteps[currentHour] = steps;

    // Calculate total from hourly
    final totalSteps = hourlySteps.reduce((a, b) => a + b);

    // Save updated data
    await insertOrUpdateDailySteps(today, totalSteps, hourlySteps);
  }

  // Add steps to current hour (incremental)
  static Future<void> addStepsToCurrentHour(int additionalSteps) async {
    final today = _getTodayString();
    final currentHour = DateTime.now().hour;

    // Get existing data
    final existing = await getDailySteps(today);
    List<int> hourlySteps;
    int currentTotal;

    if (existing != null) {
      hourlySteps = (existing['hourly_steps'] as List<dynamic>)
          .map((e) => e as int)
          .toList();
      currentTotal = existing['total_steps'] as int;
    } else {
      hourlySteps = List.filled(24, 0);
      currentTotal = 0;
    }

    // Add to current hour
    hourlySteps[currentHour] += additionalSteps;
    currentTotal += additionalSteps;

    // Save updated data
    await insertOrUpdateDailySteps(today, currentTotal, hourlySteps);
  }

  // Get today's steps and hourly breakdown
  static Future<Map<String, dynamic>> getTodaySteps() async {
    final today = _getTodayString();
    final data = await getDailySteps(today);

    if (data != null) {
      return data;
    }

    // Return default if no data
    return {
      'date': today,
      'total_steps': 0,
      'hourly_steps': List.filled(24, 0),
    };
  }
}
