import 'package:flutter/material.dart';

class LeitnerPage extends StatefulWidget {
  const LeitnerPage({super.key});

  @override
  State<LeitnerPage> createState() => _LeitnerPageState();
}

class _LeitnerPageState extends State<LeitnerPage> {
  final TextEditingController _questionController = TextEditingController();
  String? _leitnerResult;
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
      _leitnerResult = null;
    });
    // TODO: Appeler l'IA pour générer une réponse Leitner
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    setState(() {
      _leitnerResult = 'Réponse IA (exemple) : Voici une carte générée pour ta révision.';
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
            if (_leitnerResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  _leitnerResult!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 