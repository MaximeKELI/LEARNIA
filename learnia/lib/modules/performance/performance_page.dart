import 'package:flutter/material.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse des performances'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Historique des résultats et progression.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Diagramme simulé
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      'Diagramme de progression',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('(simulé)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Suggestions simulées
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggestions d\'amélioration :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• Réviser davantage les fractions'),
                  Text('• Pratiquer plus d\'exercices de géométrie'),
                  Text('• Améliorer la vitesse de calcul mental'),
                  Text('• Consulter le tuteur pour les points difficiles'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 