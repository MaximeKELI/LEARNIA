import 'package:flutter/foundation.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  // Configuration de base
  static const String appName = 'Learnia';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  // Configuration API
  static const String baseUrl = 'http://localhost:8000';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration aiTimeout = Duration(seconds: 60);

  // Configuration de l'application
  static const bool debugMode = kDebugMode;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;

  // Configuration des modules
  static const Map<String, bool> enabledModules = {
    'tutor': true,
    'qcm': true,
    'leitner': true,
    'summary': true,
    'translation': true,
    'performance': true,
    'planner': true,
    'ocr': true,
    'orientation': true,
  };

  // Configuration des matières
  static const List<String> subjects = [
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
  static const List<String> gradeLevels = [
    'Primaire',
    'Collège',
    'Lycée',
    'Terminale',
  ];

  // Configuration des langues
  static const List<String> supportedLanguages = [
    'fr',
    'ewe',
    'kab',
  ];

  // Configuration de l'IA
  static const String defaultAiModel = 'gpt-3.5-turbo';
  static const int maxTokens = 500;
  static const double temperature = 0.7;
  static const bool enableLocalFallback = true;

  // Configuration de la base de données
  static const int databaseVersion = 1;
  static const String databaseName = 'learnia.db';

  // Configuration des performances
  static const int maxFlashcardsPerBox = 20;
  static const int maxQcmQuestions = 10;
  static const int maxSummaryLength = 200;
  static const int maxTranslationLength = 500;

  // Configuration de l'interface
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Configuration des couleurs (pour référence)
  static const Map<String, int> colorScheme = {
    'primary': 0xFF2196F3,
    'secondary': 0xFF03DAC6,
    'error': 0xFFB00020,
    'surface': 0xFFFFFFFF,
    'background': 0xFFF5F5F5,
  };

  // Configuration des tailles de police
  static const Map<String, double> textSizes = {
    'small': 12.0,
    'medium': 14.0,
    'large': 16.0,
    'xlarge': 18.0,
    'xxlarge': 24.0,
  };

  // Configuration des animations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Configuration du cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB

  // Configuration des notifications
  static const bool enableNotifications = true;
  static const Duration notificationDelay = Duration(seconds: 5);

  // Configuration de la synchronisation
  static const bool enableSync = true;
  static const Duration syncInterval = Duration(minutes: 30);
  static const int maxRetryAttempts = 3;

  // Méthodes utilitaires
  static String get apiBaseUrl => '$baseUrl/api/$apiVersion';
  static String get healthCheckUrl => '$baseUrl/health';
  static String get configUrl => '$baseUrl/config';

  // Vérifier si un module est activé
  static bool isModuleEnabled(String moduleName) {
    return enabledModules[moduleName] ?? false;
  }

  // Obtenir la configuration d'un module
  static Map<String, dynamic> getModuleConfig(String moduleName) {
    switch (moduleName) {
      case 'tutor':
        return {
          'maxQuestionsPerSession': 10,
          'enableSuggestions': true,
          'enableHistory': true,
        };
      case 'qcm':
        return {
          'maxQuestions': maxQcmQuestions,
          'timePerQuestion': 30, // seconds
          'enableTimer': true,
        };
      case 'leitner':
        return {
          'maxCardsPerBox': maxFlashcardsPerBox,
          'reviewInterval': 24, // hours
          'enableNotifications': true,
        };
      case 'summary':
        return {
          'maxLength': maxSummaryLength,
          'enableCompression': true,
          'enableKeywords': true,
        };
      case 'translation':
        return {
          'maxLength': maxTranslationLength,
          'enableLocalTranslation': true,
          'enableHistory': true,
        };
      case 'performance':
        return {
          'enableAnalytics': enableAnalytics,
          'enableCharts': true,
          'enableExport': true,
        };
      case 'planner':
        return {
          'maxPlansPerUser': 50,
          'enableReminders': true,
          'enableSync': enableSync,
        };
      case 'ocr':
        return {
          'maxImageSize': 5, // MB
          'supportedFormats': ['jpg', 'jpeg', 'png'],
          'enablePreprocessing': true,
        };
      case 'orientation':
        return {
          'maxQuestions': 20,
          'enablePersonalization': true,
          'enableFollowUp': true,
        };
      default:
        return {};
    }
  }

  // Obtenir la configuration de l'environnement
  static Map<String, dynamic> getEnvironmentConfig() {
    return {
      'debug': debugMode,
      'logging': enableLogging,
      'analytics': enableAnalytics,
      'sync': enableSync,
      'notifications': enableNotifications,
    };
  }

  // Obtenir la configuration complète
  static Map<String, dynamic> getAllConfig() {
    return {
      'app': {
        'name': appName,
        'version': version,
        'buildNumber': buildNumber,
      },
      'api': {
        'baseUrl': baseUrl,
        'apiVersion': apiVersion,
        'timeout': apiTimeout.inSeconds,
        'aiTimeout': aiTimeout.inSeconds,
      },
      'modules': enabledModules,
      'subjects': subjects,
      'gradeLevels': gradeLevels,
      'languages': supportedLanguages,
      'ai': {
        'model': defaultAiModel,
        'maxTokens': maxTokens,
        'temperature': temperature,
        'localFallback': enableLocalFallback,
      },
      'database': {
        'version': databaseVersion,
        'name': databaseName,
      },
      'ui': {
        'padding': defaultPadding,
        'borderRadius': defaultBorderRadius,
        'elevation': defaultElevation,
        'textSizes': textSizes,
        'colors': colorScheme,
      },
      'animations': {
        'short': shortAnimation.inMilliseconds,
        'medium': mediumAnimation.inMilliseconds,
        'long': longAnimation.inMilliseconds,
      },
      'cache': {
        'expiration': cacheExpiration.inHours,
        'maxSize': maxCacheSize,
      },
      'sync': {
        'enabled': enableSync,
        'interval': syncInterval.inMinutes,
        'maxRetries': maxRetryAttempts,
      },
    };
  }
}

