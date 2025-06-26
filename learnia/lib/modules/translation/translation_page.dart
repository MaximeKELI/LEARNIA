import 'package:flutter/material.dart';

class TranslationPage extends StatefulWidget {
  const TranslationPage({super.key});

  @override
  State<TranslationPage> createState() => _TranslationPageState();
}

class _TranslationPageState extends State<TranslationPage> {
  final TextEditingController _questionController = TextEditingController();
  String? _translationResult;
  bool _isLoading = false;
  String _selectedLang = 'éwé';

  Future<void> _askTranslation() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un texte à traduire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _translationResult = null;
    });
    // TODO: Appeler l'IA pour traduire le texte
    await Future.delayed(const Duration(seconds: 2)); // Simulation
    setState(() {
      _translationResult = 'Traduction IA ($_selectedLang) (exemple).';
      _isLoading = false;
    });
  }

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
              'Entre un texte à traduire et choisis la langue.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Texte à traduire',
                border: OutlineInputBorder(),
                hintText: 'Entrez le texte en français...',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedLang,
              items: const [
                DropdownMenuItem(value: 'éwé', child: Text('Éwé')),
                DropdownMenuItem(value: 'kabiyè', child: Text('Kabiyè')),
              ],
              onChanged: (v) {
                setState(() {
                  _selectedLang = v!;
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _askTranslation,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Traduction en cours...'),
                        ],
                      )
                    : const Text('Traduire avec l’IA'),
              ),
            ),
            const SizedBox(height: 24),
            if (_translationResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Text(
                  _translationResult!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 