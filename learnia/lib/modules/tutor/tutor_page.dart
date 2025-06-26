import 'package:flutter/material.dart';
import '../../models/tutor_model.dart';
import '../../services/config_service.dart';

class TutorPage extends StatefulWidget {
  const TutorPage({super.key});

  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  final TutorModel _tutorModel = TutorModel();
  final ConfigService _config = ConfigService();
  
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  
  TutorResponse? _lastResponse;
  bool _isLoading = false;
  String _selectedSubject = 'Mathématiques';

  @override
  void initState() {
    super.initState();
    _subjectController.text = _selectedSubject;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez entrer une question'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _tutorModel.askQuestion(
        question: _questionController.text.trim(),
        subject: _selectedSubject,
        gradeLevel: 'Collège', // À adapter selon l'utilisateur
        userId: 1, // À adapter selon l'utilisateur connecté
      );

      if (mounted) {
        setState(() {
          _lastResponse = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuteur intelligent'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_config.isOfflineMode ? Icons.cloud_off : Icons.cloud),
            onPressed: () {
              setState(() {
                _config.setOfflineMode(!_config.isOfflineMode);
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_config.isOfflineMode 
                      ? 'Mode hors ligne activé' 
                      : 'Mode en ligne activé'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mode de fonctionnement
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _config.isOfflineMode ? Colors.orange.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _config.isOfflineMode ? Icons.cloud_off : Icons.cloud,
                    color: _config.isOfflineMode ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _config.isOfflineMode ? 'Mode hors ligne' : 'Mode en ligne',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _config.isOfflineMode ? Colors.orange.shade800 : Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélection de la matière
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Matière',
                border: OutlineInputBorder(),
              ),
              items: _config.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Champ de question
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Ta question',
                border: OutlineInputBorder(),
                hintText: 'Ex: Explique les fractions',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Bouton pour poser la question
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _askQuestion,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Génération en cours...'),
                        ],
                      )
                    : const Text('Demander au tuteur'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Suggestions de questions
            // (SUPPRIMÉ : plus de suggestions prédéfinies)
            
            const SizedBox(height: 24),
            
            // Affichage de la réponse
            if (_lastResponse != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Réponse du tuteur :',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _lastResponse!.source == 'ai_api' 
                              ? Colors.green.shade100 
                              : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _lastResponse!.source == 'ai_api' ? 'IA' : 'Local',
                            style: TextStyle(
                              fontSize: 12,
                              color: _lastResponse!.source == 'ai_api' 
                                ? Colors.green.shade800 
                                : Colors.orange.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastResponse!.answer,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confiance: ${(_lastResponse!.confidence * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 