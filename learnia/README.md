# Learnia - Application Éducative pour Élèves Togolais

## Description

Learnia est une application mobile éducative complète développée en Flutter, conçue spécialement pour les élèves togolais du primaire à la terminale. L'application intègre plusieurs fonctionnalités basées sur l'intelligence artificielle et fonctionne entièrement en mode hors ligne avec une base de données SQLite locale.

## Fonctionnalités

### 🎓 Modules Éducatifs

1. **Tuteur intelligent (Chatbot éducatif)**
   - Pose de questions sur les cours
   - Explications simples et adaptées
   - Réponses générées par IA (simulation)
   - Mode hors ligne avec fallback local

2. **Générateur de QCM**
   - Génération automatique de questions à partir d'un texte
   - Interface de quiz interactive
   - Corrections automatiques

3. **Mémorisation intelligente (Système Leitner)**
   - Système de flashcards adaptatif
   - Révision basée sur la performance
   - Intervalles de révision optimisés

4. **Résumé automatique des leçons**
   - Extraction des points clés
   - Résumés structurés
   - Sauvegarde des résumés

5. **Traduction en langues locales**
   - Traduction français → éwé
   - Traduction français → kabiyè
   - Dictionnaire local intégré

6. **Analyse des performances**
   - Historique des résultats
   - Graphiques de progression
   - Suggestions d'amélioration

7. **Planificateur de révision intelligent**
   - Planning personnalisé
   - Gestion des matières et examens
   - Rappels automatiques

8. **Reconnaissance de devoirs manuscrits (OCR)**
   - Capture photo des devoirs
   - Reconnaissance de texte
   - Correction automatique (simulation)

9. **Orientation scolaire**
   - Questionnaire d'orientation
   - Suggestions de filières
   - Conseils de métiers

## Architecture Technique

### Technologies Utilisées

- **Framework** : Flutter 3.7+
- **Base de données** : SQLite (sqflite)
- **Gestion d'état** : Provider
- **Stockage local** : path_provider
- **Interface utilisateur** : Material Design
- **APIs** : Architecture modulaire pour intégration facile

### Structure du Projet

```
lib/
├── main.dart                    # Point d'entrée de l'application
├── services/
│   ├── api_service.dart         # Service centralisé pour les APIs
│   ├── ai_service.dart          # Service dédié aux fonctionnalités d'IA
│   └── config_service.dart      # Configuration centralisée
├── models/
│   ├── database_helper.dart     # Gestionnaire de base de données SQLite
│   └── tutor_model.dart         # Modèle pour le tuteur intelligent
├── utils/
│   └── api_integration_helper.dart # Helper pour intégration d'APIs
└── modules/
    ├── tutor/                   # Module tuteur intelligent
    ├── qcm/                     # Module générateur de QCM
    ├── leitner/                 # Module mémorisation Leitner
    ├── summary/                 # Module résumé automatique
    ├── translation/             # Module traduction
    ├── performance/             # Module analyse des performances
    ├── planner/                 # Module planificateur
    ├── ocr/                     # Module reconnaissance de devoirs
    └── orientation/             # Module orientation scolaire
```

## Architecture d'Intégration d'APIs

### 🚀 Facilité d'Intégration

L'application a été conçue pour faciliter l'intégration de nouvelles APIs :

#### 1. **Service API Centralisé** (`api_service.dart`)
- Gestion centralisée de toutes les requêtes HTTP
- Configuration automatique des timeouts et headers
- Gestion d'erreurs unifiée
- Support des méthodes GET, POST, PUT, DELETE

#### 2. **Service IA Dédié** (`ai_service.dart`)
- Interface unifiée pour toutes les APIs d'IA
- Fallback automatique vers le mode local
- Support d'OpenAI, Hugging Face, et APIs locales
- Gestion des prompts et configurations

#### 3. **Configuration Centralisée** (`config_service.dart`)
- Gestion des environnements (dev, prod, local)
- Configuration des URLs d'APIs
- Gestion des clés API
- Mode hors ligne configurable

#### 4. **Helper d'Intégration** (`api_integration_helper.dart`)
- Templates prêts à l'emploi
- Exemples d'intégration
- Méthodes avec retry, cache, validation
- Support de l'authentification

### 📋 Exemples d'Intégration

#### Intégration d'une nouvelle API d'IA
```dart
// Dans ai_service.dart
Future<String> newAiFeature(String input) async {
  try {
    final response = await _apiService.post(
      '/ai/new-feature',
      body: {'input': input},
    );
    return response['result'] ?? 'Pas de réponse';
  } catch (e) {
    return _generateLocalResponse(input);
  }
}
```

#### Intégration avec authentification
```dart
// Utilisation du helper
final helper = ApiIntegrationHelper();
final result = await helper.authenticatedApiCall(
  endpoint: '/secure/data',
  apiKey: 'your-api-key',
);
```

#### Intégration avec retry et cache
```dart
final result = await helper.apiCallWithRetry(
  endpoint: '/unreliable/api',
  method: 'GET',
  maxRetries: 3,
);
```

### 🔧 Configuration des APIs

#### 1. Ajouter une nouvelle API
```dart
// Dans config_service.dart
Map<String, String> get endpoints => {
  'new_api': '/api/new-feature',
  // ... autres endpoints
};
```

#### 2. Configurer les clés API
```dart
Map<String, String> get apiKeys => {
  'openai': 'YOUR_OPENAI_API_KEY',
  'new_api': 'YOUR_NEW_API_KEY',
};
```

#### 3. Ajouter un nouveau modèle d'IA
```dart
Map<String, String> get aiModels => {
  'new_model': 'gpt-4',
  // ... autres modèles
};
```

### 🌐 Support des Environnements

- **Développement** : `https://dev-api.learnia.tg`
- **Production** : `https://api.learnia.tg`
- **Local** : `http://localhost:3000`

### 📱 Mode Hors Ligne

L'application fonctionne entièrement hors ligne avec :
- Base de données SQLite locale
- Réponses pré-générées
- Fallback automatique
- Synchronisation lors du retour en ligne

## Installation et Configuration

### Prérequis

- Flutter SDK 3.7.2 ou supérieur
- Dart SDK
- Android Studio / VS Code
- Émulateur Android ou appareil physique

### Installation

1. **Cloner le projet**
   ```bash
   git clone [url-du-repo]
   cd learnia
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer les APIs** (optionnel)
   ```dart
   // Dans config_service.dart
   static const String _openaiApiKey = 'YOUR_ACTUAL_API_KEY';
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## Utilisation

### Première utilisation

1. L'application se lance sur l'écran d'accueil avec tous les modules disponibles
2. Chaque module peut être utilisé indépendamment
3. Les données sont sauvegardées automatiquement en local
4. Le mode hors ligne est activé par défaut

### Fonctionnalités principales

- **Navigation** : Interface intuitive avec navigation par modules
- **Données** : Toutes les données sont stockées localement
- **Interface** : Design responsive et adapté aux élèves togolais
- **Langue** : Interface entièrement en français
- **APIs** : Intégration transparente avec fallback automatique

## Développement

### Ajout de nouvelles fonctionnalités

1. **Créer un nouveau module**
   ```bash
   mkdir lib/modules/new_module
   touch lib/modules/new_module/new_module_page.dart
   ```

2. **Implémenter la page du module**
   ```dart
   import 'package:flutter/material.dart';
   import '../../services/ai_service.dart';
   
   class NewModulePage extends StatelessWidget {
     // Implémentation...
   }
   ```

3. **Ajouter le module dans main.dart**
   ```dart
   _Module('Nouveau Module', Icons.new_feature, const NewModulePage()),
   ```

4. **Intégrer une API** (si nécessaire)
   ```dart
   // Utiliser le helper d'intégration
   final helper = ApiIntegrationHelper();
   final result = await helper.integrateNewAiApi(
     endpoint: '/ai/new-feature',
     payload: {'data': 'value'},
     fallbackResponse: 'Réponse locale',
   );
   ```

### Tests

```bash
flutter test
```

### Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Contribution

Ce projet est conçu pour l'éducation au Togo. Les contributions sont les bienvenues pour :

- Améliorer l'interface utilisateur
- Ajouter de nouvelles fonctionnalités
- Optimiser les performances
- Corriger les bugs
- Intégrer de nouvelles APIs

### Guide de Contribution pour les APIs

1. **Utiliser les services existants** : `ApiService`, `AiService`
2. **Suivre les templates** : `ApiIntegrationHelper`
3. **Tester le fallback** : Vérifier le mode hors ligne
4. **Documenter** : Ajouter des commentaires et exemples

## Licence

Ce projet est développé pour un usage éducatif au Togo.

## Contact

Pour toute question ou suggestion, veuillez contacter l'équipe de développement.

---

**Learnia** - Révolutionner l'éducation au Togo avec l'intelligence artificielle locale.
