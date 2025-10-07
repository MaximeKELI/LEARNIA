#!/bin/bash

# Script de démarrage optimisé pour Learnia
echo "🚀 Démarrage optimisé de Learnia"
echo "================================="

# Fonction pour vérifier si un port est libre
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "❌ Le port $port est déjà utilisé"
        return 1
    else
        echo "✅ Le port $port est libre"
        return 0
    fi
}

# Fonction pour attendre qu'un service soit prêt
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=0
    
    echo "⏳ Attente de $service_name..."
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo "✅ $service_name est prêt!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo "   Tentative $attempt/$max_attempts..."
        sleep 2
    done
    
    echo "❌ $service_name n'est pas prêt après $max_attempts tentatives"
    return 1
}

# Vérifier les ports
echo "🔍 Vérification des ports..."
check_port 8000 || exit 1
check_port 3000 || exit 1

# Démarrer le backend
echo "🔧 Démarrage du backend..."
cd learnia-backend

# Vérifier l'environnement virtuel
if [ ! -d "venv" ]; then
    echo "📦 Création de l'environnement virtuel..."
    python3 -m venv venv
fi

# Activer l'environnement virtuel
source venv/bin/activate

# Installer les dépendances
echo "📥 Installation des dépendances..."
pip install -r requirements.txt

# Créer le fichier .env s'il n'existe pas
if [ ! -f ".env" ]; then
    echo "⚙️  Création du fichier .env..."
    cat > .env << EOF
SECRET_KEY=your-secret-key-change-in-production-$(date +%s)
DEBUG=True
DATABASE_URL=sqlite:///./learnia.db
OPENAI_API_KEY=your-openai-api-key-here
HUGGINGFACE_API_KEY=your-huggingface-api-key-here
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://127.0.0.1:3000","http://127.0.0.1:8080"]
ACCESS_TOKEN_EXPIRE_MINUTES=30
ALGORITHM=HS256
EOF
fi

# Démarrer le backend en arrière-plan
echo "🌐 Démarrage du serveur FastAPI..."
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!

# Attendre que le backend soit prêt
wait_for_service "http://localhost:8000/health" "Backend FastAPI"

# Démarrer le frontend
echo "📱 Démarrage du frontend..."
cd ../learnia

# Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    echo "📥 Installez Flutter depuis: https://flutter.dev/docs/get-started/install"
    kill $BACKEND_PID
    exit 1
fi

# Installer les dépendances Flutter
echo "📦 Installation des dépendances Flutter..."
flutter pub get

# Démarrer le frontend en arrière-plan
echo "🚀 Démarrage de l'application Flutter..."
flutter run -d web-server --web-port 3000 &
FRONTEND_PID=$!

# Attendre que le frontend soit prêt
wait_for_service "http://localhost:3000" "Frontend Flutter"

# Afficher les informations
echo ""
echo "🎉 Learnia est maintenant démarré!"
echo "================================="
echo "📍 Backend: http://localhost:8000"
echo "📚 API Docs: http://localhost:8000/docs"
echo "🔍 ReDoc: http://localhost:8000/redoc"
echo "📱 Frontend: http://localhost:3000"
echo ""
echo "🧪 Pour tester la connexion:"
echo "   python3 test_connection.py"
echo ""
echo "📊 Pour tester les performances:"
echo "   cd learnia-backend && python performance_test.py"
echo ""
echo "🛑 Pour arrêter les services:"
echo "   kill $BACKEND_PID $FRONTEND_PID"
echo ""

# Fonction de nettoyage
cleanup() {
    echo ""
    echo "🛑 Arrêt des services..."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    echo "✅ Services arrêtés"
    exit 0
}

# Capturer Ctrl+C
trap cleanup SIGINT SIGTERM

# Attendre indéfiniment
echo "Appuyez sur Ctrl+C pour arrêter les services"
wait
