# 🚀 Démarrage Rapide - Learnia

## Prérequis

### Backend (Python/FastAPI)
- Python 3.10+
- pip3

### Frontend (Flutter)
- Flutter SDK 3.7+
- Dart SDK

## 🏃‍♂️ Démarrage Ultra-Rapide

### 1. Démarrer le Backend
```bash
./start_backend.sh
```
Le backend sera accessible sur http://localhost:8000

### 2. Démarrer le Frontend
```bash
./start_frontend.sh
```
L'application sera accessible sur http://localhost:3000

### 3. Tester la Connexion
```bash
python3 test_connection.py
```

## 📋 Démarrage Manuel

### Backend
```bash
cd learnia-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp env.example .env
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Frontend
```bash
cd learnia
flutter pub get
flutter run -d web-server --web-port 3000
```

## 🔧 Configuration

### Backend (.env)
```env
SECRET_KEY=your-secret-key-change-in-production
OPENAI_API_KEY=your-openai-api-key-here
HUGGINGFACE_API_KEY=your-huggingface-api-key-here
```

### Frontend
Modifiez `learnia/lib/services/config_service.dart` pour changer l'URL de l'API.

## 🧪 Tests

### Backend
```bash
cd learnia-backend
pytest
```

### Frontend
```bash
cd learnia
flutter test
```

## 📚 Documentation API

Une fois le backend démarré, accédez à :
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🐛 Dépannage

### Backend inaccessible
1. Vérifiez que le port 8000 est libre
2. Vérifiez les logs du backend
3. Vérifiez la configuration CORS

### Frontend ne se connecte pas
1. Vérifiez que le backend est démarré
2. Vérifiez l'URL dans `config_service.dart`
3. Vérifiez la configuration CORS du backend

### Erreurs d'authentification
1. Vérifiez que la base de données est créée
2. Vérifiez les logs du backend
3. Testez avec le script `test_connection.py`

## 📱 Plateformes Supportées

- **Web**: http://localhost:3000
- **Android**: Émulateur ou appareil physique
- **iOS**: Simulateur ou appareil physique (macOS uniquement)
- **Desktop**: Windows, macOS, Linux

## 🔐 Authentification

L'application utilise JWT pour l'authentification :
1. Inscription d'un nouvel utilisateur
2. Connexion avec email/mot de passe
3. Token JWT stocké localement
4. Requêtes authentifiées automatiques

## 🎯 Fonctionnalités Testées

- ✅ Inscription utilisateur
- ✅ Connexion utilisateur
- ✅ Récupération du profil
- ✅ Tuteur intelligent
- ✅ Gestion des tokens JWT
- ✅ Configuration CORS
- ✅ Stockage local des données

## 📞 Support

En cas de problème :
1. Consultez les logs du backend
2. Vérifiez la configuration
3. Testez avec le script de test
4. Consultez la documentation API
