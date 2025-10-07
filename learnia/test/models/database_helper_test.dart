import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:learnia/models/database_helper.dart';

void main() {
  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() {
      // Initialiser SQLite FFI pour les tests
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Nettoyer la base de données avant chaque test
      final db = await dbHelper.database;
      await db.delete('users');
      await db.delete('qcm_questions');
      await db.delete('quiz_results');
      await db.delete('leitner_cards');
      await db.delete('study_plans');
      await db.delete('translations');
      await db.delete('summaries');
      await db.delete('tutor_conversations');
    });

    group('User Management', () {
      test('should insert and retrieve user', () async {
        // Arrange
        const name = 'Test User';
        const grade = 'Collège';

        // Act
        final userId = await dbHelper.insertUser(name, grade);
        final users = await dbHelper.getUsers();

        // Assert
        expect(userId, isA<int>());
        expect(users.length, equals(1));
        expect(users.first['name'], equals(name));
        expect(users.first['grade'], equals(grade));
      });

      test('should insert multiple users', () async {
        // Act
        await dbHelper.insertUser('User 1', 'Primaire');
        await dbHelper.insertUser('User 2', 'Lycée');
        final users = await dbHelper.getUsers();

        // Assert
        expect(users.length, equals(2));
      });
    });

    group('QCM Questions', () {
      test('should insert and retrieve QCM question', () async {
        // Arrange
        final question = {
          'question': 'Qu\'est-ce qu\'une fraction ?',
          'option_a': 'Partie d\'un tout',
          'option_b': 'Nombre entier',
          'option_c': 'Décimal',
          'option_d': 'Pourcentage',
          'correct_answer': 'Partie d\'un tout',
          'subject': 'Mathématiques',
        };

        // Act
        final questionId = await dbHelper.insertQcmQuestion(question);
        final questions = await dbHelper.getQcmQuestions('Mathématiques');

        // Assert
        expect(questionId, isA<int>());
        expect(questions.length, equals(1));
        expect(questions.first['question'], equals(question['question']));
        expect(questions.first['subject'], equals('Mathématiques'));
      });

      test('should filter QCM questions by subject', () async {
        // Arrange
        final mathQuestion = {
          'question': 'Question de maths',
          'option_a': 'A',
          'option_b': 'B',
          'option_c': 'C',
          'option_d': 'D',
          'correct_answer': 'A',
          'subject': 'Mathématiques',
        };
        final frenchQuestion = {
          'question': 'Question de français',
          'option_a': 'A',
          'option_b': 'B',
          'option_c': 'C',
          'option_d': 'D',
          'correct_answer': 'A',
          'subject': 'Français',
        };

        // Act
        await dbHelper.insertQcmQuestion(mathQuestion);
        await dbHelper.insertQcmQuestion(frenchQuestion);
        final mathQuestions = await dbHelper.getQcmQuestions('Mathématiques');
        final frenchQuestions = await dbHelper.getQcmQuestions('Français');

        // Assert
        expect(mathQuestions.length, equals(1));
        expect(frenchQuestions.length, equals(1));
        expect(mathQuestions.first['subject'], equals('Mathématiques'));
        expect(frenchQuestions.first['subject'], equals('Français'));
      });
    });

    group('Quiz Results', () {
      test('should insert and retrieve quiz results', () async {
        // Arrange
        const userId = 1;
        final result = {
          'user_id': userId,
          'subject': 'Mathématiques',
          'score': 8,
          'total_questions': 10,
        };

        // Act
        final resultId = await dbHelper.insertQuizResult(result);
        final results = await dbHelper.getQuizResults(userId);

        // Assert
        expect(resultId, isA<int>());
        expect(results.length, equals(1));
        expect(results.first['user_id'], equals(userId));
        expect(results.first['score'], equals(8));
        expect(results.first['total_questions'], equals(10));
      });

      test('should retrieve quiz results ordered by date', () async {
        // Arrange
        const userId = 1;
        final result1 = {
          'user_id': userId,
          'subject': 'Mathématiques',
          'score': 5,
          'total_questions': 10,
        };
        final result2 = {
          'user_id': userId,
          'subject': 'Français',
          'score': 7,
          'total_questions': 10,
        };

        // Act
        await dbHelper.insertQuizResult(result1);
        await Future.delayed(Duration(milliseconds: 10)); // Petite pause pour différencier les dates
        await dbHelper.insertQuizResult(result2);
        final results = await dbHelper.getQuizResults(userId);

        // Assert
        expect(results.length, equals(2));
        // Le dernier résultat inséré doit être en premier (ordre DESC)
        expect(results.first['subject'], equals('Français'));
        expect(results.last['subject'], equals('Mathématiques'));
      });
    });

    group('Leitner Cards', () {
      test('should insert and retrieve Leitner cards', () async {
        // Arrange
        final card = {
          'question': 'Quelle est la capitale du Togo ?',
          'answer': 'Lomé',
          'subject': 'Géographie',
          'level': 1,
        };

        // Act
        final cardId = await dbHelper.insertLeitnerCard(card);
        final cards = await dbHelper.getLeitnerCardsForReview();

        // Assert
        expect(cardId, isA<int>());
        expect(cards.length, equals(1));
        expect(cards.first['question'], equals(card['question']));
        expect(cards.first['answer'], equals(card['answer']));
      });

      test('should update Leitner card level', () async {
        // Arrange
        final card = {
          'question': 'Test question',
          'answer': 'Test answer',
          'subject': 'Test',
          'level': 1,
        };
        final cardId = await dbHelper.insertLeitnerCard(card);

        // Act
        await dbHelper.updateLeitnerCardLevel(cardId, 2);
        final cards = await dbHelper.getLeitnerCardsForReview();

        // Assert
        expect(cards.length, equals(0)); // Niveau 2 = prochaine révision dans 3 jours
      });
    });

    group('Study Plans', () {
      test('should insert and retrieve study plans', () async {
        // Arrange
        const userId = 1;
        final plan = {
          'user_id': userId,
          'subject': 'Mathématiques',
          'topic': 'Fractions',
          'duration': 60, // minutes
          'day_of_week': 1, // Lundi
        };

        // Act
        final planId = await dbHelper.insertStudyPlan(plan);
        final plans = await dbHelper.getStudyPlans(userId);

        // Assert
        expect(planId, isA<int>());
        expect(plans.length, equals(1));
        expect(plans.first['subject'], equals('Mathématiques'));
        expect(plans.first['topic'], equals('Fractions'));
        expect(plans.first['duration'], equals(60));
      });
    });

    group('Translations', () {
      test('should insert and retrieve translations', () async {
        // Arrange
        final translation = {
          'french_text': 'bonjour',
          'ewe_text': 'Woé zɔ',
          'kabiyee_text': 'Yaa',
        };

        // Act
        final translationId = await dbHelper.insertTranslation(translation);
        final retrievedTranslation = await dbHelper.getTranslation('bonjour');

        // Assert
        expect(translationId, isA<int>());
        expect(retrievedTranslation, isNotNull);
        expect(retrievedTranslation!['french_text'], equals('bonjour'));
        expect(retrievedTranslation['ewe_text'], equals('Woé zɔ'));
        expect(retrievedTranslation['kabiyee_text'], equals('Yaa'));
      });

      test('should return null for non-existent translation', () async {
        // Act
        final translation = await dbHelper.getTranslation('mot_inexistant');

        // Assert
        expect(translation, isNull);
      });
    });

    group('Summaries', () {
      test('should insert and retrieve summaries', () async {
        // Arrange
        final summary = {
          'original_text': 'Long text about mathematics...',
          'summary_text': 'Short summary about math.',
          'subject': 'Mathématiques',
        };

        // Act
        final summaryId = await dbHelper.insertSummary(summary);
        final summaries = await dbHelper.getSummaries('Mathématiques');

        // Assert
        expect(summaryId, isA<int>());
        expect(summaries.length, equals(1));
        expect(summaries.first['original_text'], equals('Long text about mathematics...'));
        expect(summaries.first['summary_text'], equals('Short summary about math.'));
      });
    });

    group('Tutor Conversations', () {
      test('should insert and retrieve tutor conversations', () async {
        // Arrange
        const userId = 1;
        final conversation = {
          'user_id': userId,
          'question': 'Qu\'est-ce qu\'une fraction ?',
          'answer': 'Une fraction représente une partie d\'un tout.',
          'subject': 'Mathématiques',
        };

        // Act
        final conversationId = await dbHelper.insertTutorConversation(conversation);
        final conversations = await dbHelper.getTutorConversations(userId);

        // Assert
        expect(conversationId, isA<int>());
        expect(conversations.length, equals(1));
        expect(conversations.first['question'], equals('Qu\'est-ce qu\'une fraction ?'));
        expect(conversations.first['answer'], equals('Une fraction représente une partie d\'un tout.'));
        expect(conversations.first['subject'], equals('Mathématiques'));
      });
    });
  });
}
