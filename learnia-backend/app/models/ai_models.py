from datetime import datetime
from typing import List, Optional

from sqlmodel import Field, SQLModel


# Modèles pour le tuteur intelligent
class TutorRequest(SQLModel):
    """Requête pour le tuteur intelligent"""

    question: str = Field(..., min_length=1, max_length=1000)
    subject: str = Field(..., min_length=1, max_length=100)
    grade_level: Optional[str] = None
    context: Optional[str] = None


class TutorResponse(SQLModel):
    """Réponse du tuteur intelligent"""

    answer: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    source: str = "ai_api"  # ai_api, local, offline
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour le générateur de QCM
class QcmRequest(SQLModel):
    """Requête pour générer des QCM"""

    text: str = Field(..., min_length=10, max_length=5000)
    subject: str = Field(..., min_length=1, max_length=100)
    num_questions: int = Field(default=5, ge=1, le=20)
    difficulty: Optional[str] = "medium"  # easy, medium, hard


class QcmQuestion(SQLModel):
    """Question de QCM"""

    question: str
    options: List[str] = Field(..., min_items=2, max_items=6)
    correct_answer: str
    explanation: Optional[str] = None


class QcmResponse(SQLModel):
    """Réponse avec les questions QCM générées"""

    questions: List[QcmQuestion]
    subject: str
    difficulty: str
    generated_at: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour le résumé automatique
class SummaryRequest(SQLModel):
    """Requête pour générer un résumé"""

    text: str = Field(..., min_length=50, max_length=10000)
    subject: str = Field(..., min_length=1, max_length=100)
    max_length: int = Field(default=200, ge=50, le=1000)
    style: Optional[str] = (
        "bullet_points"  # bullet_points, paragraph, structured
    )


class SummaryResponse(SQLModel):
    """Réponse avec le résumé généré"""

    summary: str
    original_length: int
    summary_length: int
    compression_ratio: float
    key_points: Optional[List[str]] = None
    generated_at: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour la traduction
class TranslationRequest(SQLModel):
    """Requête pour traduire un texte"""

    text: str = Field(..., min_length=1, max_length=2000)
    source_language: str = Field(default="fr")
    target_language: str = Field(..., min_length=2, max_length=10)
    context: Optional[str] = None


class TranslationResponse(SQLModel):
    """Réponse avec la traduction"""

    original_text: str
    translated_text: str
    source_language: str
    target_language: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    detected_language: Optional[str] = None
    generated_at: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour l'orientation scolaire
class OrientationQuestion(SQLModel):
    """Question d'orientation"""

    question_id: str
    question: str
    options: List[str]
    category: str  # interests, skills, personality, etc.


class OrientationAnswer(SQLModel):
    """Réponse à une question d'orientation"""

    question_id: str
    answer: str


class OrientationRequest(SQLModel):
    """Requête pour l'orientation scolaire"""

    answers: List[OrientationAnswer]
    grade_level: str
    current_subjects: Optional[List[str]] = None


class OrientationResponse(SQLModel):
    """Réponse avec l'orientation suggérée"""

    suggested_fields: List[str]
    suggested_careers: List[str]
    explanation: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    recommendations: List[str]
    generated_at: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour l'OCR
class OcrRequest(SQLModel):
    """Requête pour la reconnaissance de texte"""

    image_base64: str = Field(..., min_length=100)
    language: str = Field(default="fr")
    confidence_threshold: float = Field(default=0.7, ge=0.0, le=1.0)


class OcrResponse(SQLModel):
    """Réponse avec le texte reconnu"""

    text: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    detected_language: Optional[str] = None
    word_count: int
    processing_time: float
    generated_at: datetime = Field(default_factory=datetime.utcnow)


# Modèles pour les statistiques et analytics
class UserStats(SQLModel):
    """Statistiques utilisateur"""

    user_id: int
    total_questions_asked: int = 0
    total_qcm_taken: int = 0
    total_summaries_generated: int = 0
    total_translations: int = 0
    average_score: float = 0.0
    favorite_subject: Optional[str] = None
    study_time_minutes: int = 0
    last_activity: Optional[datetime] = None


class ApiUsage(SQLModel):
    """Statistiques d'utilisation des APIs"""

    endpoint: str
    total_calls: int = 0
    successful_calls: int = 0
    failed_calls: int = 0
    average_response_time: float = 0.0
    last_called: Optional[datetime] = None
