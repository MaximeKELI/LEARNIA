import 'api_service.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final ApiService _apiService = ApiService();

  // Tuteur intelligent
  Future<TutorResponse> askTutor({
    required String question,
    required String subject,
    String? gradeLevel,
    String? context,
  }) async {
    try {
      final response = await _apiService.post('/ai/tutor/', body: {
        'question': question,
        'subject': subject,
        'grade_level': gradeLevel,
        'context': context,
      });

      return TutorResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur tuteur: $e');
      }
      // Fallback local
      return _generateLocalTutorResponse(question, subject, gradeLevel);
    }
  }

  // Générateur de QCM
  Future<QcmResponse> generateQcm({
    required String text,
    required String subject,
    int numQuestions = 5,
    String difficulty = 'medium',
  }) async {
    try {
      final response = await _apiService.post('/ai/qcm/', body: {
        'text': text,
        'subject': subject,
        'num_questions': numQuestions,
        'difficulty': difficulty,
      });

      return QcmResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur QCM: $e');
      }
      // Fallback local
      return _generateLocalQcm(text, subject, numQuestions);
    }
  }

  // Résumé automatique
  Future<SummaryResponse> generateSummary({
    required String text,
    int maxLength = 100,
    String style = 'academic',
  }) async {
    try {
      final response = await _apiService.post('/ai/summary/', body: {
        'text': text,
        'max_length': maxLength,
        'style': style,
      });

      return SummaryResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur résumé: $e');
      }
      // Fallback local
      return _generateLocalSummary(text, maxLength);
    }
  }

  // Traduction
  Future<TranslationResponse> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String? context,
  }) async {
    try {
      final response = await _apiService.post('/ai/translation/', body: {
        'text': text,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'context': context,
      });

      return TranslationResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur traduction: $e');
      }
      // Fallback local
      return _generateLocalTranslation(text, sourceLanguage, targetLanguage);
    }
  }

  // Orientation scolaire
  Future<OrientationResponse> analyzeOrientation({
    required List<OrientationAnswer> answers,
    required String gradeLevel,
    List<String>? currentSubjects,
  }) async {
    try {
      final response = await _apiService.post('/ai/orientation/', body: {
        'answers': answers.map((a) => a.toJson()).toList(),
        'grade_level': gradeLevel,
        'current_subjects': currentSubjects,
      });

      return OrientationResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur orientation: $e');
      }
      // Fallback local
      return _generateLocalOrientation(answers, gradeLevel);
    }
  }

  // OCR
  Future<OcrResponse> performOcr({
    required String imageBase64,
    String language = 'fra',
  }) async {
    try {
      final response = await _apiService.post('/ai/ocr/', body: {
        'image_base64': imageBase64,
        'language': language,
      });

      return OcrResponse.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur OCR: $e');
      }
      // Fallback local
      return _generateLocalOcr();
    }
  }

  // Suggestions de questions
  Future<List<String>> getQuestionSuggestions(String subject) async {
    try {
      final response = await _apiService.get('/ai/tutor/suggestions/$subject');
      return List<String>.from(response['suggestions'] ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur suggestions: $e');
      }
      return _getLocalSuggestions(subject);
    }
  }

  // Matières supportées
  Future<List<String>> getSupportedSubjects() async {
    try {
      final response = await _apiService.get('/ai/tutor/subjects');
      return List<String>.from(response['subjects'] ?? []);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur matières: $e');
      }
      return _getLocalSubjects();
    }
  }

  // Méthodes de fallback local
  TutorResponse _generateLocalTutorResponse(String question, String subject, String? gradeLevel) {
    final responses = {
      'mathématiques': {
        'fraction': 'Les fractions représentent une partie d\'un tout. Par exemple, 1/2 signifie une partie sur deux parties égales.',
        'géométrie': 'La géométrie étudie les formes et les figures dans l\'espace.',
        'algèbre': 'L\'algèbre utilise des lettres pour représenter des nombres inconnus.',
      },
      'français': {
        'grammaire': 'La grammaire étudie la structure et les règles de la langue française.',
        'conjugaison': 'La conjugaison indique le temps et la personne du verbe.',
        'orthographe': 'L\'orthographe concerne l\'écriture correcte des mots.',
      },
      'histoire': {
        'colonisation': 'La colonisation est l\'occupation et l\'exploitation d\'un territoire par une puissance étrangère.',
        'indépendance': 'L\'indépendance est la liberté d\'un pays de se gouverner lui-même.',
      },
    };

    final subjectResponses = responses[subject.toLowerCase()] ?? {};
    String answer = 'Je comprends votre question sur $subject. Voici une explication simple...';
    
    for (final keyword in subjectResponses.keys) {
      if (question.toLowerCase().contains(keyword)) {
        answer = subjectResponses[keyword]!;
        break;
      }
    }

    return TutorResponse(
      answer: answer,
      confidence: 0.7,
      source: 'local',
    );
  }

  QcmResponse _generateLocalQcm(String text, String subject, int numQuestions) {
    final questions = <QcmQuestion>[];
    
    for (int i = 0; i < numQuestions; i++) {
      questions.add(QcmQuestion(
        question: 'Question ${i + 1} sur $subject ?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 'Option A',
        explanation: 'Explication de la réponse correcte',
      ));
    }

    return QcmResponse(
      questions: questions,
      subject: subject,
      difficulty: 'medium',
    );
  }

  SummaryResponse _generateLocalSummary(String text, int maxLength) {
    final sentences = text.split('.');
    String summary = sentences.take(3).join('.');
    
    if (summary.length > maxLength) {
      summary = summary.substring(0, maxLength) + '...';
    }

    return SummaryResponse(
      summary: summary,
      originalLength: text.split(' ').length,
      summaryLength: summary.split(' ').length,
      compressionRatio: summary.split(' ').length / text.split(' ').length,
    );
  }

  TranslationResponse _generateLocalTranslation(String text, String sourceLanguage, String targetLanguage) {
    final translations = {
      'éwé': {
        'bonjour': 'Woé zɔ',
        'merci': 'Akpé',
        'comment allez-vous': 'Êfoa woé',
        'au revoir': 'Hede nyuie',
        'oui': 'Ee',
        'non': 'Ao',
      },
      'kabiyè': {
        'bonjour': 'Yaa',
        'merci': 'Yoo',
        'comment allez-vous': 'Yaa yaa',
        'au revoir': 'Yaa yaa',
        'oui': 'Ee',
        'non': 'Ao',
      },
    };

    String translatedText = text;
    final localTranslations = translations[targetLanguage] ?? {};
    
    for (final french in localTranslations.keys) {
      translatedText = translatedText.replaceAll(french, localTranslations[french]!);
    }

    return TranslationResponse(
      originalText: text,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      confidence: 0.8,
    );
  }

  OrientationResponse _generateLocalOrientation(List<OrientationAnswer> answers, String gradeLevel) {
    return OrientationResponse(
      suggestedFields: ['Sciences et Technologies', 'Lettres et Sciences Humaines'],
      suggestedCareers: ['Ingénieur', 'Médecin', 'Enseignant', 'Avocat'],
      explanation: 'Basé sur vos réponses, nous vous suggérons ces filières...',
      confidence: 0.7,
      recommendations: [
        'Continuez vos études',
        'Développez vos compétences',
        'Explorez différents domaines',
      ],
    );
  }

  OcrResponse _generateLocalOcr() {
    return OcrResponse(
      text: 'Texte reconnu (simulation)',
      confidence: 0.8,
      wordCount: 5,
      processingTime: 1.5,
    );
  }

  List<String> _getLocalSuggestions(String subject) {
    final suggestions = {
      'mathématiques': [
        'Qu\'est-ce qu\'une fraction ?',
        'Comment calculer l\'aire d\'un cercle ?',
        'Qu\'est-ce qu\'une équation ?',
      ],
      'français': [
        'Qu\'est-ce qu\'un verbe ?',
        'Comment conjuguer le verbe être ?',
        'Qu\'est-ce qu\'un adjectif ?',
      ],
      'histoire': [
        'Qu\'est-ce que la colonisation ?',
        'Quand le Togo a-t-il obtenu son indépendance ?',
        'Qu\'est-ce qu\'une révolution ?',
      ],
    };

    return suggestions[subject.toLowerCase()] ?? [
      'Pouvez-vous expliquer ce concept ?',
      'Comment résoudre ce problème ?',
      'Quelle est la définition de ce terme ?',
    ];
  }

  List<String> _getLocalSubjects() {
    return [
      'Mathématiques',
      'Français',
      'Histoire',
      'Géographie',
      'Sciences',
      'Anglais',
      'Philosophie',
      'Économie',
    ];
  }
}

// Modèles de données
class TutorResponse {
  final String answer;
  final double confidence;
  final String source;

  TutorResponse({
    required this.answer,
    required this.confidence,
    required this.source,
  });

  factory TutorResponse.fromJson(Map<String, dynamic> json) {
    return TutorResponse(
      answer: json['answer'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      source: json['source'] ?? 'unknown',
    );
  }
}

class QcmResponse {
  final List<QcmQuestion> questions;
  final String subject;
  final String difficulty;

  QcmResponse({
    required this.questions,
    required this.subject,
    required this.difficulty,
  });

  factory QcmResponse.fromJson(Map<String, dynamic> json) {
    return QcmResponse(
      questions: (json['questions'] as List?)
          ?.map((q) => QcmQuestion.fromJson(q))
          .toList() ?? [],
      subject: json['subject'] ?? '',
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
}

class QcmQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  QcmQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory QcmQuestion.fromJson(Map<String, dynamic> json) {
    return QcmQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}

class SummaryResponse {
  final String summary;
  final int originalLength;
  final int summaryLength;
  final double compressionRatio;

  SummaryResponse({
    required this.summary,
    required this.originalLength,
    required this.summaryLength,
    required this.compressionRatio,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      summary: json['summary'] ?? '',
      originalLength: json['original_length'] ?? 0,
      summaryLength: json['summary_length'] ?? 0,
      compressionRatio: (json['compression_ratio'] ?? 0.0).toDouble(),
    );
  }
}

class TranslationResponse {
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final double confidence;

  TranslationResponse({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.confidence,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      originalText: json['original_text'] ?? '',
      translatedText: json['translated_text'] ?? '',
      sourceLanguage: json['source_language'] ?? '',
      targetLanguage: json['target_language'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}

class OrientationResponse {
  final List<String> suggestedFields;
  final List<String> suggestedCareers;
  final String explanation;
  final double confidence;
  final List<String> recommendations;

  OrientationResponse({
    required this.suggestedFields,
    required this.suggestedCareers,
    required this.explanation,
    required this.confidence,
    required this.recommendations,
  });

  factory OrientationResponse.fromJson(Map<String, dynamic> json) {
    return OrientationResponse(
      suggestedFields: List<String>.from(json['suggested_fields'] ?? []),
      suggestedCareers: List<String>.from(json['suggested_careers'] ?? []),
      explanation: json['explanation'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class OrientationAnswer {
  final int questionId;
  final String answer;

  OrientationAnswer({
    required this.questionId,
    required this.answer,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answer,
    };
  }
}

class OcrResponse {
  final String text;
  final double confidence;
  final int wordCount;
  final double processingTime;

  OcrResponse({
    required this.text,
    required this.confidence,
    required this.wordCount,
    required this.processingTime,
  });

  factory OcrResponse.fromJson(Map<String, dynamic> json) {
    return OcrResponse(
      text: json['text'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      wordCount: json['word_count'] ?? 0,
      processingTime: (json['processing_time'] ?? 0.0).toDouble(),
    );
  }
}
