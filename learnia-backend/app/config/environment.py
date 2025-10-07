"""
Gestion des environnements pour Learnia Backend
"""
import os
from typing import Type
from .production import ProductionSettings
from ..config import Settings


def get_settings() -> Settings:
    """
    Retourne la configuration appropriée selon l'environnement
    
    Returns:
        Configuration de l'environnement actuel
    """
    environment = os.getenv("ENVIRONMENT", "development").lower()
    
    if environment == "production":
        return ProductionSettings()
    else:
        return Settings()


def is_production() -> bool:
    """Vérifie si on est en environnement de production"""
    return os.getenv("ENVIRONMENT", "development").lower() == "production"


def is_development() -> bool:
    """Vérifie si on est en environnement de développement"""
    return os.getenv("ENVIRONMENT", "development").lower() == "development"


def is_testing() -> bool:
    """Vérifie si on est en environnement de test"""
    return os.getenv("ENVIRONMENT", "development").lower() == "testing"


def get_environment() -> str:
    """Retourne l'environnement actuel"""
    return os.getenv("ENVIRONMENT", "development").lower()


def validate_production_config():
    """
    Valide la configuration de production
    
    Raises:
        ValueError: Si la configuration n'est pas valide pour la production
    """
    if not is_production():
        return
    
    required_vars = [
        "SECRET_KEY",
        "DATABASE_URL",
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        raise ValueError(
            f"Variables d'environnement manquantes pour la production: {', '.join(missing_vars)}"
        )
    
    # Vérifier que la clé secrète n'est pas la valeur par défaut
    secret_key = os.getenv("SECRET_KEY")
    if secret_key == "your-secret-key-change-in-production":
        raise ValueError("SECRET_KEY doit être changée en production")
    
    # Vérifier que le debug est désactivé
    if os.getenv("DEBUG", "false").lower() == "true":
        raise ValueError("DEBUG doit être désactivé en production")
