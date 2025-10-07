import 'modules/qcm/qcm_page.dart';
import 'modules/ocr/ocr_page.dart';
import 'services/auth_service.dart';
import 'services/config_service.dart';
import 'package:flutter/material.dart';
import 'modules/tutor/tutor_page.dart';
import 'services/database_helper.dart';
import 'package:provider/provider.dart';
import 'modules/leitner/leitner_page.dart';
import 'modules/summary/summary_page.dart';
import 'modules/planner/planner_page.dart';
import 'modules/translation/translation_page.dart';
import 'modules/performance/performance_page.dart';
import 'modules/orientation/orientation_page.dart';
//Maxime KELI
// Importations des pages modules et services

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser les services
  await DatabaseHelper().database;
  await AuthService().loadUserFromLocal();
  
  runApp(const LearniaApp());
}

class LearniaApp extends StatelessWidget {
  const LearniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => AppStateNotifier()),
      ],
      child: MaterialApp(
        title: ConfigService.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          // Ajout pour la localisation française
        ],
        supportedLocales: const [
          Locale('fr', ''),
        ],
      ),
    );
  }
}

// Wrapper d'authentification
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        if (authNotifier.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (authNotifier.isLoggedIn) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

// Page de connexion
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegisterMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Inscription' : 'Connexion'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 32),
              Text(
                'Bienvenue sur Learnia',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Votre assistant éducatif intelligent',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isRegisterMode ? 'S\'inscrire' : 'Se connecter'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegisterMode = !_isRegisterMode;
                  });
                },
                child: Text(
                  _isRegisterMode
                      ? 'Déjà un compte ? Se connecter'
                      : 'Pas de compte ? S\'inscrire',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      AuthResult result;

      if (_isRegisterMode) {
        result = await authService.register(
          email: _emailController.text,
          username: _emailController.text.split('@')[0],
          password: _passwordController.text,
        );
      } else {
        result = await authService.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (result.success) {
        if (mounted) {
          context.read<AuthNotifier>().setLoggedIn(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.error ?? 'Erreur inconnue')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module('Tuteur intelligent', Icons.chat, const TutorPage(), 'Pose des questions et reçois des explications'),
      _Module('Générateur de QCM', Icons.quiz, const QcmPage(), 'Crée des quiz à partir de tes cours'),
      _Module('Mémorisation (Leitner)', Icons.memory, const LeitnerPage(), 'Mémorise efficacement avec les flashcards'),
      _Module('Résumé automatique', Icons.summarize, const SummaryPage(), 'Résume tes leçons automatiquement'),
      _Module('Traduction', Icons.translate, const TranslationPage(), 'Traduis vers les langues locales'),
      _Module('Performances', Icons.bar_chart, const PerformancePage(), 'Suis tes progrès et améliore-toi'),
      _Module('Planificateur', Icons.schedule, const PlannerPage(), 'Organise tes révisions'),
      _Module('Reconnaissance OCR', Icons.camera_alt, const OcrPage(), 'Reconnais le texte de tes devoirs'),
      _Module('Orientation', Icons.school, const OrientationPage(), 'Découvre ta voie professionnelle'),
    ];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learnia'),
        actions: [
          Consumer<AuthNotifier>(
            builder: (context, authNotifier, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    authNotifier.logout();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profil'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Paramètres'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Déconnexion'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthNotifier>(
        builder: (context, authNotifier, child) {
          return Column(
            children: [
              // En-tête avec informations utilisateur
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ${authNotifier.user?.displayName ?? 'Élève'} !',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prêt à apprendre quelque chose de nouveau ?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              // Liste des modules
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            module.icon,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          module.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          module.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => module.page),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
  final String description;
  _Module(this.title, this.icon, this.page, this.description);
}

// Notifier pour l'authentification
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthNotifier() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuthenticated = await _authService.checkAuthStatus();
      if (isAuthenticated) {
        _user = _authService.currentUser;
        _isLoggedIn = true;
      }
    } catch (e) {
      // Gérer l'erreur silencieusement
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setLoggedIn(bool loggedIn) {
    _isLoggedIn = loggedIn;
    _user = _authService.currentUser;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isLoggedIn = false;
    } catch (e) {
      // Gérer l'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Notifier pour l'état de l'application
class AppStateNotifier extends ChangeNotifier {
  bool _isOnline = true;
  String _currentModule = '';
  Map<String, dynamic> _userPreferences = {};

  bool get isOnline => _isOnline;
  String get currentModule => _currentModule;
  Map<String, dynamic> get userPreferences => _userPreferences;

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void setCurrentModule(String module) {
    _currentModule = module;
    notifyListeners();
  }

  void updatePreferences(Map<String, dynamic> preferences) {
    _userPreferences.addAll(preferences);
    notifyListeners();
  }
} 