"""
Tests pour le tuteur intelligent
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock

from app.models.ai_models import TutorRequest, TutorResponse


class TestTutor:
    """Tests pour les endpoints du tuteur intelligent"""

    def test_ask_tutor_success(self, client: TestClient, auth_headers: dict):
        """Test de question au tuteur avec succès"""
        question_data = {
            "question": "Qu'est-ce qu'une fraction ?",
            "subject": "Mathématiques",
            "grade_level": "Collège",
            "context": "Apprentissage des fractions"
        }
        
        # Mock de la réponse IA
        with patch('app.services.ai_service.ai_service.generate_tutor_response') as mock_ai:
            mock_ai.return_value = TutorResponse(
                answer="Une fraction représente une partie d'un tout...",
                confidence=0.9,
                source="ai_api"
            )
            
            response = client.post(
                "/api/v1/ai/tutor/",
                json=question_data,
                headers=auth_headers
            )
            
            assert response.status_code == 200
            data = response.json()
            assert "answer" in data
            assert "confidence" in data
            assert "source" in data
            assert data["confidence"] == 0.9

    def test_ask_tutor_unauthorized(self, client: TestClient):
        """Test de question au tuteur sans authentification"""
        question_data = {
            "question": "Qu'est-ce qu'une fraction ?",
            "subject": "Mathématiques"
        }
        
        response = client.post("/api/v1/ai/tutor/", json=question_data)
        
        assert response.status_code == 401

    def test_ask_tutor_invalid_data(self, client: TestClient, auth_headers: dict):
        """Test de question au tuteur avec données invalides"""
        # Question vide
        question_data = {
            "question": "",
            "subject": "Mathématiques"
        }
        
        response = client.post(
            "/api/v1/ai/tutor/",
            json=question_data,
            headers=auth_headers
        )
        
        assert response.status_code == 422

    def test_ask_tutor_long_question(self, client: TestClient, auth_headers: dict):
        """Test de question au tuteur avec question trop longue"""
        long_question = "a" * 1001  # Plus de 1000 caractères
        
        question_data = {
            "question": long_question,
            "subject": "Mathématiques"
        }
        
        response = client.post(
            "/api/v1/ai/tutor/",
            json=question_data,
            headers=auth_headers
        )
        
        assert response.status_code == 422

    def test_ask_tutor_ai_error(self, client: TestClient, auth_headers: dict):
        """Test de question au tuteur avec erreur IA"""
        question_data = {
            "question": "Qu'est-ce qu'une fraction ?",
            "subject": "Mathématiques"
        }
        
        # Mock d'une erreur IA
        with patch('app.services.ai_service.ai_service.generate_tutor_response') as mock_ai:
            mock_ai.side_effect = Exception("Erreur IA")
            
            response = client.post(
                "/api/v1/ai/tutor/",
                json=question_data,
                headers=auth_headers
            )
            
            assert response.status_code == 500

    def test_get_suggestions(self, client: TestClient, auth_headers: dict):
        """Test d'obtention des suggestions de questions"""
        response = client.get(
            "/api/v1/ai/tutor/suggestions/mathématiques",
            headers=auth_headers
        )
        
        assert response.status_code == 200
        data = response.json()
        assert "subject" in data
        assert "suggestions" in data
        assert data["subject"] == "mathématiques"
        assert isinstance(data["suggestions"], list)
        assert len(data["suggestions"]) > 0

    def test_get_suggestions_unauthorized(self, client: TestClient):
        """Test d'obtention des suggestions sans authentification"""
        response = client.get("/api/v1/ai/tutor/suggestions/mathématiques")
        
        assert response.status_code == 401

    def test_get_subjects(self, client: TestClient):
        """Test d'obtention des matières supportées"""
        response = client.get("/api/v1/ai/tutor/subjects")
        
        assert response.status_code == 200
        data = response.json()
        assert "subjects" in data
        assert isinstance(data["subjects"], list)
        assert "Mathématiques" in data["subjects"]
        assert "Français" in data["subjects"]

    def test_tutor_health(self, client: TestClient):
        """Test de l'état du service tuteur"""
        response = client.get("/api/v1/ai/tutor/health")
        
        assert response.status_code == 200
        data = response.json()
        assert "status" in data
        assert "service" in data
        assert data["status"] == "healthy"
        assert data["service"] == "tutor"

    def test_tutor_with_different_subjects(self, client: TestClient, auth_headers: dict):
        """Test du tuteur avec différentes matières"""
        subjects = ["Mathématiques", "Français", "Histoire", "Sciences"]
        
        for subject in subjects:
            question_data = {
                "question": f"Question sur {subject}",
                "subject": subject
            }
            
            with patch('app.services.ai_service.ai_service.generate_tutor_response') as mock_ai:
                mock_ai.return_value = TutorResponse(
                    answer=f"Réponse pour {subject}",
                    confidence=0.8,
                    source="ai_api"
                )
                
                response = client.post(
                    "/api/v1/ai/tutor/",
                    json=question_data,
                    headers=auth_headers
                )
                
                assert response.status_code == 200

    def test_tutor_context_handling(self, client: TestClient, auth_headers: dict):
        """Test de gestion du contexte dans les questions"""
        question_data = {
            "question": "Explique-moi les équations",
            "subject": "Mathématiques",
            "grade_level": "Primaire",
            "context": "Élève en difficulté avec l'algèbre"
        }
        
        with patch('app.services.ai_service.ai_service.generate_tutor_response') as mock_ai:
            mock_ai.return_value = TutorResponse(
                answer="Explication adaptée au primaire...",
                confidence=0.9,
                source="ai_api"
            )
            
            response = client.post(
                "/api/v1/ai/tutor/",
                json=question_data,
                headers=auth_headers
            )
            
            assert response.status_code == 200
            # Vérifier que le contexte est passé au service IA
            mock_ai.assert_called_once()
            call_args = mock_ai.call_args[0][0]
            assert call_args.context == "Élève en difficulté avec l'algèbre"
            assert call_args.grade_level == "Primaire"
