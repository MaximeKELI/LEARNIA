import 'package:flutter/material.dart';

class PerformancePage extends StatelessWidget {
  const PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyse des performances')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Historique des résultats et progression.'),
            const SizedBox(height: 16),
            // Diagramme simulé
            Container(
              height: 200,
              color: Colors.blue.shade50,
              child: const Center(child: Text('Diagramme de progression (simulé)')),
            ),
            const SizedBox(height: 24),
            // Suggestions simulées
            const Text('Suggestions d’amélioration (simulées)...'),
          ],
        ),
      ),
    );
  }
} 