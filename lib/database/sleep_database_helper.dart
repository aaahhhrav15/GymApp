import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sleep_model.dart';

class SleepDatabaseHelper {
  static final SleepDatabaseHelper _instance = SleepDatabaseHelper._internal();
  static Database? _database;

  factory SleepDatabaseHelper() => _instance;

  SleepDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'sleep_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Sleep data table
    await db.execute('''
      CREATE TABLE sleep_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        hours REAL NOT NULL,
        quality INTEGER NOT NULL,
        deepSleep REAL NOT NULL,
        bedtime TEXT NOT NULL,
        wakeTime TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Sleep schedule table
    await db.execute('''
      CREATE TABLE sleep_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bedtime TEXT NOT NULL,
        wakeTime TEXT NOT NULL,
        targetHours INTEGER NOT NULL,
        targetMinutes INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // Sleep Data Operations
  Future<int> insertSleepData(SleepData sleepData) async {
    final db = await database;
    return await db.insert(
      'sleep_data',
      sleepData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SleepData>> getSleepDataForLast7Days() async {
    final db = await database;
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));

    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_data',
      where: 'date >= ?',
      whereArgs: [_formatDate(sevenDaysAgo)],
      orderBy: 'date ASC',
    );

    return List.generate(maps.length, (i) => SleepData.fromMap(maps[i]));
  }

  Future<SleepData?> getSleepDataForDate(DateTime date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_data',
      where: 'date = ?',
      whereArgs: [_formatDate(date)],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SleepData.fromMap(maps.first);
    }
    return null;
  }

  Future<SleepData?> getTodaysSleepData() async {
    return await getSleepDataForDate(DateTime.now());
  }

  Future<int> updateSleepData(SleepData sleepData) async {
    final db = await database;
    return await db.update(
      'sleep_data',
      sleepData.toMap(),
      where: 'id = ?',
      whereArgs: [sleepData.id],
    );
  }

  Future<int> deleteSleepData(int id) async {
    final db = await database;
    return await db.delete(
      'sleep_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sleep Schedule Operations
  Future<int> insertOrUpdateSleepSchedule(SleepSchedule schedule) async {
    final db = await database;

    // Check if schedule exists
    final existing = await getCurrentSleepSchedule();
    if (existing != null) {
      return await db.update(
        'sleep_schedule',
        schedule.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      return await db.insert('sleep_schedule', schedule.toMap());
    }
  }

  Future<SleepSchedule?> getCurrentSleepSchedule() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sleep_schedule',
      orderBy: 'updatedAt DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return SleepSchedule.fromMap(maps.first);
    }
    return null;
  }

  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Initialize with default data if needed
  Future<void> initializeWithDefaults() async {
    // Check if we have a sleep schedule, if not create default
    final schedule = await getCurrentSleepSchedule();
    if (schedule == null) {
      await insertOrUpdateSleepSchedule(SleepSchedule(
        bedtime: '22:30',
        wakeTime: '06:30',
        targetHours: 8,
        targetMinutes: 0,
      ));
    }

    // Check if we have any sleep data for the last 7 days
    final sleepDataList = await getSleepDataForLast7Days();
    if (sleepDataList.isEmpty) {
      // Add some sample data for the last 7 days for demo purposes
      final now = DateTime.now();
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final sleepData = _generateSampleSleepData(date);
        await insertSleepData(sleepData);
      }
    }
  }

  SleepData _generateSampleSleepData(DateTime date) {
    // Generate realistic sample data
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final baseHours = 7.0 + (random % 3); // 7-9 hours
    final quality = 70 + (random % 25); // 70-95% quality
    final deepSleep =
        baseHours * 0.2 + (random % 10) * 0.1; // 20-30% of total sleep

    return SleepData(
      date: _formatDate(date),
      hours: double.parse(baseHours.toStringAsFixed(1)),
      quality: quality,
      deepSleep: double.parse(deepSleep.toStringAsFixed(1)),
      bedtime: '22:30',
      wakeTime: '06:30',
    );
  }

  // Get sleep data for specific day of week (for chart display)
  Future<Map<String, Map<String, dynamic>>> getWeeklySleepDataMap() async {
    final sleepDataList = await getSleepDataForLast7Days();
    final Map<String, Map<String, dynamic>> weeklyData = {};

    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = daysOfWeek[date.weekday - 1];

      // Find matching sleep data
      final matchingData = sleepDataList
          .where((data) => data.date == _formatDate(date))
          .firstOrNull;

      if (matchingData != null) {
        weeklyData[dayName] = {
          'hours': matchingData.hours,
          'quality': matchingData.quality,
          'deepSleep': matchingData.deepSleep,
        };
      } else {
        // Default data if no record exists
        weeklyData[dayName] = {
          'hours': 0.0,
          'quality': 0,
          'deepSleep': 0.0,
        };
      }
    }

    return weeklyData;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

extension on Iterable<SleepData> {
  SleepData? get firstOrNull => isEmpty ? null : first;
}
