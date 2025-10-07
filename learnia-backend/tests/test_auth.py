"""
Tests pour l'authentification
"""
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session

from app.models.user import User


class TestAuth:
    """Tests pour les endpoints d'authentification"""

    def test_register_success(self, client: TestClient, db_session: Session):
        """Test d'inscription réussie"""
        user_data = {
            "email": "newuser@example.com",
            "username": "newuser",
            "full_name": "New User",
            "password": "newpassword123",
            "grade_level": "Collège",
            "school": "Test School"
        }
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == user_data["email"]
        assert data["username"] == user_data["username"]
        assert "id" in data
        assert "hashed_password" not in data

    def test_register_duplicate_email(self, client: TestClient, test_user: User):
        """Test d'inscription avec email dupliqué"""
        user_data = {
            "email": test_user.email,  # Email déjà existant
            "username": "anotheruser",
            "full_name": "Another User",
            "password": "password123",
            "grade_level": "Collège"
        }
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 400
        assert "email" in response.json()["detail"].lower()

    def test_register_invalid_email(self, client: TestClient):
        """Test d'inscription avec email invalide"""
        user_data = {
            "email": "invalid-email",
            "username": "testuser",
            "full_name": "Test User",
            "password": "password123",
            "grade_level": "Collège"
        }
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 422

    def test_register_weak_password(self, client: TestClient):
        """Test d'inscription avec mot de passe faible"""
        user_data = {
            "email": "test@example.com",
            "username": "testuser",
            "full_name": "Test User",
            "password": "123",  # Mot de passe trop court
            "grade_level": "Collège"
        }
        
        response = client.post("/api/v1/auth/register", json=user_data)
        
        assert response.status_code == 422

    def test_login_success(self, client: TestClient, test_user: User):
        """Test de connexion réussie"""
        login_data = {
            "username": test_user.email,
            "password": "testpassword123"
        }
        
        response = client.post("/api/v1/auth/login", data=login_data)
        
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert data["token_type"] == "bearer"

    def test_login_wrong_password(self, client: TestClient, test_user: User):
        """Test de connexion avec mauvais mot de passe"""
        login_data = {
            "username": test_user.email,
            "password": "wrongpassword"
        }
        
        response = client.post("/api/v1/auth/login", data=login_data)
        
        assert response.status_code == 401
        assert "incorrect" in response.json()["detail"].lower()

    def test_login_nonexistent_user(self, client: TestClient):
        """Test de connexion avec utilisateur inexistant"""
        login_data = {
            "username": "nonexistent@example.com",
            "password": "password123"
        }
        
        response = client.post("/api/v1/auth/login", data=login_data)
        
        assert response.status_code == 401

    def test_get_current_user(self, client: TestClient, auth_headers: dict):
        """Test d'obtention des informations utilisateur actuel"""
        response = client.get("/api/v1/auth/me", headers=auth_headers)
        
        assert response.status_code == 200
        data = response.json()
        assert "email" in data
        assert "username" in data
        assert "hashed_password" not in data

    def test_get_current_user_unauthorized(self, client: TestClient):
        """Test d'obtention des informations sans authentification"""
        response = client.get("/api/v1/auth/me")
        
        assert response.status_code == 401

    def test_logout(self, client: TestClient, auth_headers: dict):
        """Test de déconnexion"""
        response = client.post("/api/v1/auth/logout", headers=auth_headers)
        
        assert response.status_code == 200
        assert "successfully" in response.json()["message"].lower()

    def test_password_hashing(self):
        """Test du hachage des mots de passe"""
        from app.services.auth import get_password_hash, verify_password
        
        password = "testpassword123"
        hashed = get_password_hash(password)
        
        # Le hash ne doit pas être identique au mot de passe
        assert hashed != password
        
        # La vérification doit fonctionner
        assert verify_password(password, hashed)
        assert not verify_password("wrongpassword", hashed)

    def test_token_expiration(self, client: TestClient, test_user: User):
        """Test d'expiration du token"""
        # Ce test nécessiterait une configuration spéciale pour des tokens courts
        # Pour l'instant, on teste juste que le token est valide
        login_data = {
            "username": test_user.email,
            "password": "testpassword123"
        }
        
        response = client.post("/api/v1/auth/login", data=login_data)
        assert response.status_code == 200
        
        token = response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}
        
        # Le token doit être valide immédiatement
        response = client.get("/api/v1/auth/me", headers=headers)
        assert response.status_code == 200
