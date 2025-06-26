import 'package:flutter/material.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconnaissance de devoirs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Prends une photo de ton devoir pour le lire automatiquement.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Simulation de prise de photo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo prise et texte détecté !'),
                    backgroundColor: Colors.deepPurple,
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 24),
            // Affichage du texte détecté simulé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Texte détecté :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Exercice 1 :\n'
                    'Calculer : 3/4 + 1/2\n'
                    'Solution :\n'
                    '3/4 + 1/2 = 3/4 + 2/4 = 5/4\n'
                    'Réponse : 5/4 ou 1,25',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 