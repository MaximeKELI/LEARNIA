import 'package:flutter/material.dart';

class LeitnerPage extends StatelessWidget {
  const LeitnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mémorisation Leitner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Système de flashcards pour réviser intelligemment.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Commencer une session'),
            ),
            const SizedBox(height: 24),
            // Affichage d'une carte simulée
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Text('Question (simulée)'),
                    SizedBox(height: 8),
                    Text('Réponse (simulée)', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 