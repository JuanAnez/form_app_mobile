import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() {
    return _instance;
  }

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'survey_responses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE responses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            surveyId TEXT,
            question TEXT,
            answer TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertResponse(String surveyId, String question, String answer) async {
    final db = await database;
    await db.insert(
      'responses',
      {'surveyId': surveyId, 'question': question, 'answer': answer},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getResponses() async {
    final db = await database;
    return await db.query('responses');
  }

  Future<void> deleteResponses() async {
    final db = await database;
    await db.delete('responses');
  }

  Future<void> storeVote(String surveyId, String question, String answer) async {
    final db = await database;
    await db.insert(
      'votes',
      {'surveyId': surveyId, 'question': question, 'answer': answer},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getVotes() async {
    final db = await database;
    return await db.query('votes');
  }

  Future<void> deleteVotes() async {
    final db = await database;
    await db.delete('votes');
  }
}
