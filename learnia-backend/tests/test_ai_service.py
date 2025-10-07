"""
Tests pour le service IA
"""
import pytest
from unittest.mock import patch, AsyncMock, MagicMock
from app.services.ai_service import AIService
from app.models.ai_models import (
    TutorRequest, QcmRequest, SummaryRequest, 
    TranslationRequest, OrientationRequest, OcrRequest
)


class TestAIService:
    """Tests pour le service IA"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.ai_service = AIService()

    def test_init_without_openai_key(self):
        """Test d'initialisation sans clé OpenAI"""
        service = AIService()
        assert service.openai_client is None

    @patch('app.services.ai_service.AsyncOpenAI')
    def test_init_with_openai_key(self, mock_openai):
        """Test d'initialisation avec clé OpenAI"""
        with patch('app.config.settings.openai_api_key', 'test-key'):
            service = AIService()
            assert service.openai_client is not None

    @pytest.mark.asyncio
    async def test_generate_tutor_response_with_openai(self):
        """Test de génération de réponse tuteur avec OpenAI"""
        # Mock OpenAI client
        mock_client = AsyncMock()
        mock_response = MagicMock()
        mock_response.choices[0].message.content = "Réponse IA générée"
        mock_client.chat.completions.create.return_value = mock_response
        
        self.ai_service.openai_client = mock_client
        
        request = TutorRequest(
            question="Qu'est-ce qu'une fraction ?",
            subject="Mathématiques",
            grade_level="Collège"
        )
        
        response = await self.ai_service.generate_tutor_response(request)
        
        assert response.answer == "Réponse IA générée"
        assert response.confidence == 0.9
        assert response.source == "ai_api"

    @pytest.mark.asyncio
    async def test_generate_tutor_response_local_fallback(self):
        """Test de génération de réponse tuteur en mode local"""
        request = TutorRequest(
            question="Qu'est-ce qu'une fraction ?",
            subject="Mathématiques",
            grade_level="Collège"
        )
        
        response = await self.ai_service.generate_tutor_response(request)
        
        assert "fraction" in response.answer.lower()
        assert response.source == "local"
        assert response.confidence == 0.7

    @pytest.mark.asyncio
    async def test_generate_tutor_response_error_handling(self):
        """Test de gestion d'erreur dans la génération de réponse"""
        # Mock OpenAI pour lever une exception
        mock_client = AsyncMock()
        mock_client.chat.completions.create.side_effect = Exception("Erreur API")
        self.ai_service.openai_client = mock_client
        
        request = TutorRequest(
            question="Question test",
            subject="Mathématiques"
        )
        
        response = await self.ai_service.generate_tutor_response(request)
        
        assert response.source == "offline"
        assert response.confidence == 0.5

    @pytest.mark.asyncio
    async def test_generate_qcm_questions(self):
        """Test de génération de questions QCM"""
        request = QcmRequest(
            text="Les fractions sont des nombres qui représentent une partie d'un tout.",
            subject="Mathématiques",
            num_questions=3
        )
        
        response = await self.ai_service.generate_qcm_questions(request)
        
        assert len(response.questions) > 0
        assert response.subject == "Mathématiques"
        assert response.difficulty == "medium"

    @pytest.mark.asyncio
    async def test_generate_summary(self):
        """Test de génération de résumé"""
        request = SummaryRequest(
            text="Ceci est un long texte sur les mathématiques. " * 10,
            subject="Mathématiques",
            max_length=100
        )
        
        response = await self.ai_service.generate_summary(request)
        
        assert len(response.summary) > 0
        assert response.original_length > response.summary_length
        assert response.compression_ratio > 0

    @pytest.mark.asyncio
    async def test_translate_text_local(self):
        """Test de traduction en mode local"""
        request = TranslationRequest(
            text="bonjour",
            source_language="fr",
            target_language="éwé"
        )
        
        response = await self.ai_service.translate_text(request)
        
        assert response.original_text == "bonjour"
        assert response.translated_text != "bonjour"  # Doit être traduit
        assert response.confidence > 0

    @pytest.mark.asyncio
    async def test_analyze_orientation(self):
        """Test d'analyse d'orientation"""
        from app.models.ai_models import OrientationAnswer
        
        answers = [
            OrientationAnswer(question_id="q1", answer="Sciences"),
            OrientationAnswer(question_id="q2", answer="Mathématiques")
        ]
        
        request = OrientationRequest(
            answers=answers,
            grade_level="Lycée"
        )
        
        response = await self.ai_service.analyze_orientation(request)
        
        assert len(response.suggested_fields) > 0
        assert len(response.suggested_careers) > 0
        assert response.explanation is not None
        assert response.confidence > 0

    @pytest.mark.asyncio
    async def test_perform_ocr(self):
        """Test de reconnaissance de texte (OCR)"""
        # Image base64 factice
        fake_image_b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg=="
        
        request = OcrRequest(
            image_base64=fake_image_b64,
            language="fr"
        )
        
        with patch('pytesseract.image_to_string') as mock_ocr:
            mock_ocr.return_value = "Texte reconnu"
            
            response = await self.ai_service.perform_ocr(request)
            
            assert response.text == "Texte reconnu"
            assert response.confidence > 0
            assert response.word_count >= 0

    def test_local_translations(self):
        """Test des traductions locales"""
        # Test éwé
        request_ewe = TranslationRequest(
            text="bonjour",
            source_language="fr",
            target_language="éwé"
        )
        
        result = self.ai_service._translate_local(request_ewe)
        assert result != "bonjour"  # Doit être traduit
        
        # Test kabiyè
        request_kab = TranslationRequest(
            text="merci",
            source_language="fr",
            target_language="kabiyè"
        )
        
        result = self.ai_service._translate_local(request_kab)
        assert result != "merci"  # Doit être traduit

    def test_generate_local_tutor_response(self):
        """Test de génération de réponse locale"""
        request = TutorRequest(
            question="Qu'est-ce qu'une fraction ?",
            subject="Mathématiques"
        )
        
        response = self.ai_service._generate_local_tutor_response(request)
        
        assert "fraction" in response.lower()
        assert len(response) > 0

    def test_generate_local_qcm_questions(self):
        """Test de génération de questions QCM locales"""
        request = QcmRequest(
            text="Test text",
            subject="Mathématiques",
            num_questions=2
        )
        
        questions = self.ai_service._generate_local_qcm_questions(request)
        
        assert len(questions) == 2
        assert all(q.question for q in questions)
        assert all(len(q.options) >= 2 for q in questions)

    def test_generate_local_summary(self):
        """Test de génération de résumé local"""
        request = SummaryRequest(
            text="Première phrase. Deuxième phrase. Troisième phrase. Quatrième phrase.",
            subject="Test"
        )
        
        summary = self.ai_service._generate_local_summary(request)
        
        assert len(summary) < len(request.text)
        assert "Première phrase" in summary

    def test_generate_local_orientation(self):
        """Test de génération d'orientation locale"""
        from app.models.ai_models import OrientationAnswer
        
        answers = [
            OrientationAnswer(question_id="q1", answer="Sciences")
        ]
        
        request = OrientationRequest(
            answers=answers,
            grade_level="Lycée"
        )
        
        result = self.ai_service._generate_local_orientation(request)
        
        assert "fields" in result
        assert "careers" in result
        assert "explanation" in result
        assert "recommendations" in result
        assert len(result["fields"]) > 0
