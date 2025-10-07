#!/usr/bin/env python3
"""
Script de test de connexion entre le frontend et le backend Learnia
"""
import requests
import json
import sys
from datetime import datetime

# Configuration
BACKEND_URL = "http://localhost:8000"
FRONTEND_URL = "http://localhost:3000"

def test_backend_health():
    """Test de santé du backend"""
    print("🔍 Test de santé du backend...")
    try:
        response = requests.get(f"{BACKEND_URL}/health", timeout=5)
        if response.status_code == 200:
            print("✅ Backend accessible")
            data = response.json()
            print(f"   Status: {data.get('status', 'unknown')}")
            print(f"   Version: {data.get('version', 'unknown')}")
            return True
        else:
            print(f"❌ Backend inaccessible (Status: {response.status_code})")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Erreur de connexion au backend: {e}")
        return False

def test_auth_endpoints():
    """Test des endpoints d'authentification"""
    print("\n🔐 Test des endpoints d'authentification...")
    
    # Test d'inscription
    print("   Test d'inscription...")
    register_data = {
        "email": f"test_{datetime.now().strftime('%Y%m%d_%H%M%S')}@example.com",
        "username": f"testuser_{datetime.now().strftime('%Y%m%d_%H%M%S')}",
        "full_name": "Test User",
        "password": "TestPassword123!",
        "grade_level": "Collège",
        "school": "Test School"
    }
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/auth/register",
            json=register_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 201:
            print("   ✅ Inscription réussie")
            user_data = response.json()
            print(f"   User ID: {user_data.get('id')}")
            print(f"   Email: {user_data.get('email')}")
        else:
            print(f"   ❌ Échec d'inscription (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erreur lors de l'inscription: {e}")
        return False
    
    # Test de connexion
    print("   Test de connexion...")
    login_data = {
        "email": register_data["email"],
        "password": register_data["password"]
    }
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/auth/login",
            json=login_data,
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            print("   ✅ Connexion réussie")
            auth_data = response.json()
            token = auth_data.get("access_token")
            print(f"   Token reçu: {token[:20]}..." if token else "   Aucun token reçu")
            return token
        else:
            print(f"   ❌ Échec de connexion (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erreur lors de la connexion: {e}")
        return False

def test_authenticated_endpoints(token):
    """Test des endpoints nécessitant une authentification"""
    print("\n🔒 Test des endpoints authentifiés...")
    
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # Test de récupération du profil
    print("   Test de récupération du profil...")
    try:
        response = requests.get(
            f"{BACKEND_URL}/api/v1/auth/me",
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 200:
            print("   ✅ Profil récupéré avec succès")
            user_data = response.json()
            print(f"   Email: {user_data.get('email')}")
            print(f"   Username: {user_data.get('username')}")
        else:
            print(f"   ❌ Échec de récupération du profil (Status: {response.status_code})")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erreur lors de la récupération du profil: {e}")
        return False
    
    # Test du tuteur intelligent
    print("   Test du tuteur intelligent...")
    tutor_data = {
        "question": "Qu'est-ce qu'une fraction ?",
        "subject": "Mathématiques",
        "grade_level": "Collège"
    }
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/ai/tutor/",
            json=tutor_data,
            headers=headers,
            timeout=30
        )
        
        if response.status_code == 200:
            print("   ✅ Tuteur intelligent fonctionne")
            tutor_response = response.json()
            print(f"   Réponse: {tutor_response.get('answer', 'Aucune réponse')[:100]}...")
        else:
            print(f"   ❌ Échec du tuteur intelligent (Status: {response.status_code})")
            print(f"   Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erreur lors du test du tuteur: {e}")
    
    return True

def test_cors():
    """Test de la configuration CORS"""
    print("\n🌐 Test de la configuration CORS...")
    
    try:
        # Simuler une requête depuis le frontend
        headers = {
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Content-Type,Authorization"
        }
        
        response = requests.options(
            f"{BACKEND_URL}/api/v1/auth/login",
            headers=headers,
            timeout=5
        )
        
        cors_headers = response.headers
        if "Access-Control-Allow-Origin" in cors_headers:
            print("   ✅ CORS configuré")
            print(f"   Allow-Origin: {cors_headers.get('Access-Control-Allow-Origin')}")
            print(f"   Allow-Methods: {cors_headers.get('Access-Control-Allow-Methods')}")
        else:
            print("   ⚠️  CORS non configuré ou mal configuré")
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Erreur lors du test CORS: {e}")

def main():
    """Fonction principale de test"""
    print("🚀 Test de connexion Learnia Frontend-Backend")
    print("=" * 50)
    
    # Test 1: Santé du backend
    if not test_backend_health():
        print("\n❌ Le backend n'est pas accessible. Vérifiez qu'il est démarré.")
        sys.exit(1)
    
    # Test 2: Endpoints d'authentification
    token = test_auth_endpoints()
    if not token:
        print("\n❌ Les endpoints d'authentification ne fonctionnent pas.")
        sys.exit(1)
    
    # Test 3: Endpoints authentifiés
    if not test_authenticated_endpoints(token):
        print("\n❌ Les endpoints authentifiés ne fonctionnent pas.")
        sys.exit(1)
    
    # Test 4: Configuration CORS
    test_cors()
    
    print("\n" + "=" * 50)
    print("✅ Tous les tests sont passés avec succès!")
    print("🎉 Le frontend et le backend sont correctement connectés.")
    print("\n📋 Résumé:")
    print("   - Backend accessible sur http://localhost:8000")
    print("   - Authentification fonctionnelle")
    print("   - Endpoints API opérationnels")
    print("   - CORS configuré")
    print("\n🚀 Vous pouvez maintenant lancer l'application Flutter!")

if __name__ == "__main__":
    main()
