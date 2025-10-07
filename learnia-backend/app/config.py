import os
from typing import Optional

from dotenv import load_dotenv
from pydantic_settings import BaseSettings

load_dotenv()


class Settings(BaseSettings):
    # Configuration de base
    app_name: str = "Learnia Backend"
    version: str = "1.0.0"
    debug: bool = False

    # Configuration de la base de données
    database_url: str = "sqlite:///./learnia.db"

    # Configuration de sécurité
    secret_key: str = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # Configuration des APIs externes
    openai_api_key: Optional[str] = os.getenv("OPENAI_API_KEY")
    huggingface_api_key: Optional[str] = os.getenv("HUGGINGFACE_API_KEY")

    # Configuration CORS
    cors_origins: list = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8080",
        "http://localhost:3000",  # Flutter web
        "http://localhost:8080",  # Flutter web
        "http://10.0.2.2:8000",  # Android emulator
        "http://localhost:8000",  # Local development
    ]

    # Configuration des modèles IA
    default_ai_model: str = "gpt-3.5-turbo"
    max_tokens: int = 500
    temperature: float = 0.7

    # Configuration des langues supportées
    supported_languages: list = ["fr", "ewe", "kab"]

    # Configuration des matières
    subjects: list = [
        "Mathématiques",
        "Français",
        "Histoire",
        "Géographie",
        "Sciences",
        "Anglais",
        "Philosophie",
        "Économie",
    ]

    # Configuration des niveaux
    grade_levels: list = ["Primaire", "Collège", "Lycée", "Terminale"]

    # Configuration des timeouts
    api_timeout: int = 30
    ai_timeout: int = 60

    # Configuration des logs
    log_level: str = "INFO"
    log_file: str = "learnia.log"

    class Config:
        env_file = ".env"


settings = Settings()
