#!/bin/bash

# Script de démarrage du frontend Learnia
echo "🚀 Démarrage du frontend Learnia..."

# Vérifier si Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    echo "📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Aller dans le dossier frontend
cd learnia

# Vérifier si les dépendances sont installées
if [ ! -d "build" ]; then
    echo "📦 Installation des dépendances Flutter..."
    flutter pub get
fi

# Vérifier la configuration Flutter
echo "🔧 Vérification de la configuration Flutter..."
flutter doctor

# Démarrer l'application
echo "📱 Démarrage de l'application Flutter..."
echo "📍 Application accessible sur: http://localhost:3000 (web)"
echo "📱 Ou sur votre émulateur/appareil mobile"
echo ""
echo "Appuyez sur Ctrl+C pour arrêter l'application"
echo ""

# Démarrer en mode web par défaut
flutter run -d web-server --web-port 3000
