import 'package:flutter/material.dart';

class OrientationPage extends StatelessWidget {
  const OrientationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orientation scolaire'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Réponds au questionnaire pour une suggestion de filière ou métier.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulation de questionnaire
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Questionnaire terminé !'),
                    backgroundColor: Colors.amber,
                  ),
                );
              },
              child: const Text('Commencer le questionnaire'),
            ),
            const SizedBox(height: 24),
            // Affichage de la suggestion simulée
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestion de filière/métier :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Basé sur tes réponses, nous te suggérons :\n\n'
                    '🎯 Filière : Sciences et Technologies\n'
                    '📚 Spécialités recommandées :\n'
                    '   • Mathématiques\n'
                    '   • Physique-Chimie\n'
                    '   • Sciences de l\'Ingénieur\n\n'
                    '💼 Métiers possibles :\n'
                    '   • Ingénieur\n'
                    '   • Architecte\n'
                    '   • Médecin\n'
                    '   • Enseignant en sciences',
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