import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NotificationDatabase {
  static Database? _database;

  // Singleton pattern for the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'notifications.db');
      return await openDatabase(
        path,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE notifications(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT UNIQUE, body TEXT, date TEXT)",
          );
        },
        version: 1,
      );
    } catch (e) {
      throw Exception('Error initializing database: $e');
    }
  }

  // Save a notification to the database
  static Future<void> saveNotification(Map<String, dynamic> notification) async {
    final db = await database;
    try {
      await db.insert(
        'notifications',
        notification,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error saving notification: $e');
    }
  }

  // Retrieve all notifications from the database
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    try {
      return await db.query('notifications');
    } catch (e) {
      throw Exception('Error retrieving notifications: $e');
    }
  }

  // Delete a notification by title
   static Future<void> deleteNotification(DateTime date) async {
    final db = await database;
    try {
      await db.delete(
        'notifications',
        where: 'date = ?',
        whereArgs: [date.toIso8601String()],
      );
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }
}
