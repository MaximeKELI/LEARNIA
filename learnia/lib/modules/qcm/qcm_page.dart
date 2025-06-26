import 'package:flutter/material.dart';

class QcmPage extends StatefulWidget {
  const QcmPage({super.key});

  @override
  State<QcmPage> createState() => _QcmPageState();
}

class _QcmPageState extends State<QcmPage> {
  final TextEditingController _questionController = TextEditingController();
  String? _qcmResult;
  bool _isLoading = false;

  Future<void> _generateQcm() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un texte de cours ou une question'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _qcmResult = null;
    });
    // TODO: Appeler l'API IA pour générer le QCM à partir du texte
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    setState(() {
      _qcmResult = 'QCM généré par l\'IA (exemple) :\n1. Exemple de question ?\nA) Réponse 1\nB) Réponse 2\nC) Réponse 3';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur de QCM'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Colle un texte de cours ou pose une question pour générer un QCM automatiquement.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texte du cours ou question',
                border: OutlineInputBorder(),
                hintText: 'Colle ici le contenu de ton cours ou pose ta question...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateQcm,
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
                    : const Text('Générer le QCM'),
              ),
            ),
            const SizedBox(height: 24),
            if (_qcmResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  _qcmResult!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 