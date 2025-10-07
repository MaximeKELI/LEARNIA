import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/ai_service.dart';
import '../../services/database_helper.dart';

class TutorPage extends StatefulWidget {
  const TutorPage({super.key});

  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  final _questionController = TextEditingController();
  final _subjectController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _aiService = AIService();
  final _dbHelper = DatabaseHelper();

  List<TutorSession> _sessions = [];
  bool _isLoading = false;
  String? _currentAnswer;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.user != null) {
      final sessions = await _dbHelper.getTutorSessions(authNotifier.user!.id, limit: 10);
      setState(() {
        _sessions = sessions.map((s) => TutorSession.fromJson(s)).toList();
      });
    }
  }

  Future<void> _askQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez poser une question')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _currentAnswer = null;
    });

    try {
      final authNotifier = context.read<AuthNotifier>();
      if (authNotifier.user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await _aiService.askTutor(
        question: _questionController.text.trim(),
        subject: _subjectController.text.trim().isNotEmpty 
            ? _subjectController.text.trim() 
            : 'Général',
        gradeLevel: _gradeLevelController.text.trim().isNotEmpty 
            ? _gradeLevelController.text.trim() 
            : null,
      );

      setState(() {
        _currentAnswer = response.answer;
      });

      // Sauvegarder la session
      await _dbHelper.saveTutorSession({
        'user_id': authNotifier.user!.id,
        'question': _questionController.text.trim(),
        'answer': response.answer,
        'subject': _subjectController.text.trim().isNotEmpty 
            ? _subjectController.text.trim() 
            : 'Général',
        'grade_level': _gradeLevelController.text.trim().isNotEmpty 
            ? _gradeLevelController.text.trim() 
            : null,
        'confidence': response.confidence,
        'source': response.source,
      });

      // Recharger les sessions
      await _loadSessions();

      // Vider le champ de question
      _questionController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuteur intelligent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire de question
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pose une question sur un cours et reçois une explication simple.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: 'Ta question',
                        hintText: 'Ex: Qu\'est-ce qu\'une fraction ?',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.help_outline),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subjectController,
                            decoration: const InputDecoration(
                              labelText: 'Matière (optionnel)',
                              hintText: 'Ex: Mathématiques',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.book),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _gradeLevelController,
                            decoration: const InputDecoration(
                              labelText: 'Niveau (optionnel)',
                              hintText: 'Ex: Collège',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.grade),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _askQuestion,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isLoading ? 'En cours...' : 'Demander au tuteur'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Réponse du tuteur
            if (_currentAnswer != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Réponse du tuteur',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentAnswer!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Historique des sessions
            if (_sessions.isNotEmpty) ...[
              const Text(
                'Questions récentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.help_outline, color: Colors.blue.shade700),
                        ),
                        title: Text(
                          session.question,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${session.subject} • ${session.createdAt.day}/${session.createdAt.month}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        trailing: Icon(
                          Icons.check_circle,
                          color: session.confidence > 0.7 ? Colors.green : Colors.orange,
                        ),
                        onTap: () => _showSessionDetails(session),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historique des questions'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _sessions.length,
            itemBuilder: (context, index) {
              final session = _sessions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(session.question),
                  subtitle: Text('${session.subject} • ${session.createdAt.day}/${session.createdAt.month}'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSessionDetails(session);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showSessionDetails(TutorSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la question'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(session.question),
              const SizedBox(height: 16),
              Text(
                'Réponse:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(session.answer),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Matière: ${session.subject}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Text(
                    'Confiance: ${(session.confidence * 100).toInt()}%',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _subjectController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }
}

// Modèle pour les sessions de tuteur
class TutorSession {
  final int id;
  final String question;
  final String answer;
  final String subject;
  final String? gradeLevel;
  final double confidence;
  final String source;
  final DateTime createdAt;

  TutorSession({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    this.gradeLevel,
    required this.confidence,
    required this.source,
    required this.createdAt,
  });

  factory TutorSession.fromJson(Map<String, dynamic> json) {
    return TutorSession(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      subject: json['subject'] ?? '',
      gradeLevel: json['grade_level'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      source: json['source'] ?? 'unknown',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 