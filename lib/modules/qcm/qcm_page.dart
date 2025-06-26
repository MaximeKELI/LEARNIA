import 'package:flutter/material.dart';

class QcmPage extends StatelessWidget {
  const QcmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Générateur de QCM')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Colle un texte de cours pour générer un QCM.'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texte du cours',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Générer le QCM'),
            ),
            const SizedBox(height: 24),
            // Affichage des questions simulées
            const Text('Questions générées (simulées)...'),
          ],
        ),
      ),
    );
  }
} 