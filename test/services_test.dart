import 'package:flutter_test/flutter_test.dart';
import 'package:learnia/services/ai_service.dart';
import 'package:learnia/services/api_service.dart';
import 'package:learnia/services/auth_service.dart';
import 'package:learnia/services/database_helper.dart';

void main() {
  group('API Service Tests', () {
    test('should create singleton instance', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      expect(instance1, equals(instance2));
    });

    test('should set and clear auth token', () {
      final apiService = ApiService();
      apiService.setAuthToken('test-token');
      // Note: In a real test, you would verify the token is set
      apiService.clearAuthToken();
      // Note: In a real test, you would verify the token is cleared
    });
  });

  group('Database Helper Tests', () {
    test('should create singleton instance', () {
      final instance1 = DatabaseHelper();
      final instance2 = DatabaseHelper();
      expect(instance1, equals(instance2));
    });
  });

  group('AI Service Tests', () {
    test('should create singleton instance', () {
      final instance1 = AIService();
      final instance2 = AIService();
      expect(instance1, equals(instance2));
    });

    test('should generate local tutor response', () async {
      final aiService = AIService();
      final response = await aiService.askTutor(
        question: 'Qu\'est-ce qu\'une fraction ?',
        subject: 'Mathématiques',
      );
      
      expect(response.answer, isNotEmpty);
      expect(response.confidence, greaterThan(0.0));
      expect(response.source, equals('local'));
    });

    test('should generate local QCM', () async {
      final aiService = AIService();
      final response = await aiService.generateQcm(
        text: 'Test text for QCM generation',
        subject: 'Mathématiques',
        numQuestions: 3,
      );
      
      expect(response.questions, isNotEmpty);
      expect(response.questions.length, equals(3));
      expect(response.subject, equals('Mathématiques'));
    });

    test('should generate local summary', () async {
      final aiService = AIService();
      final response = await aiService.generateSummary(
        text: 'This is a long text that should be summarized. It contains multiple sentences to test the summarization functionality.',
        maxLength: 20,
      );
      
      expect(response.summary, isNotEmpty);
      expect(response.originalLength, greaterThan(0));
      expect(response.summaryLength, greaterThan(0));
      expect(response.compressionRatio, greaterThan(0.0));
    });

    test('should translate text locally', () async {
      final aiService = AIService();
      final response = await aiService.translateText(
        text: 'bonjour',
        sourceLanguage: 'fr',
        targetLanguage: 'éwé',
      );
      
      expect(response.originalText, equals('bonjour'));
      expect(response.translatedText, isNotEmpty);
      expect(response.sourceLanguage, equals('fr'));
      expect(response.targetLanguage, equals('éwé'));
    });
  });

  group('Auth Service Tests', () {
    test('should create singleton instance', () {
      final instance1 = AuthService();
      final instance2 = AuthService();
      expect(instance1, equals(instance2));
    });

    test('should have initial state', () {
      final authService = AuthService();
      expect(authService.currentUser, isNull);
      expect(authService.isLoggedIn, isFalse);
    });
  });

  group('User Model Tests', () {
    test('should create user from JSON', () {
      final json = {
        'id': 1,
        'email': 'test@example.com',
        'username': 'testuser',
        'full_name': 'Test User',
        'grade_level': 'Collège',
        'school': 'Test School',
        'is_active': true,
        'is_teacher': false,
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
      };

      final user = User.fromJson(json);
      
      expect(user.id, equals(1));
      expect(user.email, equals('test@example.com'));
      expect(user.username, equals('testuser'));
      expect(user.fullName, equals('Test User'));
      expect(user.gradeLevel, equals('Collège'));
      expect(user.school, equals('Test School'));
      expect(user.isActive, isTrue);
      expect(user.isTeacher, isFalse);
    });

    test('should convert user to JSON', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        fullName: 'Test User',
        gradeLevel: 'Collège',
        school: 'Test School',
        isActive: true,
        isTeacher: false,
        createdAt: DateTime.parse('2023-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2023-01-01T00:00:00Z'),
      );

      final json = user.toJson();
      
      expect(json['id'], equals(1));
      expect(json['email'], equals('test@example.com'));
      expect(json['username'], equals('testuser'));
      expect(json['full_name'], equals('Test User'));
      expect(json['grade_level'], equals('Collège'));
      expect(json['school'], equals('Test School'));
      expect(json['is_active'], isTrue);
      expect(json['is_teacher'], isFalse);
    });

    test('should generate display name', () {
      final userWithFullName = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userWithoutFullName = User(
        id: 2,
        email: 'test2@example.com',
        username: 'testuser2',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(userWithFullName.displayName, equals('Test User'));
      expect(userWithoutFullName.displayName, equals('testuser2'));
    });

    test('should generate initials', () {
      final userWithFullName = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        fullName: 'Test User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userWithSingleName = User(
        id: 2,
        email: 'test2@example.com',
        username: 'testuser2',
        fullName: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final userWithoutFullName = User(
        id: 3,
        email: 'test3@example.com',
        username: 'testuser3',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(userWithFullName.initials, equals('TU'));
      expect(userWithSingleName.initials, equals('T'));
      expect(userWithoutFullName.initials, equals('T'));
    });
  });

  group('Auth Result Tests', () {
    test('should create success result', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = AuthResult.success(user: user, token: 'test-token');
      
      expect(result.success, isTrue);
      expect(result.user, equals(user));
      expect(result.token, equals('test-token'));
      expect(result.error, isNull);
    });

    test('should create error result', () {
      final result = AuthResult.error('Test error');
      
      expect(result.success, isFalse);
      expect(result.user, isNull);
      expect(result.token, isNull);
      expect(result.error, equals('Test error'));
    });
  });
}

