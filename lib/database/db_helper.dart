import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/donation.dart';
import '../models/charity.dart';
import '../models/budget_goal.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._internal();
  static Database? _db;

  DBHelper._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'charity_tracker_v2.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE charities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        website TEXT,
        colorValue INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        charityId INTEGER NOT NULL,
        charityName TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        isRecurring INTEGER DEFAULT 0,
        recurringInterval TEXT,
        paymentMethod TEXT DEFAULT 'Cash',
        FOREIGN KEY (charityId) REFERENCES charities(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        goalAmount REAL NOT NULL,
        UNIQUE(year, month)
      )
    ''');
  }

  // ── Charities ─────────────────────────────────────────────
  Future<int> insertCharity(Charity c) async =>
      (await database).insert('charities', c.toMap());

  Future<List<Charity>> getAllCharities() async {
    final db = await database;
    final rows = await db.query('charities', orderBy: 'name ASC');
    return rows.map(Charity.fromMap).toList();
  }

  Future<int> updateCharity(Charity c) async =>
      (await database).update('charities', c.toMap(), where: 'id = ?', whereArgs: [c.id]);

  Future<int> deleteCharity(int id) async =>
      (await database).delete('charities', where: 'id = ?', whereArgs: [id]);

  // ── Donations ──────────────────────────────────────────────
  Future<int> insertDonation(Donation d) async =>
      (await database).insert('donations', d.toMap());

  Future<List<Donation>> getAllDonations({String? search, String? category, int? charityId}) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (search != null && search.isNotEmpty) {
      conditions.add('(charityName LIKE ? OR note LIKE ?)');
      args.addAll(['%$search%', '%$search%']);
    }
    if (category != null && category != 'All') {
      conditions.add('category = ?');
      args.add(category);
    }
    if (charityId != null) {
      conditions.add('charityId = ?');
      args.add(charityId);
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;
    final rows = await db.query('donations', where: where, whereArgs: args.isEmpty ? null : args, orderBy: 'date DESC');
    return rows.map(Donation.fromMap).toList();
  }

  Future<List<Donation>> getDonationsForMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    final rows = await db.query(
      'donations',
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return rows.map(Donation.fromMap).toList();
  }

  Future<int> updateDonation(Donation d) async =>
      (await database).update('donations', d.toMap(), where: 'id = ?', whereArgs: [d.id]);

  Future<int> deleteDonation(int id) async =>
      (await database).delete('donations', where: 'id = ?', whereArgs: [id]);

  Future<double> getTotalDonated() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM donations');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getTotalByCategory() async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM donations GROUP BY category ORDER BY total DESC');
    return {for (var r in rows) r['category'] as String: (r['total'] as num).toDouble()};
  }

  Future<List<Map<String, dynamic>>> getMonthlyTotals(int months) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT strftime('%Y-%m', date) as month, SUM(amount) as total
      FROM donations
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month DESC
      LIMIT ?
    ''', [months]);
  }

  Future<Map<int, double>> getTotalByCharity() async {
    final db = await database;
    final rows = await db.rawQuery(
        'SELECT charityId, SUM(amount) as total FROM donations GROUP BY charityId ORDER BY total DESC');
    return {for (var r in rows) r['charityId'] as int: (r['total'] as num).toDouble()};
  }

  // ── Budget Goals ───────────────────────────────────────────
  Future<void> upsertBudgetGoal(BudgetGoal g) async {
    final db = await database;
    await db.insert(
      'budget_goals',
      g.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BudgetGoal?> getBudgetGoal(int year, int month) async {
    final db = await database;
    final rows = await db.query('budget_goals',
        where: 'year = ? AND month = ?', whereArgs: [year, month]);
    if (rows.isEmpty) return null;
    return BudgetGoal.fromMap(rows.first);
  }
}