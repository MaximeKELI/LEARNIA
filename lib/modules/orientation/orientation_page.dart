import 'package:flutter/material.dart';

class OrientationPage extends StatelessWidget {
  const OrientationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orientation scolaire')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Réponds au questionnaire pour une suggestion de filière ou métier.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Commencer le questionnaire'),
            ),
            const SizedBox(height: 24),
            // Affichage de la suggestion simulée
            const Text('Suggestion de filière/métier (simulée)...'),
          ],
        ),
      ),
    );
  }
} 