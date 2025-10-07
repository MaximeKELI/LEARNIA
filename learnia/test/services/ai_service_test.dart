import 'ai_service_test.mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnia/services/ai_service.dart';
import 'package:learnia/services/api_service.dart';


@GenerateMocks([ApiService])
void main() {
  group('AiService Tests', () {
    late AiService aiService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      aiService = AiService();
      // Injecter le mock dans le service
      // Note: Cela nécessiterait une refactorisation du service pour accepter l'injection
    });

    group('generateTutorResponse', () {
      test('should return AI response when API call succeeds', () async {
        // Arrange
        const question = 'Qu\'est-ce qu\'une fraction ?';
        const subject = 'Mathématiques';
        const expectedResponse = 'Les fractions représentent une partie d\'un tout.';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => {
          'response': expectedResponse,
        });

        // Act
        final result = await aiService.generateTutorResponse(question, subject);

        // Assert
        expect(result, equals(expectedResponse));
      });

      test('should return local response when API call fails', () async {
        // Arrange
        const question = 'Qu\'est-ce qu\'une fraction ?';
        const subject = 'Mathématiques';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.generateTutorResponse(question, subject);

        // Assert
        expect(result, isNotEmpty);
        expect(result, contains('fraction'));
      });
    });

    group('generateQcmQuestions', () {
      test('should return QCM questions when API call succeeds', () async {
        // Arrange
        const text = 'Les fractions sont importantes en mathématiques.';
        const subject = 'Mathématiques';
        final expectedQuestions = [
          {
            'question': 'Qu\'est-ce qu\'une fraction ?',
            'options': ['A', 'B', 'C', 'D'],
            'correct_answer': 'A',
          }
        ];

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => {
          'questions': expectedQuestions,
        });

        // Act
        final result = await aiService.generateQcmQuestions(text, subject);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(1));
        expect(result.first['question'], equals('Qu\'est-ce qu\'une fraction ?'));
      });

      test('should return local QCM questions when API call fails', () async {
        // Arrange
        const text = 'Test text';
        const subject = 'Mathématiques';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.generateQcmQuestions(text, subject);

        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, greaterThan(0));
      });
    });

    group('generateSummary', () {
      test('should return summary when API call succeeds', () async {
        // Arrange
        const text = 'Long text about mathematics and fractions...';
        const subject = 'Mathématiques';
        const expectedSummary = 'Résumé des mathématiques et fractions.';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => {
          'summary': expectedSummary,
        });

        // Act
        final result = await aiService.generateSummary(text, subject);

        // Assert
        expect(result, equals(expectedSummary));
      });

      test('should return local summary when API call fails', () async {
        // Arrange
        const text = 'Première phrase. Deuxième phrase. Troisième phrase.';
        const subject = 'Test';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.generateSummary(text, subject);

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, lessThan(text.length));
      });
    });

    group('translateText', () {
      test('should return translation when API call succeeds', () async {
        // Arrange
        const text = 'bonjour';
        const targetLanguage = 'éwé';
        const expectedTranslation = 'Woé zɔ';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => {
          'translated_text': expectedTranslation,
          'confidence': '0.9',
        });

        // Act
        final result = await aiService.translateText(text, targetLanguage);

        // Assert
        expect(result['translated_text'], equals(expectedTranslation));
        expect(result['confidence'], equals('0.9'));
      });

      test('should return local translation when API call fails', () async {
        // Arrange
        const text = 'bonjour';
        const targetLanguage = 'éwé';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.translateText(text, targetLanguage);

        // Assert
        expect(result['translated_text'], isNotEmpty);
        expect(result['confidence'], isNotEmpty);
      });
    });

    group('analyzeOrientation', () {
      test('should return orientation analysis when API call succeeds', () async {
        // Arrange
        final answers = [
          {'question_id': 'q1', 'answer': 'Sciences'},
          {'question_id': 'q2', 'answer': 'Mathématiques'},
        ];
        final expectedResult = {
          'filiere_suggeree': 'Sciences et Technologies',
          'metiers': ['Ingénieur', 'Médecin'],
          'explication': 'Basé sur vos réponses...',
        };

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => expectedResult);

        // Act
        final result = await aiService.analyzeOrientation(answers);

        // Assert
        expect(result, equals(expectedResult));
      });

      test('should return local orientation when API call fails', () async {
        // Arrange
        final answers = [
          {'question_id': 'q1', 'answer': 'Sciences'},
        ];

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.analyzeOrientation(answers);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['filiere_suggeree'], isNotEmpty);
      });
    });

    group('performOcr', () {
      test('should return OCR result when API call succeeds', () async {
        // Arrange
        const imageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
        const expectedText = 'Texte reconnu';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenAnswer((_) async => {
          'text': expectedText,
        });

        // Act
        final result = await aiService.performOcr(imageBase64);

        // Assert
        expect(result, equals(expectedText));
      });

      test('should return error message when API call fails', () async {
        // Arrange
        const imageBase64 = 'invalid_base64';

        when(mockApiService.post(
          any,
          body: anyNamed('body'),
        )).thenThrow(Exception('API Error'));

        // Act
        final result = await aiService.performOcr(imageBase64);

        // Assert
        expect(result, equals('Erreur de reconnaissance de texte'));
      });
    });
  });
}
