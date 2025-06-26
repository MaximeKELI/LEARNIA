import base64
import io
import time
from typing import Any, Dict, List

import pytesseract
from loguru import logger
from openai import AsyncOpenAI
from PIL import Image

from ..config import settings
from ..models.ai_models import (
    OcrRequest,
    OcrResponse,
    OrientationRequest,
    OrientationResponse,
    QcmQuestion,
    QcmRequest,
    QcmResponse,
    SummaryRequest,
    SummaryResponse,
    TranslationRequest,
    TranslationResponse,
    TutorRequest,
    TutorResponse,
)


class AIService:
    """Service principal pour toutes les fonctionnalités d'IA"""

    def __init__(self):
        self.openai_client = None
        if settings.openai_api_key:
            self.openai_client = AsyncOpenAI(api_key=settings.openai_api_key)

        # Modèles locaux (optionnels)
        self.translation_pipeline = None
        self.summarization_pipeline = None

        # Dictionnaire de traductions locales
        self.local_translations = {
            "éwé": {
                "bonjour": "Woé zɔ",
                "merci": "Akpé",
                "comment allez-vous": "Êfoa woé",
                "au revoir": "Hede nyuie",
                "oui": "Ee",
                "non": "Ao",
            },
            "kabiyè": {
                "bonjour": "Yaa",
                "merci": "Yoo",
                "comment allez-vous": "Yaa yaa",
                "au revoir": "Yaa yaa",
                "oui": "Ee",
                "non": "Ao",
            },
        }

    async def generate_tutor_response(
        self, request: TutorRequest
    ) -> TutorResponse:
        """Génère une réponse pour le tuteur intelligent"""
        start_time = time.time()

        try:
            if self.openai_client:
                # Utiliser OpenAI
                response = await self._call_openai_tutor(request)
                source = "ai_api"
                confidence = 0.9
            else:
                # Fallback local
                response = self._generate_local_tutor_response(request)
                source = "local"
                confidence = 0.7

            processing_time = time.time() - start_time
            logger.info(f"Réponse tuteur générée en {processing_time:.2f}s")

            return TutorResponse(
                answer=response, confidence=confidence, source=source
            )

        except Exception as e:
            logger.error(f"Erreur génération réponse tuteur: {e}")
            return TutorResponse(
                answer=self._generate_fallback_response(request),
                confidence=0.5,
                source="offline",
            )

    async def generate_qcm_questions(self, request: QcmRequest) -> QcmResponse:
        """Génère des questions QCM"""
        start_time = time.time()

        try:
            if self.openai_client:
                # Utiliser OpenAI
                questions = await self._call_openai_qcm(request)
            else:
                # Fallback local
                questions = self._generate_local_qcm_questions(request)

            processing_time = time.time() - start_time
            logger.info(f"QCM généré en {processing_time:.2f}s")

            return QcmResponse(
                questions=questions,
                subject=request.subject,
                difficulty=request.difficulty,
            )

        except Exception as e:
            logger.error(f"Erreur génération QCM: {e}")
            return QcmResponse(
                questions=self._generate_fallback_qcm(request),
                subject=request.subject,
                difficulty="easy",
            )

    async def generate_summary(
        self, request: SummaryRequest
    ) -> SummaryResponse:
        """Génère un résumé automatique"""
        start_time = time.time()

        try:
            if self.openai_client:
                # Utiliser OpenAI
                summary = await self._call_openai_summary(request)
            else:
                # Fallback local
                summary = self._generate_local_summary(request)

            processing_time = time.time() - start_time
            original_length = len(request.text.split())
            summary_length = len(summary.split())
            compression_ratio = (
                summary_length / original_length if original_length > 0 else 0
            )

            logger.info(f"Résumé généré en {processing_time:.2f}s")

            return SummaryResponse(
                summary=summary,
                original_length=original_length,
                summary_length=summary_length,
                compression_ratio=compression_ratio,
            )

        except Exception as e:
            logger.error(f"Erreur génération résumé: {e}")
            return SummaryResponse(
                summary=self._generate_fallback_summary(request),
                original_length=len(request.text.split()),
                summary_length=0,
                compression_ratio=0,
            )

    async def translate_text(
        self, request: TranslationRequest
    ) -> TranslationResponse:
        """Traduit un texte"""
        start_time = time.time()

        try:
            if request.target_language in ["éwé", "kab"]:
                # Traduction locale
                translated_text = self._translate_local(request)
                confidence = 0.8
            elif self.openai_client:
                # Utiliser OpenAI
                translated_text = await self._call_openai_translation(request)
                confidence = 0.9
            else:
                # Fallback
                translated_text = request.text
                confidence = 0.5

            processing_time = time.time() - start_time
            logger.info(f"Traduction effectuée en {processing_time:.2f}s")

            return TranslationResponse(
                original_text=request.text,
                translated_text=translated_text,
                source_language=request.source_language,
                target_language=request.target_language,
                confidence=confidence,
            )

        except Exception as e:
            logger.error(f"Erreur traduction: {e}")
            return TranslationResponse(
                original_text=request.text,
                translated_text=request.text,
                source_language=request.source_language,
                target_language=request.target_language,
                confidence=0.0,
            )

    async def analyze_orientation(
        self, request: OrientationRequest
    ) -> OrientationResponse:
        """Analyse l'orientation scolaire"""
        start_time = time.time()

        try:
            if self.openai_client:
                # Utiliser OpenAI
                result = await self._call_openai_orientation(request)
                confidence = 0.9
            else:
                # Fallback local
                result = self._generate_local_orientation(request)
                confidence = 0.7

            processing_time = time.time() - start_time
            logger.info(f"Orientation analysée en {processing_time:.2f}s")

            return OrientationResponse(
                suggested_fields=result["fields"],
                suggested_careers=result["careers"],
                explanation=result["explanation"],
                confidence=confidence,
                recommendations=result["recommendations"],
            )

        except Exception as e:
            logger.error(f"Erreur analyse orientation: {e}")
            return OrientationResponse(
                suggested_fields=["Sciences et Technologies"],
                suggested_careers=["Ingénieur", "Médecin", "Enseignant"],
                explanation="Analyse basée sur des critères généraux",
                confidence=0.5,
                recommendations=[
                    "Continuez vos études",
                    "Développez vos compétences",
                ],
            )

    async def perform_ocr(self, request: OcrRequest) -> OcrResponse:
        """Effectue la reconnaissance de texte (OCR)"""
        start_time = time.time()

        try:
            # Décoder l'image base64
            image_data = base64.b64decode(request.image_base64)
            image = Image.open(io.BytesIO(image_data))

            # Utiliser pytesseract pour l'OCR
            text = pytesseract.image_to_string(
                image, lang=request.language, config="--psm 6"
            )

            processing_time = time.time() - start_time
            word_count = len(text.split())

            logger.info(f"OCR effectué en {processing_time:.2f}s")

            return OcrResponse(
                text=text.strip(),
                confidence=0.8,  # Estimation
                word_count=word_count,
                processing_time=processing_time,
            )

        except Exception as e:
            logger.error(f"Erreur OCR: {e}")
            return OcrResponse(
                text="Erreur de reconnaissance de texte",
                confidence=0.0,
                word_count=0,
                processing_time=0,
            )

    # Méthodes privées pour les appels OpenAI
    async def _call_openai_tutor(self, request: TutorRequest) -> str:
        """Appel OpenAI pour le tuteur"""
        prompt = f"""
        Tu es un tuteur éducatif pour des élèves togolais du primaire à la 
        terminale. Réponds de manière simple et claire en français. Adapte 
        ton explication au niveau de l'élève.
        
        Question: {request.question}
        Matière: {request.subject}
        Niveau: {request.grade_level or 'Collège'}
        """

        response = await self.openai_client.chat.completions.create(
            model=settings.default_ai_model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=settings.max_tokens,
            temperature=settings.temperature,
        )

        return response.choices[0].message.content

    async def _call_openai_qcm(self, request: QcmRequest) -> List[QcmQuestion]:
        """Appel OpenAI pour générer des QCM"""
        prompt = f"""
        Génère {request.num_questions} questions à choix multiples basées 
        sur ce texte: {request.text}
        
        Format JSON:
        {{
            "questions": [
                {{
                    "question": "Question ici",
                    "options": ["A", "B", "C", "D"],
                    "correct_answer": "A",
                    "explanation": "Explication optionnelle"
                }}
            ]
        }}
        """

        await self.openai_client.chat.completions.create(
            model=settings.default_ai_model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=1000,
            temperature=0.7,
        )

        # Pour simplifier on génère des questions basiques
        return self._generate_local_qcm_questions(request)

    async def _call_openai_summary(self, request: SummaryRequest) -> str:
        """Appel OpenAI pour le résumé"""
        prompt = f"""
        Résume ce texte en français de manière claire et structurée:
        {request.text}
        
        Longueur maximale: {request.max_length} mots
        Style: {request.style}
        """

        response = await self.openai_client.chat.completions.create(
            model=settings.default_ai_model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=request.max_length,
            temperature=0.5,
        )

        return response.choices[0].message.content

    async def _call_openai_translation(
        self, request: TranslationRequest
    ) -> str:
        """Appel OpenAI pour la traduction"""
        prompt = f"""
        Traduis ce texte du français vers {request.target_language}:
        {request.text}
        
        Contexte: {request.context or 'Éducation'}
        """

        response = await self.openai_client.chat.completions.create(
            model=settings.default_ai_model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=500,
            temperature=0.3,
        )

        return response.choices[0].message.content

    async def _call_openai_orientation(
        self, request: OrientationRequest
    ) -> Dict[str, Any]:
        """Appel OpenAI pour l'orientation"""
        answers_text = "\n".join(
            [f"Q{ans.question_id}: {ans.answer}" for ans in request.answers]
        )

        prompt = f"""
        Analyse les réponses de cet élève pour l'orientation scolaire:
        
        Niveau: {request.grade_level}
        Matières actuelles: {', '.join(request.current_subjects or [])}
        
        Réponses:
        {answers_text}
        
        Donne des suggestions de filières et métiers en JSON:
        {{
            "fields": ["filière1", "filière2"],
            "careers": ["métier1", "métier2"],
            "explanation": "explication",
            "recommendations": ["recommandation1", "recommandation2"]
        }}
        """

        await self.openai_client.chat.completions.create(
            model=settings.default_ai_model,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=800,
            temperature=0.7,
        )

        # Parse la réponse JSON (simplifié)
        return self._generate_local_orientation(request)

    # Méthodes de fallback local
    def _generate_local_tutor_response(self, request: TutorRequest) -> str:
        """Génère une réponse locale pour le tuteur"""
        responses = {
            "mathématiques": {
                "fraction": (
                    "Les fractions représentent une partie d'un tout. "
                    "Par exemple, 1/2 signifie une partie sur deux "
                    "parties égales."
                ),
                "géométrie": (
                    "La géométrie étudie les formes et les figures "
                    "dans l'espace."
                ),
                "algèbre": (
                    "L'algèbre utilise des lettres pour représenter "
                    "des nombres inconnus."
                ),
            },
            "français": {
                "grammaire": (
                    "La grammaire étudie la structure et les règles "
                    "de la langue française."
                ),
                "conjugaison": (
                    "La conjugaison indique le temps et la personne "
                    "du verbe."
                ),
                "orthographe": (
                    "L'orthographe concerne l'écriture correcte " "des mots."
                ),
            },
        }

        subject_responses = responses.get(request.subject.lower(), {})
        for keyword, response in subject_responses.items():
            if keyword in request.question.lower():
                return response

        return (
            f"Je comprends votre question sur {request.subject}. "
            "Voici une explication simple..."
        )

    def _generate_local_qcm_questions(
        self, request: QcmRequest
    ) -> List[QcmQuestion]:
        """Génère des questions QCM locales"""
        return [
            QcmQuestion(
                question=f"Qu'est-ce que {request.subject} ?",
                options=["Option A", "Option B", "Option C", "Option D"],
                correct_answer="Option A",
                explanation="Explication de la réponse",
            ),
            QcmQuestion(
                question="Quelle est la définition principale ?",
                options=["Réponse 1", "Réponse 2", "Réponse 3", "Réponse 4"],
                correct_answer="Réponse 1",
                explanation="Explication de la réponse",
            ),
        ]

    def _generate_local_summary(self, request: SummaryRequest) -> str:
        """Génère un résumé local"""
        sentences = request.text.split(".")
        if len(sentences) <= 3:
            return request.text

        return ". ".join(sentences[:3]) + "."

    def _translate_local(self, request: TranslationRequest) -> str:
        """Traduit localement"""
        translations = self.local_translations.get(request.target_language, {})
        translated_text = request.text

        for french, local in translations.items():
            translated_text = translated_text.replace(french, local)

        return translated_text

    def _generate_local_orientation(
        self, request: OrientationRequest
    ) -> Dict[str, Any]:
        """Génère une orientation locale"""
        return {
            "fields": [
                "Sciences et Technologies",
                "Lettres et Sciences Humaines",
            ],
            "careers": ["Ingénieur", "Médecin", "Enseignant", "Avocat"],
            "explanation": (
                "Basé sur vos réponses, nous vous suggérons " "ces filières..."
            ),
            "recommendations": [
                "Continuez vos études",
                "Développez vos compétences",
                "Explorez différents domaines",
            ],
        }

    def _generate_fallback_response(self, request: TutorRequest) -> str:
        """Réponse de fallback"""
        return (
            f"Désolé, je ne peux pas répondre à cette question sur "
            f"{request.subject} pour le moment."
        )

    def _generate_fallback_qcm(self, request: QcmRequest) -> List[QcmQuestion]:
        """QCM de fallback"""
        return [
            QcmQuestion(
                question="Question de fallback",
                options=["A", "B", "C", "D"],
                correct_answer="A",
                explanation="Réponse de fallback",
            )
        ]

    def _generate_fallback_summary(self, request: SummaryRequest) -> str:
        """Résumé de fallback"""
        return "Impossible de générer un résumé pour le moment."


# Instance globale du service IA
ai_service = AIService()
