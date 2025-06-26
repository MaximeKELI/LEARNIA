import 'database_helper.dart';
import '../services/ai_service.dart';
import '../services/config_service.dart';

class TutorModel {
  final AiService _aiService = AiService();
  final ConfigService _config = ConfigService();
  final DatabaseHelper _db = DatabaseHelper();

  /// Pose une question au tuteur et obtient une réponse
  Future<TutorResponse> askQuestion({
    required String question,
    required String subject,
    String? gradeLevel,
    int? userId,
  }) async {
    try {
      // Vérifier si on est en mode hors ligne
      if (_config.isOfflineMode) {
        return _generateOfflineResponse(question, subject);
      }

      // Générer la réponse via l'API
      final response = await _aiService.generateTutorResponse(question, subject);
      
      // Sauvegarder la conversation en base
      if (userId != null) {
        await _db.insertTutorConversation({
          'user_id': userId,
          'question': question,
          'answer': response,
          'subject': subject,
        });
      }

      return TutorResponse(
        answer: response,
        source: 'ai_api',
        confidence: 0.9,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback vers le mode local
      return _generateOfflineResponse(question, subject);
    }
  }

  /// Obtient l'historique des conversations
  Future<List<TutorConversation>> getConversationHistory(int userId) async {
    try {
      final conversations = await _db.getTutorConversations(userId);
      return conversations.map((conv) => TutorConversation.fromMap(conv)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Génère une réponse en mode hors ligne
  TutorResponse _generateOfflineResponse(String question, String subject) {
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
        'colonisation': 'La colonisation est l\'occupation d\'un territoire par une puissance étrangère.',
        'indépendance': 'L\'indépendance est la liberté d\'un pays de se gouverner lui-même.',
        'révolution': 'Une révolution est un changement profond et rapide dans la société.',
      },
      'sciences': {
        'électricité': 'L\'électricité est un phénomène physique lié aux charges électriques.',
        'chimie': 'La chimie étudie la composition et les transformations de la matière.',
        'biologie': 'La biologie étudie les êtres vivants et leurs interactions.',
      },
    };

    String answer = 'Je comprends votre question sur $subject. Voici une explication simple...';
    
    final subjectResponses = responses[subject.toLowerCase()];
    if (subjectResponses != null) {
      for (final entry in subjectResponses.entries) {
        if (question.toLowerCase().contains(entry.key)) {
          answer = entry.value;
          break;
        }
      }
    }

    return TutorResponse(
      answer: answer,
      source: 'offline',
      confidence: 0.7,
      timestamp: DateTime.now(),
    );
  }

  /// Obtient des suggestions de questions basées sur la matière
  List<String> getSuggestedQuestions(String subject) {
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
      'sciences': [
        'Qu\'est-ce que l\'électricité ?',
        'Comment fonctionne la photosynthèse ?',
        'Qu\'est-ce qu\'une réaction chimique ?',
      ],
    };

    return suggestions[subject.toLowerCase()] ?? [
      'Pouvez-vous expliquer ce concept ?',
      'Comment résoudre ce problème ?',
      'Quelle est la définition de ce terme ?',
    ];
  }
}

class TutorResponse {
  final String answer;
  final String source; // 'ai_api', 'offline', 'local'
  final double confidence;
  final DateTime timestamp;

  TutorResponse({
    required this.answer,
    required this.source,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'answer': answer,
      'source': source,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TutorResponse.fromMap(Map<String, dynamic> map) {
    return TutorResponse(
      answer: map['answer'] ?? '',
      source: map['source'] ?? 'unknown',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class TutorConversation {
  final int id;
  final int userId;
  final String question;
  final String answer;
  final String? subject;
  final DateTime createdAt;

  TutorConversation({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    this.subject,
    required this.createdAt,
  });

  factory TutorConversation.fromMap(Map<String, dynamic> map) {
    return TutorConversation(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? 0,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      subject: map['subject'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'question': question,
      'answer': answer,
      'subject': subject,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 