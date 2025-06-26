import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Résumé automatique')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Colle un texte pour obtenir un résumé.'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texte à résumer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Générer le résumé'),
            ),
            const SizedBox(height: 24),
            // Affichage du résumé simulé
            const Text('Résumé généré (simulé)...'),
          ],
        ),
      ),
    );
  }
} 