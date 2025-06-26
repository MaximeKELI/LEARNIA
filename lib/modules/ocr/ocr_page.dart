import 'package:flutter/material.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconnaissance de devoirs')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Prends une photo de ton devoir pour le lire automatiquement.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Prendre une photo'),
            ),
            const SizedBox(height: 24),
            // Affichage du texte détecté simulé
            const Text('Texte détecté (simulé)...'),
          ],
        ),
      ),
    );
  }
} 