import 'package:flutter/material.dart';

class TranslationPage extends StatelessWidget {
  const TranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traduction en langues locales'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Traduire un texte en éwé ou kabiyè.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Texte à traduire',
                border: OutlineInputBorder(),
                hintText: 'Entrez le texte en français...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: 'éwé',
              items: const [
                DropdownMenuItem(value: 'éwé', child: Text('Éwé')),
                DropdownMenuItem(value: 'kabiyè', child: Text('Kabiyè')),
              ],
              onChanged: (v) {},
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulation de traduction
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Traduction effectuée !'),
                    backgroundColor: Colors.teal,
                  ),
                );
              },
              child: const Text('Traduire'),
            ),
            const SizedBox(height: 24),
            // Affichage de la traduction simulée
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traduction en Éwé :',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bonjour = Woé zɔ\n'
                    'Merci = Akpé\n'
                    'Comment allez-vous ? = Êfoa woé ?\n'
                    'Je vais bien = Mênye nyuie',
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