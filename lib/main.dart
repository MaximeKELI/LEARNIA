//Maxime KELI
import 'modules/qcm/qcm_page.dart';
import 'modules/ocr/ocr_page.dart';
import 'package:flutter/material.dart';
import 'modules/tutor/tutor_page.dart';
import 'package:provider/provider.dart';
import 'modules/leitner/leitner_page.dart';
import 'modules/summary/summary_page.dart';
import 'modules/planner/planner_page.dart';
import 'modules/translation/translation_page.dart';
import 'modules/performance/performance_page.dart';
import 'modules/orientation/orientation_page.dart';
// Importations des pages modules (à créer)

void main() {
  runApp(const LearniaApp());
}

class LearniaApp extends StatelessWidget {
  const LearniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learnia',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        // Ajout pour la localisation française
      ],
      supportedLocales: const [
        Locale('fr', ''),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Tuteur intelligent', Icons.chat, const TutorPage()),
      _Module('Générateur de QCM', Icons.quiz, const QcmPage()),
      _Module('Mémorisation (Leitner)', Icons.memory, const LeitnerPage()),
      _Module('Résumé automatique', Icons.summarize, const SummaryPage()),
      _Module('Traduction en langues locales', Icons.translate, const TranslationPage()),
      _Module('Analyse des performances', Icons.bar_chart, const PerformancePage()),
      _Module('Planificateur de révision', Icons.schedule, const PlannerPage()),
      _Module('Reconnaissance de devoirs', Icons.camera_alt, const OcrPage()),
      _Module('Orientation scolaire', Icons.school, const OrientationPage()),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learnia'),
      ),
      body: ListView.builder(
        itemCount: modules.length,
        itemBuilder: (context, index) {
          final module = modules[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(module.icon, color: Colors.blue),
              title: Text(module.title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => module.page),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Module {
  final String title;
  final IconData icon;
  final Widget page;
  _Module(this.title, this.icon, this.page);
} 