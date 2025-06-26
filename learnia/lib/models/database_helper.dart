import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = '${documentsDirectory.path}/learnia.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        grade TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des questions QCM
    await db.execute('''
      CREATE TABLE qcm_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        subject TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des résultats de quiz
    await db.execute('''
      CREATE TABLE quiz_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        subject TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des cartes Leitner
    await db.execute('''
      CREATE TABLE leitner_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        subject TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        next_review TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des plannings de révision
    await db.execute('''
      CREATE TABLE study_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        subject TEXT NOT NULL,
        topic TEXT NOT NULL,
        duration INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des traductions
    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        french_text TEXT NOT NULL,
        ewe_text TEXT,
        kabiyee_text TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des résumés
    await db.execute('''
      CREATE TABLE summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        original_text TEXT NOT NULL,
        summary_text TEXT NOT NULL,
        subject TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Table des conversations avec le tuteur
    await db.execute('''
      CREATE TABLE tutor_conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        subject TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // Méthodes pour les utilisateurs
  Future<int> insertUser(String name, String grade) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'grade': grade,
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  // Méthodes pour les questions QCM
  Future<int> insertQcmQuestion(Map<String, dynamic> question) async {
    final db = await database;
    return await db.insert('qcm_questions', question);
  }

  Future<List<Map<String, dynamic>>> getQcmQuestions(String subject) async {
    final db = await database;
    return await db.query(
      'qcm_questions',
      where: 'subject = ?',
      whereArgs: [subject],
    );
  }

  // Méthodes pour les résultats de quiz
  Future<int> insertQuizResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('quiz_results', result);
  }

  Future<List<Map<String, dynamic>>> getQuizResults(int userId) async {
    final db = await database;
    return await db.query(
      'quiz_results',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // Méthodes pour les cartes Leitner
  Future<int> insertLeitnerCard(Map<String, dynamic> card) async {
    final db = await database;
    return await db.insert('leitner_cards', card);
  }

  Future<List<Map<String, dynamic>>> getLeitnerCardsForReview() async {
    final db = await database;
    return await db.query(
      'leitner_cards',
      where: 'next_review <= ?',
      whereArgs: [DateTime.now().toIso8601String()],
    );
  }

  Future<void> updateLeitnerCardLevel(int cardId, int newLevel) async {
    final db = await database;
    await db.update(
      'leitner_cards',
      {
        'level': newLevel,
        'next_review': _calculateNextReview(newLevel),
      },
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  DateTime _calculateNextReview(int level) {
    // Système Leitner : plus le niveau est élevé, plus l'intervalle est long
    final intervals = [1, 3, 7, 14, 30, 90, 180]; // jours
    final days = level < intervals.length ? intervals[level - 1] : 365;
    return DateTime.now().add(Duration(days: days));
  }

  // Méthodes pour les plannings
  Future<int> insertStudyPlan(Map<String, dynamic> plan) async {
    final db = await database;
    return await db.insert('study_plans', plan);
  }

  Future<List<Map<String, dynamic>>> getStudyPlans(int userId) async {
    final db = await database;
    return await db.query(
      'study_plans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'day_of_week ASC',
    );
  }

  // Méthodes pour les traductions
  Future<int> insertTranslation(Map<String, dynamic> translation) async {
    final db = await database;
    return await db.insert('translations', translation);
  }

  Future<Map<String, dynamic>?> getTranslation(String frenchText) async {
    final db = await database;
    final results = await db.query(
      'translations',
      where: 'french_text = ?',
      whereArgs: [frenchText],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Méthodes pour les résumés
  Future<int> insertSummary(Map<String, dynamic> summary) async {
    final db = await database;
    return await db.insert('summaries', summary);
  }

  Future<List<Map<String, dynamic>>> getSummaries(String subject) async {
    final db = await database;
    return await db.query(
      'summaries',
      where: 'subject = ?',
      whereArgs: [subject],
      orderBy: 'created_at DESC',
    );
  }

  // Méthodes pour les conversations avec le tuteur
  Future<int> insertTutorConversation(Map<String, dynamic> conversation) async {
    final db = await database;
    return await db.insert('tutor_conversations', conversation);
  }

  Future<List<Map<String, dynamic>>> getTutorConversations(int userId) async {
    final db = await database;
    return await db.query(
      'tutor_conversations',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }
} 