#!/bin/bash

# Script de démarrage du backend Learnia
echo "🚀 Démarrage du backend Learnia..."

# Vérifier si Python est installé
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 n'est pas installé"
    exit 1
fi

# Vérifier si pip est installé
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 n'est pas installé"
    exit 1
fi

# Aller dans le dossier backend
cd learnia-backend

# Vérifier si l'environnement virtuel existe
if [ ! -d "venv" ]; then
    echo "📦 Création de l'environnement virtuel..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
echo "🔧 Activation de l'environnement virtuel..."
source venv/bin/activate

# Installer les dépendances
echo "📥 Installation des dépendances..."
pip install -r requirements.txt

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    echo "⚙️  Création du fichier .env..."
    cp env.example .env
    echo "📝 Veuillez configurer le fichier .env avec vos clés API"
fi

# Démarrer le serveur
echo "🌐 Démarrage du serveur FastAPI..."
echo "📍 Backend accessible sur: http://localhost:8000"
echo "📚 Documentation API: http://localhost:8000/docs"
echo "🔍 ReDoc: http://localhost:8000/redoc"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter le serveur"
echo ""

python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
