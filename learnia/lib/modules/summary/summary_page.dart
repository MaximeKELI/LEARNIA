import 'package:flutter/material.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé automatique'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Colle un texte pour obtenir un résumé des points clés.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Texte à résumer',
                border: OutlineInputBorder(),
                hintText: 'Colle ici le texte de ton cours...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulation de génération de résumé
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Résumé généré !'),
                    backgroundColor: Colors.purple,
                  ),
                );
              },
              child: const Text('Générer le résumé'),
            ),
            const SizedBox(height: 24),
            // Affichage du résumé simulé
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé généré :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Les fractions représentent des parties d\'un tout\n'
                    '• Le numérateur indique le nombre de parties prises\n'
                    '• Le dénominateur indique le nombre total de parties\n'
                    '• Les fractions équivalentes ont la même valeur\n'
                    '• Pour additionner des fractions, il faut un dénominateur commun',
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