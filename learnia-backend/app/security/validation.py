"""
Module de validation et de sécurité des données
"""
import re
import html
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, validator, Field
from fastapi import HTTPException, status


class SecurityValidator:
    """Classe pour la validation de sécurité des données"""

    # Patterns de validation
    EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    USERNAME_PATTERN = re.compile(r'^[a-zA-Z0-9_-]{3,20}$')
    PASSWORD_PATTERN = re.compile(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
    PHONE_PATTERN = re.compile(r'^\+?[1-9]\d{1,14}$')
    
    # Mots interdits (basique)
    FORBIDDEN_WORDS = [
        'script', 'javascript', 'vbscript', 'onload', 'onerror',
        'onclick', 'onmouseover', 'alert', 'prompt', 'confirm',
        'eval', 'expression', 'iframe', 'object', 'embed'
    ]

    @classmethod
    def validate_email(cls, email: str) -> str:
        """Valide et nettoie une adresse email"""
        if not email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="L'adresse email est requise"
            )
        
        email = email.strip().lower()
        
        if not cls.EMAIL_PATTERN.match(email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Format d'email invalide"
            )
        
        # Vérifier la longueur
        if len(email) > 254:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="L'email est trop long"
            )
        
        return email

    @classmethod
    def validate_username(cls, username: str) -> str:
        """Valide et nettoie un nom d'utilisateur"""
        if not username:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le nom d'utilisateur est requis"
            )
        
        username = username.strip()
        
        if not cls.USERNAME_PATTERN.match(username):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le nom d'utilisateur doit contenir entre 3 et 20 caractères alphanumériques, tirets et underscores"
            )
        
        return username

    @classmethod
    def validate_password(cls, password: str) -> str:
        """Valide un mot de passe"""
        if not password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le mot de passe est requis"
            )
        
        if len(password) < 8:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le mot de passe doit contenir au moins 8 caractères"
            )
        
        if len(password) > 128:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le mot de passe est trop long"
            )
        
        if not cls.PASSWORD_PATTERN.match(password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Le mot de passe doit contenir au moins une minuscule, une majuscule, un chiffre et un caractère spécial"
            )
        
        return password

    @classmethod
    def validate_phone(cls, phone: Optional[str]) -> Optional[str]:
        """Valide un numéro de téléphone"""
        if not phone:
            return None
        
        phone = phone.strip()
        
        if not cls.PHONE_PATTERN.match(phone):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Format de numéro de téléphone invalide"
            )
        
        return phone

    @classmethod
    def sanitize_text(cls, text: str, max_length: int = 1000) -> str:
        """Nettoie et valide un texte"""
        if not text:
            return ""
        
        # Échapper les caractères HTML
        text = html.escape(text.strip())
        
        # Vérifier la longueur
        if len(text) > max_length:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Le texte ne doit pas dépasser {max_length} caractères"
            )
        
        # Vérifier les mots interdits
        text_lower = text.lower()
        for word in cls.FORBIDDEN_WORDS:
            if word in text_lower:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Le texte contient des éléments non autorisés"
                )
        
        return text

    @classmethod
    def validate_question_text(cls, text: str) -> str:
        """Valide le texte d'une question"""
        return cls.sanitize_text(text, max_length=1000)

    @classmethod
    def validate_subject(cls, subject: str) -> str:
        """Valide une matière"""
        if not subject:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="La matière est requise"
            )
        
        subject = subject.strip()
        
        # Liste des matières autorisées
        allowed_subjects = [
            "Mathématiques", "Français", "Histoire", "Géographie",
            "Sciences", "Anglais", "Philosophie", "Économie"
        ]
        
        if subject not in allowed_subjects:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Matière non autorisée"
            )
        
        return subject

    @classmethod
    def validate_grade_level(cls, grade_level: Optional[str]) -> Optional[str]:
        """Valide un niveau scolaire"""
        if not grade_level:
            return None
        
        grade_level = grade_level.strip()
        
        allowed_levels = ["Primaire", "Collège", "Lycée", "Terminale"]
        
        if grade_level not in allowed_levels:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Niveau scolaire non autorisé"
            )
        
        return grade_level

    @classmethod
    def validate_image_base64(cls, image_base64: str) -> str:
        """Valide une image en base64"""
        if not image_base64:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="L'image est requise"
            )
        
        # Vérifier la longueur minimale
        if len(image_base64) < 100:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Image invalide"
            )
        
        # Vérifier la longueur maximale (10MB)
        max_size = 10 * 1024 * 1024  # 10MB en base64
        if len(image_base64) > max_size:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="L'image est trop volumineuse (max 10MB)"
            )
        
        # Vérifier le format base64
        try:
            import base64
            base64.b64decode(image_base64)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Format d'image invalide"
            )
        
        return image_base64

    @classmethod
    def validate_rate_limit(cls, user_id: int, action: str, limit: int = 10, window: int = 60) -> bool:
        """Valide le rate limiting (simplifié)"""
        # Dans une vraie implémentation, utiliser Redis ou une base de données
        # pour stocker les compteurs de rate limiting
        return True

    @classmethod
    def validate_csrf_token(cls, token: str, session_token: str) -> bool:
        """Valide un token CSRF"""
        if not token or not session_token:
            return False
        
        return token == session_token


class SecureUserCreate(BaseModel):
    """Modèle sécurisé pour la création d'utilisateur"""
    email: str
    username: str
    full_name: Optional[str] = None
    password: str
    grade_level: Optional[str] = None
    school: Optional[str] = None
    phone: Optional[str] = None

    @validator('email')
    def validate_email(cls, v):
        return SecurityValidator.validate_email(v)

    @validator('username')
    def validate_username(cls, v):
        return SecurityValidator.validate_username(v)

    @validator('password')
    def validate_password(cls, v):
        return SecurityValidator.validate_password(v)

    @validator('full_name')
    def validate_full_name(cls, v):
        if v:
            return SecurityValidator.sanitize_text(v, max_length=100)
        return v

    @validator('school')
    def validate_school(cls, v):
        if v:
            return SecurityValidator.sanitize_text(v, max_length=200)
        return v

    @validator('phone')
    def validate_phone(cls, v):
        return SecurityValidator.validate_phone(v)

    @validator('grade_level')
    def validate_grade_level(cls, v):
        return SecurityValidator.validate_grade_level(v)


class SecureTutorRequest(BaseModel):
    """Modèle sécurisé pour les requêtes tuteur"""
    question: str = Field(..., min_length=1, max_length=1000)
    subject: str
    grade_level: Optional[str] = None
    context: Optional[str] = None

    @validator('question')
    def validate_question(cls, v):
        return SecurityValidator.validate_question_text(v)

    @validator('subject')
    def validate_subject(cls, v):
        return SecurityValidator.validate_subject(v)

    @validator('grade_level')
    def validate_grade_level(cls, v):
        return SecurityValidator.validate_grade_level(v)

    @validator('context')
    def validate_context(cls, v):
        if v:
            return SecurityValidator.sanitize_text(v, max_length=500)
        return v


class SecureQcmRequest(BaseModel):
    """Modèle sécurisé pour les requêtes QCM"""
    text: str = Field(..., min_length=10, max_length=5000)
    subject: str
    num_questions: int = Field(default=5, ge=1, le=20)
    difficulty: Optional[str] = "medium"

    @validator('text')
    def validate_text(cls, v):
        return SecurityValidator.sanitize_text(v, max_length=5000)

    @validator('subject')
    def validate_subject(cls, v):
        return SecurityValidator.validate_subject(v)

    @validator('difficulty')
    def validate_difficulty(cls, v):
        if v and v not in ["easy", "medium", "hard"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Niveau de difficulté invalide"
            )
        return v


class SecureSummaryRequest(BaseModel):
    """Modèle sécurisé pour les requêtes de résumé"""
    text: str = Field(..., min_length=50, max_length=10000)
    subject: str
    max_length: int = Field(default=200, ge=50, le=1000)
    style: Optional[str] = "bullet_points"

    @validator('text')
    def validate_text(cls, v):
        return SecurityValidator.sanitize_text(v, max_length=10000)

    @validator('subject')
    def validate_subject(cls, v):
        return SecurityValidator.validate_subject(v)

    @validator('style')
    def validate_style(cls, v):
        if v and v not in ["bullet_points", "paragraph", "structured"]:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Style de résumé invalide"
            )
        return v
