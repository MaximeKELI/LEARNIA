#!/bin/bash

# Script de test de production pour Learnia
set -e

echo "🧪 Test de production de Learnia"
echo "================================"

# Configuration
BACKEND_URL="http://localhost:8000"
FRONTEND_URL="http://localhost:3000"
TEST_USER_EMAIL="test_prod_$(date +%s)@example.com"
TEST_USER_PASSWORD="TestPassword123!"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fonctions de logging
log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Test de connectivité
test_connectivity() {
    log "Test de connectivité..."
    
    # Test du backend
    if curl -s "$BACKEND_URL/health" > /dev/null; then
        log "✅ Backend accessible"
    else
        error "❌ Backend non accessible"
    fi
    
    # Test du frontend
    if curl -s "$FRONTEND_URL" > /dev/null; then
        log "✅ Frontend accessible"
    else
        warn "⚠️  Frontend non accessible (normal si pas encore déployé)"
    fi
}

# Test d'authentification
test_authentication() {
    log "Test d'authentification..."
    
    # Test d'inscription
    log "Test d'inscription..."
    REGISTER_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_USER_EMAIL\",
            \"username\": \"testuser_$(date +%s)\",
            \"full_name\": \"Test User\",
            \"password\": \"$TEST_USER_PASSWORD\",
            \"grade_level\": \"Collège\"
        }")
    
    if echo "$REGISTER_RESPONSE" | grep -q "id"; then
        log "✅ Inscription réussie"
    else
        error "❌ Échec d'inscription: $REGISTER_RESPONSE"
    fi
    
    # Test de connexion
    log "Test de connexion..."
    LOGIN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"$TEST_USER_EMAIL\",
            \"password\": \"$TEST_USER_PASSWORD\"
        }")
    
    if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
        log "✅ Connexion réussie"
        TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    else
        error "❌ Échec de connexion: $LOGIN_RESPONSE"
    fi
}

# Test des endpoints authentifiés
test_authenticated_endpoints() {
    log "Test des endpoints authentifiés..."
    
    if [ -z "$TOKEN" ]; then
        error "❌ Token d'authentification manquant"
    fi
    
    # Test du profil utilisateur
    log "Test du profil utilisateur..."
    PROFILE_RESPONSE=$(curl -s -X GET "$BACKEND_URL/api/v1/auth/me" \
        -H "Authorization: Bearer $TOKEN")
    
    if echo "$PROFILE_RESPONSE" | grep -q "email"; then
        log "✅ Profil utilisateur récupéré"
    else
        error "❌ Échec de récupération du profil: $PROFILE_RESPONSE"
    fi
    
    # Test du tuteur intelligent
    log "Test du tuteur intelligent..."
    TUTOR_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/ai/tutor/" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"question\": \"Qu'est-ce qu'une fraction ?\",
            \"subject\": \"Mathématiques\",
            \"grade_level\": \"Collège\"
        }")
    
    if echo "$TUTOR_RESPONSE" | grep -q "answer"; then
        log "✅ Tuteur intelligent fonctionne"
    else
        warn "⚠️  Tuteur intelligent non fonctionnel: $TUTOR_RESPONSE"
    fi
}

# Test de performance
test_performance() {
    log "Test de performance..."
    
    # Test de charge sur l'endpoint de santé
    log "Test de charge (10 requêtes)..."
    for i in {1..10}; do
        START_TIME=$(date +%s%N)
        curl -s "$BACKEND_URL/health" > /dev/null
        END_TIME=$(date +%s%N)
        DURATION=$(( (END_TIME - START_TIME) / 1000000 ))
        log "Requête $i: ${DURATION}ms"
    done
    
    # Test de performance avec ab (si disponible)
    if command -v ab &> /dev/null; then
        log "Test de performance avec Apache Bench..."
        ab -n 100 -c 10 "$BACKEND_URL/health" > /tmp/ab_results.txt 2>&1
        if [ $? -eq 0 ]; then
            log "✅ Test de performance terminé"
            grep "Requests per second" /tmp/ab_results.txt || true
        else
            warn "⚠️  Test de performance échoué"
        fi
    else
        warn "⚠️  Apache Bench non installé, test de performance limité"
    fi
}

# Test de sécurité
test_security() {
    log "Test de sécurité..."
    
    # Test des en-têtes de sécurité
    log "Test des en-têtes de sécurité..."
    SECURITY_HEADERS=$(curl -s -I "$BACKEND_URL/health")
    
    if echo "$SECURITY_HEADERS" | grep -q "X-Content-Type-Options"; then
        log "✅ En-têtes de sécurité présents"
    else
        warn "⚠️  En-têtes de sécurité manquants"
    fi
    
    # Test de validation des entrées
    log "Test de validation des entrées..."
    INVALID_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/v1/auth/register" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"invalid-email\",
            \"username\": \"a\",
            \"password\": \"123\"
        }")
    
    if echo "$INVALID_RESPONSE" | grep -q "error\|detail"; then
        log "✅ Validation des entrées fonctionne"
    else
        warn "⚠️  Validation des entrées insuffisante"
    fi
}

# Test de la base de données
test_database() {
    log "Test de la base de données..."
    
    # Test de connexion à la base de données
    if python3 -c "
import sys
sys.path.append('learnia-backend')
from app.database import get_session
from sqlmodel import text
try:
    with get_session() as session:
        session.exec(text('SELECT 1'))
    print('Database connection successful')
except Exception as e:
    print(f'Database connection failed: {e}')
    sys.exit(1)
" 2>/dev/null; then
        log "✅ Connexion à la base de données réussie"
    else
        error "❌ Connexion à la base de données échouée"
    fi
}

# Test de Redis
test_redis() {
    log "Test de Redis..."
    
    if command -v redis-cli &> /dev/null; then
        if redis-cli ping | grep -q "PONG"; then
            log "✅ Redis accessible"
        else
            warn "⚠️  Redis non accessible"
        fi
    else
        warn "⚠️  Redis CLI non installé"
    fi
}

# Test de validation de production
test_production_validation() {
    log "Test de validation de production..."
    
    if [ -f "validate_production.py" ]; then
        if python3 validate_production.py --url "$BACKEND_URL"; then
            log "✅ Validation de production réussie"
        else
            warn "⚠️  Validation de production échouée"
        fi
    else
        warn "⚠️  Script de validation de production non trouvé"
    fi
}

# Nettoyage
cleanup() {
    log "Nettoyage des données de test..."
    
    # Supprimer l'utilisateur de test (si possible)
    if [ -n "$TOKEN" ]; then
        curl -s -X DELETE "$BACKEND_URL/api/v1/auth/me" \
            -H "Authorization: Bearer $TOKEN" > /dev/null || true
    fi
    
    log "Nettoyage terminé"
}

# Fonction principale
main() {
    log "Début des tests de production"
    
    # Tests de base
    test_connectivity
    test_database
    test_redis
    
    # Tests fonctionnels
    test_authentication
    test_authenticated_endpoints
    
    # Tests de performance et sécurité
    test_performance
    test_security
    
    # Validation de production
    test_production_validation
    
    # Nettoyage
    cleanup
    
    log "Tests de production terminés avec succès! 🎉"
}

# Gestion des erreurs
trap cleanup EXIT

# Exécuter les tests
main "$@"
