class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // Configuration des environnements
  static const String _devApiUrl = 'https://dev-api.learnia.tg';
  static const String _prodApiUrl = 'https://api.learnia.tg';
  static const String _localApiUrl = 'http://localhost:3000';

  // Configuration des APIs d'IA
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _huggingfaceApiKey = 'YOUR_HUGGINGFACE_API_KEY';
  static const String _localAiUrl = 'http://localhost:8000';

  // Configuration des timeouts
  static const int _defaultTimeout = 30;
  static const int _aiTimeout = 60;

  // Mode de fonctionnement
  bool _isOfflineMode = false;
  bool _useLocalAi = false;
  String _environment = 'dev';

  // Getters pour la configuration
  String get apiBaseUrl {
    switch (_environment) {
      case 'prod':
        return _prodApiUrl;
      case 'dev':
        return _devApiUrl;
      case 'local':
        return _localApiUrl;
      default:
        return _devApiUrl;
    }
  }

  String get aiBaseUrl => _useLocalAi ? _localAiUrl : apiBaseUrl;
  
  bool get isOfflineMode => _isOfflineMode;
  bool get useLocalAi => _useLocalAi;
  String get environment => _environment;

  int get defaultTimeout => _defaultTimeout;
  int get aiTimeout => _aiTimeout;

  // Configuration des APIs
  Map<String, String> get apiKeys => {
    'openai': _openaiApiKey,
    'huggingface': _huggingfaceApiKey,
  };

  // Méthodes de configuration
  void setEnvironment(String env) {
    _environment = env;
  }

  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
  }

  void setLocalAi(bool local) {
    _useLocalAi = local;
  }

  // Configuration des endpoints
  Map<String, String> get endpoints => {
    'tutor': '/ai/tutor',
    'qcm': '/ai/qcm',
    'summary': '/ai/summary',
    'translation': '/ai/translation',
    'orientation': '/ai/orientation',
    'ocr': '/ai/ocr',
    'performance': '/analytics/performance',
    'planner': '/planner/generate',
  };

  // Configuration des modèles d'IA
  Map<String, String> get aiModels => {
    'tutor': 'gpt-3.5-turbo',
    'qcm': 'gpt-4',
    'summary': 'gpt-3.5-turbo',
    'translation': 'Helsinki-NLP/opus-mt-fr-ewe',
    'ocr': 'microsoft/layoutlm-base-uncased',
  };

  // Configuration des prompts
  Map<String, String> get prompts => {
    'tutor': '''
Tu es un tuteur éducatif pour des élèves togolais du primaire à la terminale.
Réponds de manière simple et claire en français.
Adapte ton explication au niveau de l'élève.
Question: {question}
Matière: {subject}
''',
    'qcm': '''
Génère 5 questions à choix multiples basées sur ce texte:
{text}
Format: question, 4 options (A, B, C, D), réponse correcte
''',
    'summary': '''
Résume ce texte en français de manière claire et structurée:
{text}
Longueur maximale: 200 mots
''',
  };

  // Configuration des langues supportées
  List<String> get supportedLanguages => ['fr', 'ewe', 'kab'];
  
  Map<String, String> get languageNames => {
    'fr': 'Français',
    'ewe': 'Éwé',
    'kab': 'Kabiyè',
  };

  // Configuration des matières
  List<String> get subjects => [
    'Mathématiques',
    'Français',
    'Histoire',
    'Géographie',
    'Sciences',
    'Anglais',
    'Philosophie',
    'Économie',
  ];

  // Configuration des niveaux
  List<String> get gradeLevels => [
    'Primaire',
    'Collège',
    'Lycée',
    'Terminale',
  ];

  // Validation de la configuration
  bool isConfigValid() {
    return apiBaseUrl.isNotEmpty && 
           (_isOfflineMode || apiKeys['openai'] != 'YOUR_OPENAI_API_KEY');
  }

  // Méthode pour obtenir la configuration complète
  Map<String, dynamic> getFullConfig() {
    return {
      'environment': _environment,
      'apiBaseUrl': apiBaseUrl,
      'aiBaseUrl': aiBaseUrl,
      'isOfflineMode': _isOfflineMode,
      'useLocalAi': _useLocalAi,
      'timeouts': {
        'default': _defaultTimeout,
        'ai': _aiTimeout,
      },
      'endpoints': endpoints,
      'aiModels': aiModels,
      'supportedLanguages': supportedLanguages,
      'subjects': subjects,
      'gradeLevels': gradeLevels,
    };
  }
} 