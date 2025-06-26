import 'package:flutter/material.dart';

class TranslationPage extends StatelessWidget {
  const TranslationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Traduction en langues locales')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Traduire un texte en éwé ou kabiyè.'),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Texte à traduire',
                border: OutlineInputBorder(),
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
              onPressed: () {},
              child: const Text('Traduire'),
            ),
            const SizedBox(height: 24),
            // Affichage de la traduction simulée
            const Text('Traduction (simulée)...'),
          ],
        ),
      ),
    );
  }
} 