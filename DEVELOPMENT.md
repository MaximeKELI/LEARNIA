# Learnia - Guide de Développement

## 🚀 Améliorations Récentes

### Services Flutter Implémentés

#### 1. **ApiService** (`lib/services/api_service.dart`)
- Service centralisé pour toutes les requêtes HTTP
- Gestion automatique des timeouts et headers
- Gestion d'erreurs unifiée avec exceptions personnalisées
- Support des méthodes GET, POST, PUT, DELETE
- Gestion des tokens d'authentification
- Vérification de connectivité

#### 2. **DatabaseHelper** (`lib/services/database_helper.dart`)
- Gestionnaire de base de données SQLite
- Tables pour tous les modules éducatifs
- Méthodes CRUD génériques et spécialisées
- Support des relations entre tables
- Gestion des migrations

#### 3. **AIService** (`lib/services/ai_service.dart`)
- Service unifié pour toutes les fonctionnalités d'IA
- Intégration avec l'API backend
- Fallback automatique vers le mode local
- Support de tous les modules (tuteur, QCM, résumé, traduction, etc.)
- Gestion des erreurs et timeouts

#### 4. **AuthService** (`lib/services/auth_service.dart`)
- Gestion complète de l'authentification
- Inscription, connexion, déconnexion
- Gestion des tokens JWT
- Persistance locale des données utilisateur
- Mise à jour du profil

#### 5. **ConfigService** (`lib/services/config_service.dart`)
- Configuration centralisée de l'application
- Paramètres des modules
- Configuration de l'API et de l'IA
- Thèmes et couleurs
- Constantes de l'application

### Architecture Améliorée

#### **Gestion d'État avec Provider**
- `AuthNotifier` : Gestion de l'authentification
- `AppStateNotifier` : État global de l'application
- Intégration complète avec les services

#### **Interface Utilisateur Avancée**
- Page de connexion/inscription complète
- Interface d'accueil avec informations utilisateur
- Module tuteur intelligent entièrement fonctionnel
- Design Material 3 moderne
- Gestion des états de chargement

#### **Intégration Frontend-Backend**
- Communication bidirectionnelle avec l'API
- Synchronisation des données locales
- Gestion des erreurs réseau
- Mode hors ligne intelligent

### Modules Éducatifs

#### **Tuteur Intelligent** (Entièrement Implémenté)
- Interface de question-réponse interactive
- Historique des sessions
- Sauvegarde locale des conversations
- Intégration avec l'IA backend
- Fallback local en cas d'erreur

### Base de Données

#### **Tables Créées**
- `users` : Gestion des utilisateurs
- `tutor_sessions` : Sessions du tuteur
- `qcm_sessions` : Sessions de QCM
- `flashcards` : Cartes de mémorisation Leitner
- `summaries` : Résumés automatiques
- `translations` : Traductions
- `performances` : Données de performance
- `study_plans` : Plans d'étude
- `ocr_results` : Résultats OCR
- `orientations` : Résultats d'orientation

### Tests

#### **Suite de Tests** (`test/services_test.dart`)
- Tests unitaires pour tous les services
- Tests des modèles de données
- Tests de l'authentification
- Tests des fonctionnalités d'IA
- Couverture complète des cas d'usage

## 🔧 Utilisation

### Démarrage Rapide

1. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

2. **Lancer le backend**
   ```bash
   cd learnia-backend
   python -m app.main
   ```

3. **Lancer l'application**
   ```bash
   flutter run
   ```

### Configuration

#### **Variables d'Environnement Backend**
```env
SECRET_KEY=your-secret-key
OPENAI_API_KEY=your-openai-key  # Optionnel
DATABASE_URL=sqlite:///./learnia.db
```

#### **Configuration Flutter**
- Modifiez `ConfigService` pour ajuster les paramètres
- L'URL de l'API est configurée dans `ApiService`
- Les modules peuvent être activés/désactivés dans `ConfigService`

## 📱 Fonctionnalités Disponibles

### ✅ Implémentées
- Authentification complète (inscription/connexion)
- Tuteur intelligent avec IA
- Interface utilisateur moderne
- Base de données SQLite locale
- Services d'intégration API
- Tests unitaires

### 🔄 En Cours de Développement
- Modules QCM, Leitner, Résumé, etc.
- Interface utilisateur avancée
- Tests d'intégration
- Optimisations de performance

### 📋 À Développer
- Modules restants (OCR, Orientation, etc.)
- Synchronisation cloud
- Notifications push
- Analytics et monitoring

## 🏗️ Architecture Technique

### **Frontend (Flutter)**
```
lib/
├── main.dart                 # Point d'entrée avec Provider
├── services/                 # Services métier
│   ├── api_service.dart      # Communication API
│   ├── database_helper.dart  # Gestion SQLite
│   ├── ai_service.dart       # Fonctionnalités IA
│   ├── auth_service.dart     # Authentification
│   └── config_service.dart   # Configuration
├── modules/                  # Modules éducatifs
│   ├── tutor/               # Tuteur intelligent ✅
│   ├── qcm/                 # Générateur QCM 🔄
│   └── ...                  # Autres modules
└── test/                    # Tests unitaires
```

### **Backend (FastAPI)**
```
learnia-backend/
├── app/
│   ├── main.py              # Point d'entrée FastAPI
│   ├── api/                 # Routes API
│   ├── models/              # Modèles de données
│   ├── services/            # Services métier
│   └── config.py            # Configuration
```

## 🚀 Prochaines Étapes

1. **Finaliser les modules restants**
   - Implémenter la logique métier complète
   - Intégrer avec les services

2. **Améliorer l'interface**
   - Composants réutilisables
   - Animations et transitions
   - Thèmes personnalisables

3. **Tests et qualité**
   - Tests d'intégration
   - Tests de performance
   - Documentation API

4. **Déploiement**
   - Configuration de production
   - CI/CD
   - Monitoring

## 🤝 Contribution

### **Standards de Code**
- Suivre les conventions Flutter/Dart
- Tests unitaires pour toutes les nouvelles fonctionnalités
- Documentation des méthodes publiques
- Gestion d'erreurs robuste

### **Workflow**
1. Créer une branche feature
2. Implémenter les fonctionnalités
3. Ajouter les tests
4. Vérifier le linting
5. Créer une pull request

## 📞 Support

Pour toute question ou problème :
- Consulter la documentation API : `/docs`
- Vérifier les logs : `learnia.log`
- Ouvrir une issue sur GitHub

---

**Learnia** - Révolutionner l'éducation au Togo avec l'intelligence artificielle locale.

