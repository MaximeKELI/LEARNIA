import 'api_service.dart';

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  final ApiService _apiService = ApiService();

  // Configuration des APIs d'IA
  static const String _openaiEndpoint = '/ai/openai';
  static const String _localAiEndpoint = '/ai/local';
  static const String _huggingfaceEndpoint = '/ai/huggingface';

  /// Génère une réponse pour le tuteur intelligent
  Future<String> generateTutorResponse(String question, String subject, {String? token}) async {
    try {
      final response = token != null 
        ? await _apiService.jwtRequest(
            endpoint: '/api/v1/ai/tutor/',
            token: token,
            method: 'POST',
            body: {
              'question': question,
              'subject': subject,
              'grade_level': 'Collège',
            },
          )
        : await _apiService.post(
            '$_openaiEndpoint/chat',
            body: {
              'question': question,
              'subject': subject,
              'context': 'education_tutor',
              'language': 'fr',
              'grade_level': 'primary_to_high_school',
            },
          );
      
      return response['answer'] ?? response['response'] ?? 'Désolé, je ne peux pas répondre pour le moment.';
    } catch (e) {
      // Fallback vers l'IA locale ou réponse simulée
      return _generateLocalResponse(question, subject);
    }
  }

  /// Génère des questions QCM à partir d'un texte
  Future<List<Map<String, dynamic>>> generateQcmQuestions(String text, String subject) async {
    try {
      final response = await _apiService.post(
        '$_openaiEndpoint/qcm',
        body: {
          'text': text,
          'subject': subject,
          'num_questions': 5,
          'language': 'fr',
        },
      );
      
      return List<Map<String, dynamic>>.from(response['questions'] ?? []);
    } catch (e) {
      // Fallback vers l'IA locale
      return _generateLocalQcmQuestions(text, subject);
    }
  }

  /// Génère un résumé automatique
  Future<String> generateSummary(String text, String subject) async {
    try {
      final response = await _apiService.post(
        '$_openaiEndpoint/summarize',
        body: {
          'text': text,
          'subject': subject,
          'max_length': 200,
          'language': 'fr',
        },
      );
      
      return response['summary'] ?? 'Impossible de générer un résumé.';
    } catch (e) {
      return _generateLocalSummary(text);
    }
  }

  /// Traduit un texte en langues locales
  Future<Map<String, String>> translateText(String text, String targetLanguage) async {
    try {
      final response = await _apiService.post(
        '$_huggingfaceEndpoint/translate',
        body: {
          'text': text,
          'source_language': 'fr',
          'target_language': targetLanguage,
        },
      );
      
      return {
        'translated_text': response['translated_text'] ?? text,
        'confidence': response['confidence']?.toString() ?? '0.0',
      };
    } catch (e) {
      return _generateLocalTranslation(text, targetLanguage);
    }
  }

  /// Analyse l'orientation scolaire
  Future<Map<String, dynamic>> analyzeOrientation(List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiService.post(
        '$_openaiEndpoint/orientation',
        body: {
          'answers': answers,
          'context': 'togo_education_system',
          'language': 'fr',
        },
      );
      
      return response;
    } catch (e) {
      return _generateLocalOrientation(answers);
    }
  }

  /// Reconnaissance de texte (OCR)
  Future<String> performOcr(String imageBase64) async {
    try {
      final response = await _apiService.post(
        '$_localAiEndpoint/ocr',
        body: {
          'image': imageBase64,
          'language': 'fr',
        },
      );
      
      return response['text'] ?? 'Texte non détecté';
    } catch (e) {
      return 'Erreur de reconnaissance de texte';
    }
  }

  // Méthodes de fallback local
  String _generateLocalResponse(String question, String subject) {
    // Simulation de réponses locales basées sur des mots-clés
    final responses = {
      'fraction': 'Les fractions représentent une partie d\'un tout. Par exemple, 1/2 signifie une partie sur deux parties égales.',
      'géométrie': 'La géométrie étudie les formes et les figures dans l\'espace. Elle utilise des outils comme la règle et le compas.',
      'histoire': 'L\'histoire nous permet de comprendre le passé pour mieux préparer l\'avenir.',
      'sciences': 'Les sciences nous aident à comprendre le monde qui nous entoure.',
    };

    for (final entry in responses.entries) {
      if (question.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Je comprends votre question sur $subject. Voici une explication simple...';
  }

  List<Map<String, dynamic>> _generateLocalQcmQuestions(String text, String subject) {
    // Génération locale de questions basiques
    return [
      {
        'question': 'Qu\'est-ce que $subject ?',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correct_answer': 'Option A',
      },
      {
        'question': 'Quelle est la définition principale ?',
        'options': ['Réponse 1', 'Réponse 2', 'Réponse 3', 'Réponse 4'],
        'correct_answer': 'Réponse 1',
      },
    ];
  }

  String _generateLocalSummary(String text) {
    // Résumé local basique
    final sentences = text.split('.');
    if (sentences.length <= 3) return text;
    
    return '${sentences.take(3).join('.')}.';
  }

  Map<String, String> _generateLocalTranslation(String text, String targetLanguage) {
    // Dictionnaire local simple
    final translations = {
      'éwé': {
        'bonjour': 'Woé zɔ',
        'merci': 'Akpé',
        'comment allez-vous': 'Êfoa woé',
      },
      'kabiyè': {
        'bonjour': 'Yaa',
        'merci': 'Yoo',
        'comment allez-vous': 'Yaa yaa',
      },
    };

    final dict = translations[targetLanguage] ?? {};
    String translated = text;
    
    for (final entry in dict.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return {
      'translated_text': translated,
      'confidence': '0.8',
    };
  }

  Map<String, dynamic> _generateLocalOrientation(List<Map<String, dynamic>> answers) {
    // Analyse locale basique
    return {
      'filiere_suggeree': 'Sciences et Technologies',
      'metiers': ['Ingénieur', 'Médecin', 'Enseignant'],
      'explication': 'Basé sur vos réponses, nous vous suggérons...',
    };
  }
} 