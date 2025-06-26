import 'modules/qcm/qcm_page.dart';
import 'modules/ocr/ocr_page.dart';
import 'modules/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'modules/tutor/tutor_page.dart';
import 'modules/leitner/leitner_page.dart';
import 'modules/summary/summary_page.dart';
import 'modules/planner/planner_page.dart';
import 'modules/translation/translation_page.dart';
import 'modules/performance/performance_page.dart';
import 'modules/orientation/orientation_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
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
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                'Bienvenue sur Learnia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre assistant d\'apprentissage intelligent',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final module = modules[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => module.page),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              module.icon,
                              size: 48,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              module.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
