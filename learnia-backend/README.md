# Learnia Backend - API FastAPI

Backend complet pour l'application éducative Learnia destinée aux élèves togolais.

## 🚀 Fonctionnalités

### Core Features
- **Authentification JWT** : Inscription, connexion, gestion des utilisateurs
- **Tuteur intelligent** : Chatbot éducatif avec IA (OpenAI + fallback local)
- **Générateur de QCM** : Création automatique de quiz
- **Résumé automatique** : Extraction des points clés
- **Traduction** : Support des langues locales (éwé, kabiyè)
- **Orientation scolaire** : Conseils d'orientation personnalisés
- **OCR** : Reconnaissance de texte manuscrit
- **Base de données SQLite** : Stockage local avec SQLModel
- **Documentation automatique** : Swagger UI et ReDoc

### Architecture
- **FastAPI** : Framework moderne et rapide
- **SQLModel** : ORM moderne basé sur SQLAlchemy et Pydantic
- **JWT** : Authentification sécurisée
- **CORS** : Support cross-origin
- **Logs** : Système de logging avec Loguru
- **Configuration** : Gestion centralisée avec Pydantic Settings

## 📋 Prérequis

- Python 3.10+
- pip
- (Optionnel) OpenAI API Key pour les fonctionnalités IA avancées

## 🛠️ Installation

### 1. Cloner le projet
```bash
git clone <repository-url>
cd learnia-backend
```

### 2. Créer un environnement virtuel
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate  # Windows
```

### 3. Installer les dépendances
```bash
pip install -r requirements.txt
```

### 4. Configuration
```bash
# Copier le fichier d'exemple
cp env.example .env

# Éditer le fichier .env avec vos configurations
nano .env
```

### 5. Variables d'environnement importantes
```env
# Obligatoire
SECRET_KEY=your-secret-key-change-in-production

# Optionnel (pour les fonctionnalités IA avancées)
OPENAI_API_KEY=your-openai-api-key-here
HUGGINGFACE_API_KEY=your-huggingface-api-key-here
```

## 🚀 Lancement

### Mode développement
```bash
python -m app.main
```

### Mode production
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Avec reload automatique
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📚 Documentation API

Une fois le serveur lancé, accédez à :

- **Swagger UI** : http://localhost:8000/docs
- **ReDoc** : http://localhost:8000/redoc
- **Health Check** : http://localhost:8000/health

## 🔧 Endpoints Principaux

### Authentification
- `POST /api/v1/auth/register` - Inscription
- `POST /api/v1/auth/login` - Connexion
- `GET /api/v1/auth/me` - Informations utilisateur
- `POST /api/v1/auth/logout` - Déconnexion

### Tuteur Intelligent
- `POST /api/v1/ai/tutor/` - Poser une question
- `GET /api/v1/ai/tutor/suggestions/{subject}` - Suggestions de questions
- `GET /api/v1/ai/tutor/subjects` - Matières supportées
- `GET /api/v1/ai/tutor/health` - État du service

### Configuration
- `GET /config` - Configuration publique
- `GET /health` - État général de l'API

## 🗄️ Base de Données

### Tables créées automatiquement
- `users` - Utilisateurs et authentification
- (Autres tables selon les modèles définis)

### Migration (optionnel)
```bash
# Si vous utilisez Alembic pour les migrations
alembic init alembic
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

## 🔒 Sécurité

### Authentification
- JWT tokens avec expiration
- Hachage des mots de passe avec bcrypt
- Validation des données avec Pydantic

### CORS
- Configuration flexible des origines autorisées
- Support des credentials

### Logs
- Rotation automatique des fichiers de logs
- Niveaux de log configurables
- Logs de requêtes HTTP

## 🧪 Tests

### Lancer les tests
```bash
pytest
```

### Tests avec couverture
```bash
pytest --cov=app
```

## 📊 Monitoring

### Logs
Les logs sont stockés dans `learnia.log` avec :
- Rotation automatique (10 MB)
- Rétention de 7 jours
- Format structuré

### Métriques
- Temps de réponse des requêtes
- État des services
- Utilisation des APIs externes

## 🔧 Configuration Avancée

### Variables d'environnement disponibles
```env
# Base
APP_NAME=Learnia Backend
VERSION=1.0.0
DEBUG=true

# Base de données
DATABASE_URL=sqlite:///./learnia.db

# Sécurité
SECRET_KEY=your-secret-key
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# APIs
OPENAI_API_KEY=your-key
HUGGINGFACE_API_KEY=your-key

# CORS
CORS_ORIGINS=["http://localhost:3000"]

# IA
DEFAULT_AI_MODEL=gpt-3.5-turbo
MAX_TOKENS=500
TEMPERATURE=0.7

# Logs
LOG_LEVEL=INFO
LOG_FILE=learnia.log
```

## 🚀 Déploiement

### Docker (recommandé)
```dockerfile
FROM python:3.10-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Production
```bash
# Installer gunicorn
pip install gunicorn

# Lancer avec gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📝 Structure du Projet

```
learnia-backend/
├── app/
│   ├── __init__.py
│   ├── main.py              # Point d'entrée FastAPI
│   ├── config.py            # Configuration
│   ├── database.py          # Configuration DB
│   ├── api/                 # Routes API
│   │   ├── __init__.py
│   │   ├── auth.py          # Authentification
│   │   └── tutor.py         # Tuteur intelligent
│   ├── models/              # Modèles de données
│   │   ├── __init__.py
│   │   ├── user.py          # Modèles utilisateur
│   │   └── ai_models.py     # Modèles IA
│   └── services/            # Services métier
│       ├── __init__.py
│       ├── auth.py          # Service authentification
│       └── ai_service.py    # Service IA
├── requirements.txt         # Dépendances Python
├── env.example             # Variables d'environnement
├── README.md               # Ce fichier
└── learnia.db             # Base de données SQLite (créée automatiquement)
```

## 🐛 Dépannage

### Erreurs communes

1. **Module not found**
   ```bash
   pip install -r requirements.txt
   ```

2. **Base de données non créée**
   ```bash
   # La base est créée automatiquement au premier lancement
   # Vérifiez les permissions du dossier
   ```

3. **Erreur CORS**
   ```bash
   # Vérifiez CORS_ORIGINS dans .env
   # Ajoutez votre domaine frontend
   ```

4. **Erreur OpenAI**
   ```bash
   # Vérifiez OPENAI_API_KEY dans .env
   # Ou utilisez le mode local (sans clé API)
   ```

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Consulter la documentation API (/docs)
- Vérifier les logs dans `learnia.log`

## 📄 Licence

Ce projet est développé pour l'éducation au Togo.

---

**Learnia Backend** - Révolutionner l'éducation au Togo avec l'intelligence artificielle. 