import 'package:flutter/material.dart';

class QcmPage extends StatelessWidget {
  const QcmPage({super.key});

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
              'Colle un texte de cours pour générer un QCM automatiquement.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texte du cours',
                border: OutlineInputBorder(),
                hintText: 'Colle ici le contenu de ton cours...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulation de génération de QCM
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('QCM généré avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Générer le QCM'),
            ),
            const SizedBox(height: 24),
            // Affichage des questions simulées
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Questions générées :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text('1. Qu\'est-ce qu\'une fraction ?'),
                  Text('   A) Un nombre entier'),
                  Text('   B) Une partie d\'un tout ✓'),
                  Text('   C) Un nombre négatif'),
                  Text('   D) Un nombre décimal'),
                  SizedBox(height: 8),
                  Text('2. Comment s\'écrit la moitié ?'),
                  Text('   A) 1/3'),
                  Text('   B) 1/2 ✓'),
                  Text('   C) 2/1'),
                  Text('   D) 1/4'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 