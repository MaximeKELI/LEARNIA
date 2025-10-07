"""
Configuration de production pour Learnia Backend
"""
import os
from typing import List
from pydantic_settings import BaseSettings


class ProductionSettings(BaseSettings):
    """Configuration spécifique à la production"""
    
    # Configuration de base
    app_name: str = "Learnia Backend"
    version: str = "1.0.0"
    debug: bool = False
    
    # Configuration de la base de données
    database_url: str = os.getenv("DATABASE_URL", "postgresql://user:password@localhost/learnia_prod")
    
    # Configuration de sécurité (OBLIGATOIRE en production)
    secret_key: str = os.getenv("SECRET_KEY")
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Validation des clés obligatoires
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        if not self.secret_key or self.secret_key == "your-secret-key-change-in-production":
            raise ValueError("SECRET_KEY doit être définie en production")
    
    # Configuration des APIs externes
    openai_api_key: str = os.getenv("OPENAI_API_KEY", "")
    huggingface_api_key: str = os.getenv("HUGGINGFACE_API_KEY", "")
    
    # Configuration CORS pour la production
    cors_origins: List[str] = [
        "https://learnia.tg",
        "https://www.learnia.tg",
        "https://app.learnia.tg",
        "https://admin.learnia.tg",
    ]
    
    # Configuration Redis pour la production
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    redis_host: str = os.getenv("REDIS_HOST", "localhost")
    redis_port: int = int(os.getenv("REDIS_PORT", "6379"))
    redis_db: int = int(os.getenv("REDIS_DB", "0"))
    redis_password: str = os.getenv("REDIS_PASSWORD", "")
    
    # Configuration des modèles IA
    default_ai_model: str = "gpt-4"
    max_tokens: int = 1000
    temperature: float = 0.7
    
    # Configuration des langues supportées
    supported_languages: List[str] = ["fr", "ewe", "kab"]
    
    # Configuration des matières
    subjects: List[str] = [
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
    grade_levels: List[str] = ["Primaire", "Collège", "Lycée", "Terminale"]
    
    # Configuration des timeouts (plus longs en production)
    api_timeout: int = 60
    ai_timeout: int = 120
    
    # Configuration des logs
    log_level: str = "WARNING"  # Moins de logs en production
    log_file: str = "/var/log/learnia/learnia.log"
    
    # Configuration de sécurité renforcée
    max_login_attempts: int = 5
    lockout_duration: int = 900  # 15 minutes
    password_min_length: int = 8
    password_require_special: bool = True
    
    # Configuration de la base de données
    db_pool_size: int = 20
    db_max_overflow: int = 30
    db_pool_timeout: int = 30
    db_pool_recycle: int = 3600
    
    # Configuration du cache
    cache_ttl: int = 3600  # 1 heure
    cache_max_size: int = 10000
    
    # Configuration de monitoring
    enable_metrics: bool = True
    metrics_port: int = 9090
    
    # Configuration de sauvegarde
    backup_enabled: bool = True
    backup_interval: int = 86400  # 24 heures
    backup_retention_days: int = 30
    
    # Configuration SSL/TLS
    ssl_cert_path: str = os.getenv("SSL_CERT_PATH", "")
    ssl_key_path: str = os.getenv("SSL_KEY_PATH", "")
    
    # Configuration de rate limiting
    rate_limit_requests: int = 1000
    rate_limit_window: int = 3600  # 1 heure
    
    class Config:
        env_file = ".env.production"
        case_sensitive = False


# Instance de configuration de production
production_settings = ProductionSettings()
