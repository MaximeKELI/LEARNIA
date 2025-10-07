import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'learnia.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table des utilisateurs
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        username TEXT UNIQUE NOT NULL,
        full_name TEXT,
        grade_level TEXT,
        school TEXT,
        is_active INTEGER DEFAULT 1,
        is_teacher INTEGER DEFAULT 0,
        birth_date TEXT,
        phone TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    // Table des sessions de tuteur
    await db.execute('''
      CREATE TABLE tutor_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        subject TEXT NOT NULL,
        grade_level TEXT,
        confidence REAL,
        source TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des QCM
    await db.execute('''
      CREATE TABLE qcm_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        difficulty TEXT,
        questions TEXT NOT NULL,
        score INTEGER,
        total_questions INTEGER,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des flashcards Leitner
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        subject TEXT NOT NULL,
        box_number INTEGER DEFAULT 0,
        last_reviewed TEXT,
        next_review TEXT,
        review_count INTEGER DEFAULT 0,
        success_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des résumés
    await db.execute('''
      CREATE TABLE summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        original_text TEXT NOT NULL,
        summary TEXT NOT NULL,
        subject TEXT,
        original_length INTEGER,
        summary_length INTEGER,
        compression_ratio REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des traductions
    await db.execute('''
      CREATE TABLE translations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        original_text TEXT NOT NULL,
        translated_text TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_language TEXT NOT NULL,
        confidence REAL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des performances
    await db.execute('''
      CREATE TABLE performances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        module TEXT NOT NULL,
        score REAL NOT NULL,
        max_score REAL NOT NULL,
        time_spent INTEGER,
        subject TEXT,
        grade_level TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des planifications
    await db.execute('''
      CREATE TABLE study_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        priority INTEGER DEFAULT 1,
        completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des résultats OCR
    await db.execute('''
      CREATE TABLE ocr_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        extracted_text TEXT NOT NULL,
        confidence REAL,
        word_count INTEGER,
        processing_time REAL,
        language TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Table des orientations
    await db.execute('''
      CREATE TABLE orientations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        answers TEXT NOT NULL,
        suggested_fields TEXT NOT NULL,
        suggested_careers TEXT NOT NULL,
        explanation TEXT,
        confidence REAL,
        recommendations TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Gestion des migrations futures
  }

  // Méthodes génériques CRUD
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  // Méthodes spécifiques pour les utilisateurs
  Future<int> createUser(Map<String, dynamic> userData) async {
    return await insert('users', userData);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final results = await query('users', where: 'email = ?', whereArgs: [email]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final results = await query('users', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    return await update('users', userData, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes pour les sessions de tuteur
  Future<int> saveTutorSession(Map<String, dynamic> sessionData) async {
    return await insert('tutor_sessions', sessionData);
  }

  Future<List<Map<String, dynamic>>> getTutorSessions(int userId, {int? limit}) async {
    return await query(
      'tutor_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Méthodes pour les QCM
  Future<int> saveQcmSession(Map<String, dynamic> qcmData) async {
    return await insert('qcm_sessions', qcmData);
  }

  Future<List<Map<String, dynamic>>> getQcmSessions(int userId, {int? limit}) async {
    return await query(
      'qcm_sessions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Méthodes pour les flashcards
  Future<int> createFlashcard(Map<String, dynamic> cardData) async {
    return await insert('flashcards', cardData);
  }

  Future<List<Map<String, dynamic>>> getFlashcards(int userId, {int? boxNumber}) async {
    String? where;
    List<dynamic>? whereArgs;
    
    if (boxNumber != null) {
      where = 'user_id = ? AND box_number = ?';
      whereArgs = [userId, boxNumber];
    } else {
      where = 'user_id = ?';
      whereArgs = [userId];
    }
    
    return await query('flashcards', where: where, whereArgs: whereArgs);
  }

  Future<int> updateFlashcard(int id, Map<String, dynamic> cardData) async {
    return await update('flashcards', cardData, where: 'id = ?', whereArgs: [id]);
  }

  // Méthodes pour les performances
  Future<int> savePerformance(Map<String, dynamic> performanceData) async {
    return await insert('performances', performanceData);
  }

  Future<List<Map<String, dynamic>>> getPerformances(int userId, {String? module}) async {
    String? where;
    List<dynamic>? whereArgs;
    
    if (module != null) {
      where = 'user_id = ? AND module = ?';
      whereArgs = [userId, module];
    } else {
      where = 'user_id = ?';
      whereArgs = [userId];
    }
    
    return await query('performances', where: where, whereArgs: whereArgs, orderBy: 'created_at DESC');
  }

  // Nettoyage de la base de données
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('tutor_sessions');
    await db.delete('qcm_sessions');
    await db.delete('flashcards');
    await db.delete('summaries');
    await db.delete('translations');
    await db.delete('performances');
    await db.delete('study_plans');
    await db.delete('ocr_results');
    await db.delete('orientations');
  }

  // Fermeture de la base de données
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
