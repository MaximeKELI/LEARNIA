import 'package:flutter/material.dart';

class PlannerPage extends StatelessWidget {
  const PlannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificateur de révision'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Entre tes matières et examens pour un planning personnalisé.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulation de création de planning
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Planning généré !'),
                    backgroundColor: Colors.indigo,
                  ),
                );
              },
              child: const Text('Créer un planning'),
            ),
            const SizedBox(height: 24),
            // Affichage du planning simulé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planning de la semaine :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text('Lundi : Mathématiques (Fractions) - 1h'),
                  Text('Mardi : Français (Grammaire) - 45min'),
                  Text('Mercredi : Histoire (Colonisation) - 1h'),
                  Text('Jeudi : Sciences (Électricité) - 1h'),
                  Text('Vendredi : Révision générale - 1h30'),
                  Text('Samedi : Exercices pratiques - 2h'),
                  Text('Dimanche : Repos et préparation - 30min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 