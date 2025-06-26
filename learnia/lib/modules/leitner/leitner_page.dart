import 'package:flutter/material.dart';

class LeitnerPage extends StatefulWidget {
  const LeitnerPage({super.key});

  @override
  State<LeitnerPage> createState() => _LeitnerPageState();
}

class _LeitnerPageState extends State<LeitnerPage> {
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, String>> _cards = [];
  bool _isLoading = false;

  Future<void> _askLeitner() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une question ou un prompt'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _cards = [];
    });
    // TODO: Appeler l'IA pour générer des cartes de révision
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    setState(() {
      _cards = [
        {'question': 'Quelle est la capitale du Togo ?', 'answer': 'Lomé'},
        {'question': 'Quelle est la formule de l\'eau ?', 'answer': 'H2O'},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mémorisation Leitner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pose une question ou demande une carte de révision à l’IA.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question ou prompt',
                border: OutlineInputBorder(),
                hintText: 'Ex: Génère une carte sur les capitales africaines',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _askLeitner,
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
                    : const Text('Envoyer à l’IA'),
              ),
            ),
            const SizedBox(height: 24),
            if (_cards.isNotEmpty)
              ..._cards.map((card) => Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card['question'] ?? '',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Réponse :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card['answer'] ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
} 