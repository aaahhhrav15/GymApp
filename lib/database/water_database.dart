// lib/database/water_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WaterDatabase {
  static Database? _database;
  static const String _dbName = 'water_tracker.db';
  static const int _dbVersion = 1;

  // Table names
  static const String _waterIntakeTable = 'water_intake';
  static const String _dailySummaryTable = 'daily_summary';
  static const String _settingsTable = 'settings';

  // Water intake table columns
  static const String _intakeId = 'id';
  static const String _intakeAmount = 'amount';
  static const String _intakeType = 'type';
  static const String _intakeTime = 'time';
  static const String _intakeTimestamp = 'timestamp';
  static const String _intakeDate = 'date';

  // Daily summary table columns
  static const String _summaryId = 'id';
  static const String _summaryDate = 'date';
  static const String _summaryTotalIntake = 'total_intake';
  static const String _summaryGoal = 'goal';
  static const String _summaryGoalAchieved = 'goal_achieved';
  static const String _summaryTotalDrinks = 'total_drinks';

  // Settings table columns
  static const String _settingKey = 'setting_key';
  static const String _settingValue = 'setting_value';

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  // Create database tables
  static Future<void> _createDatabase(Database db, int version) async {
    // Create water intake table
    await db.execute('''
      CREATE TABLE $_waterIntakeTable (
        $_intakeId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_intakeAmount INTEGER NOT NULL,
        $_intakeType TEXT NOT NULL,
        $_intakeTime TEXT NOT NULL,
        $_intakeTimestamp TEXT NOT NULL,
        $_intakeDate TEXT NOT NULL
      )
    ''');

    // Create daily summary table
    await db.execute('''
      CREATE TABLE $_dailySummaryTable (
        $_summaryId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_summaryDate TEXT UNIQUE NOT NULL,
        $_summaryTotalIntake INTEGER NOT NULL DEFAULT 0,
        $_summaryGoal INTEGER NOT NULL,
        $_summaryGoalAchieved INTEGER NOT NULL DEFAULT 0,
        $_summaryTotalDrinks INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create settings table
    await db.execute('''
      CREATE TABLE $_settingsTable (
        $_settingKey TEXT PRIMARY KEY,
        $_settingValue TEXT NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert(
        _settingsTable, {_settingKey: 'daily_goal', _settingValue: '2000'});

    await db.insert(_settingsTable,
        {_settingKey: 'reminder_enabled', _settingValue: 'true'});

    await db.insert(_settingsTable,
        {_settingKey: 'reminder_interval_minutes', _settingValue: '60'});
  }

  // Upgrade database
  static Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    // For now, just recreate tables
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $_waterIntakeTable');
      await db.execute('DROP TABLE IF EXISTS $_dailySummaryTable');
      await db.execute('DROP TABLE IF EXISTS $_settingsTable');
      await _createDatabase(db, newVersion);
    }
  }

  // Add water intake
  static Future<int> addWaterIntake({
    required int amount,
    required String type,
    required DateTime timestamp,
  }) async {
    final db = await database;
    final dateStr = _formatDate(timestamp);
    final timeStr = _formatTime(timestamp);

    return await db.insert(_waterIntakeTable, {
      _intakeAmount: amount,
      _intakeType: type,
      _intakeTime: timeStr,
      _intakeTimestamp: timestamp.toIso8601String(),
      _intakeDate: dateStr,
    });
  }

  // Remove water intake
  static Future<bool> removeWaterIntake(int intakeId) async {
    final db = await database;
    final result = await db.delete(
      _waterIntakeTable,
      where: '$_intakeId = ?',
      whereArgs: [intakeId],
    );
    return result > 0;
  }

  // Update water intake
  static Future<bool> updateWaterIntake({
    required int intakeId,
    required int amount,
    required String type,
  }) async {
    final db = await database;
    final result = await db.update(
      _waterIntakeTable,
      {
        _intakeAmount: amount,
        _intakeType: type,
      },
      where: '$_intakeId = ?',
      whereArgs: [intakeId],
    );
    return result > 0;
  }

  // Get today's water intake
  static Future<List<Map<String, dynamic>>> getTodaysIntake() async {
    final db = await database;
    final today = _formatDate(DateTime.now());

    return await db.query(
      _waterIntakeTable,
      where: '$_intakeDate = ?',
      whereArgs: [today],
      orderBy: '$_intakeTimestamp DESC',
    );
  }

  // Get water intake by date range
  static Future<List<Map<String, dynamic>>> getIntakeByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate);

    return await db.query(
      _waterIntakeTable,
      where: '$_intakeDate BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: '$_intakeTimestamp DESC',
    );
  }

  // Get intake for a specific date
  static Future<List<Map<String, dynamic>>> getIntakeForDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDate(date);

    return await db.query(
      _waterIntakeTable,
      where: '$_intakeDate = ?',
      whereArgs: [dateStr],
      orderBy: '$_intakeTimestamp DESC',
    );
  }

  // Get today's total intake
  static Future<int> getTodaysTotalIntake() async {
    final db = await database;
    final today = _formatDate(DateTime.now());

    final result = await db.rawQuery('''
      SELECT SUM($_intakeAmount) as total
      FROM $_waterIntakeTable
      WHERE $_intakeDate = ?
    ''', [today]);

    return result.first['total'] as int? ?? 0;
  }

  // Update or insert daily summary
  static Future<void> updateDailySummary(DateTime date, int goal) async {
    final db = await database;
    final dateStr = _formatDate(date);
    final totalIntake = await getTotalIntakeForDate(date);
    final totalDrinks = await getTotalDrinksForDate(date);
    final goalAchieved = totalIntake >= goal ? 1 : 0;

    await db.insert(
      _dailySummaryTable,
      {
        _summaryDate: dateStr,
        _summaryTotalIntake: totalIntake,
        _summaryGoal: goal,
        _summaryGoalAchieved: goalAchieved,
        _summaryTotalDrinks: totalDrinks,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get total intake for a specific date
  static Future<int> getTotalIntakeForDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDate(date);

    final result = await db.rawQuery('''
      SELECT SUM($_intakeAmount) as total
      FROM $_waterIntakeTable
      WHERE $_intakeDate = ?
    ''', [dateStr]);

    return result.first['total'] as int? ?? 0;
  }

  // Get total drinks count for a specific date
  static Future<int> getTotalDrinksForDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDate(date);

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM $_waterIntakeTable
      WHERE $_intakeDate = ?
    ''', [dateStr]);

    return result.first['count'] as int? ?? 0;
  }

  // Get daily summaries for date range
  static Future<List<Map<String, dynamic>>> getDailySummaries(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final startStr = _formatDate(startDate);
    final endStr = _formatDate(endDate);

    return await db.query(
      _dailySummaryTable,
      where: '$_summaryDate BETWEEN ? AND ?',
      whereArgs: [startStr, endStr],
      orderBy: '$_summaryDate DESC',
    );
  }

  // Get water statistics
  static Future<Map<String, dynamic>> getWaterStats() async {
    final db = await database;
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final thirtyDaysAgoStr = _formatDate(thirtyDaysAgo);

    // Get goal achievement streak
    final streakResult = await db.rawQuery('''
      SELECT COUNT(*) as streak_days
      FROM $_dailySummaryTable
      WHERE $_summaryDate >= ? AND $_summaryGoalAchieved = 1
      ORDER BY $_summaryDate DESC
    ''', [thirtyDaysAgoStr]);

    // Get total goal achieved days
    final goalAchievedResult = await db.rawQuery('''
      SELECT COUNT(*) as goal_achieved_days
      FROM $_dailySummaryTable
      WHERE $_summaryDate >= ? AND $_summaryGoalAchieved = 1
    ''', [thirtyDaysAgoStr]);

    // Get total days tracked (all days in last 30 days)
    final totalDaysResult = await db.rawQuery('''
      SELECT COUNT(*) as total_days
      FROM $_dailySummaryTable
      WHERE $_summaryDate >= ?
    ''', [thirtyDaysAgoStr]);

    // Get average daily intake
    final avgResult = await db.rawQuery('''
      SELECT AVG($_summaryTotalIntake) as avg_intake
      FROM $_dailySummaryTable
      WHERE $_summaryDate >= ?
    ''', [thirtyDaysAgoStr]);

    // Get this week's total
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekAgoStr = _formatDate(weekAgo);
    final todayStr = _formatDate(DateTime.now());
    
    // Check if today's summary exists in the database
    final todaySummaryResult = await db.query(
      _dailySummaryTable,
      where: '$_summaryDate = ?',
      whereArgs: [todayStr],
    );
    final todaySummaryExists = todaySummaryResult.isNotEmpty;
    
    final weekResult = await db.rawQuery('''
      SELECT SUM($_summaryTotalIntake) as week_total
      FROM $_dailySummaryTable
      WHERE $_summaryDate >= ? AND $_summaryDate < ?
    ''', [weekAgoStr, todayStr]);

    // Get today's stats
    final todayTotal = await getTodaysTotalIntake();
    final dailyGoal = await getDailyGoal();

    // Safely extract values with null handling
    final streakDays = streakResult.isNotEmpty
        ? (streakResult.first['streak_days'] as int? ?? 0)
        : 0;
    
    final goalAchievedDays = goalAchievedResult.isNotEmpty
        ? (goalAchievedResult.first['goal_achieved_days'] as int? ?? 0)
        : 0;
    
    final totalDaysTracked = totalDaysResult.isNotEmpty
        ? (totalDaysResult.first['total_days'] as int? ?? 0)
        : 0;
    
    final avgIntake = avgResult.isNotEmpty
        ? ((avgResult.first['avg_intake'] as num?)?.toDouble() ?? 0.0).round()
        : 0;
    
    // Calculate week total: sum of past 7 days (excluding today) + today's total
    final weekTotalFromDB = weekResult.isNotEmpty
        ? ((weekResult.first['week_total'] as num?)?.toInt() ?? 0)
        : 0;
    
    // Add today's total: use summary value if it exists, otherwise use current intake
    final todayValue = todaySummaryExists && todaySummaryResult.first[_summaryTotalIntake] != null
        ? (todaySummaryResult.first[_summaryTotalIntake] as int? ?? 0)
        : todayTotal;
    
    final weekTotal = weekTotalFromDB + todayValue;

    return {
      'streakDays': streakDays,
      'goalAchievedDays': goalAchievedDays,
      'totalDaysTracked': totalDaysTracked > 0 ? totalDaysTracked : 1, // At least 1 for today
      'averageDailyIntake': avgIntake,
      'totalIntakeThisWeek': weekTotal,
      'todayIntake': todayTotal,
      'dailyGoal': dailyGoal,
      'completionPercentage': dailyGoal > 0
          ? ((todayTotal / dailyGoal) * 100).clamp(0, 100).round()
          : 0,
    };
  }

  // Settings methods
  static Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      _settingsTable,
      {_settingKey: key, _settingValue: value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      _settingsTable,
      where: '$_settingKey = ?',
      whereArgs: [key],
    );

    if (result.isNotEmpty) {
      return result.first[_settingValue] as String;
    }
    return null;
  }

  // Daily goal methods
  static Future<void> setDailyGoal(int goal) async {
    await setSetting('daily_goal', goal.toString());
  }

  static Future<int> getDailyGoal() async {
    final goalStr = await getSetting('daily_goal');
    return int.tryParse(goalStr ?? '2000') ?? 2000;
  }

  // Notification settings
  static Future<void> setReminderEnabled(bool enabled) async {
    await setSetting('reminder_enabled', enabled.toString());
  }

  static Future<bool> getReminderEnabled() async {
    final enabledStr = await getSetting('reminder_enabled');
    return enabledStr?.toLowerCase() == 'true';
  }

  static Future<void> setReminderInterval(int minutes) async {
    await setSetting('reminder_interval_minutes', minutes.toString());
  }

  static Future<int> getReminderInterval() async {
    final intervalStr = await getSetting('reminder_interval_minutes');
    return int.tryParse(intervalStr ?? '60') ?? 60;
  }

  // Clear all data for testing
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_waterIntakeTable);
    await db.delete(_dailySummaryTable);
  }

  // Reset today's data
  static Future<void> resetTodaysData() async {
    final db = await database;
    final today = _formatDate(DateTime.now());
    await db.delete(
      _waterIntakeTable,
      where: '$_intakeDate = ?',
      whereArgs: [today],
    );
  }

  // Helper methods
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Close database
  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
