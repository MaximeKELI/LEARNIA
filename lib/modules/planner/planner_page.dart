import 'package:flutter/material.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planificateur de révision')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Entre tes matières et examens pour un planning personnalisé.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Créer un planning'),
            ),
            const SizedBox(height: 24),
            // Affichage du planning simulé
            const Text('Planning généré (simulé)...'),
          ],
        ),
      ),
    );
  }
} 