"""
Sécurité renforcée pour la production
"""
import hashlib
import secrets
import time
from typing import Optional, Dict, Any
from datetime import datetime, timedelta
from loguru import logger

from ..config.environment import is_production


class ProductionSecurity:
    """Classe de sécurité renforcée pour la production"""

    def __init__(self):
        self.failed_attempts: Dict[str, int] = {}
        self.lockouts: Dict[str, datetime] = {}
        self.max_attempts = 5
        self.lockout_duration = 900  # 15 minutes

    def hash_password(self, password: str) -> str:
        """
        Hache un mot de passe avec salt et itérations multiples
        
        Args:
            password: Mot de passe à hacher
        
        Returns:
            Mot de passe haché
        """
        # Générer un salt unique
        salt = secrets.token_hex(32)
        
        # Hacher avec PBKDF2 et plusieurs itérations
        password_hash = hashlib.pbkdf2_hmac(
            'sha256',
            password.encode('utf-8'),
            salt.encode('utf-8'),
            100000  # 100k itérations
        )
        
        # Retourner salt + hash
        return f"{salt}:{password_hash.hex()}"

    def verify_password(self, password: str, hashed_password: str) -> bool:
        """
        Vérifie un mot de passe contre son hash
        
        Args:
            password: Mot de passe à vérifier
            hashed_password: Hash stocké
        
        Returns:
            True si le mot de passe est correct
        """
        try:
            salt, stored_hash = hashed_password.split(':')
            password_hash = hashlib.pbkdf2_hmac(
                'sha256',
                password.encode('utf-8'),
                salt.encode('utf-8'),
                100000
            )
            return password_hash.hex() == stored_hash
        except Exception as e:
            logger.error(f"Erreur lors de la vérification du mot de passe: {e}")
            return False

    def validate_password_strength(self, password: str) -> Dict[str, Any]:
        """
        Valide la force d'un mot de passe
        
        Args:
            password: Mot de passe à valider
        
        Returns:
            Résultat de la validation
        """
        result = {
            "valid": True,
            "errors": [],
            "score": 0
        }
        
        # Longueur minimale
        if len(password) < 8:
            result["errors"].append("Le mot de passe doit contenir au moins 8 caractères")
            result["valid"] = False
        else:
            result["score"] += 1
        
        # Caractères spéciaux
        if not any(c in "!@#$%^&*()_+-=[]{}|;:,.<>?" for c in password):
            result["errors"].append("Le mot de passe doit contenir au moins un caractère spécial")
            result["valid"] = False
        else:
            result["score"] += 1
        
        # Majuscules
        if not any(c.isupper() for c in password):
            result["errors"].append("Le mot de passe doit contenir au moins une majuscule")
            result["valid"] = False
        else:
            result["score"] += 1
        
        # Minuscules
        if not any(c.islower() for c in password):
            result["errors"].append("Le mot de passe doit contenir au moins une minuscule")
            result["valid"] = False
        else:
            result["score"] += 1
        
        # Chiffres
        if not any(c.isdigit() for c in password):
            result["errors"].append("Le mot de passe doit contenir au moins un chiffre")
            result["valid"] = False
        else:
            result["score"] += 1
        
        # Mots de passe communs
        common_passwords = [
            "password", "123456", "123456789", "qwerty", "abc123",
            "password123", "admin", "letmein", "welcome", "monkey"
        ]
        
        if password.lower() in common_passwords:
            result["errors"].append("Ce mot de passe est trop commun")
            result["valid"] = False
            result["score"] = 0
        
        return result

    def check_rate_limit(self, identifier: str) -> bool:
        """
        Vérifie si un identifiant est soumis à une limite de taux
        
        Args:
            identifier: Identifiant (IP, email, etc.)
        
        Returns:
            True si la limite est dépassée
        """
        if not is_production():
            return False
        
        now = datetime.now()
        
        # Vérifier si l'identifiant est en lockout
        if identifier in self.lockouts:
            if now < self.lockouts[identifier]:
                return True
            else:
                # Lockout expiré
                del self.lockouts[identifier]
                self.failed_attempts[identifier] = 0
        
        # Vérifier le nombre de tentatives
        attempts = self.failed_attempts.get(identifier, 0)
        if attempts >= self.max_attempts:
            # Mettre en lockout
            self.lockouts[identifier] = now + timedelta(seconds=self.lockout_duration)
            logger.warning(f"Rate limit dépassé pour {identifier}, lockout de {self.lockout_duration}s")
            return True
        
        return False

    def record_failed_attempt(self, identifier: str):
        """
        Enregistre une tentative échouée
        
        Args:
            identifier: Identifiant de la tentative
        """
        if not is_production():
            return
        
        self.failed_attempts[identifier] = self.failed_attempts.get(identifier, 0) + 1
        logger.warning(f"Tentative échouée pour {identifier}, total: {self.failed_attempts[identifier]}")

    def record_successful_attempt(self, identifier: str):
        """
        Enregistre une tentative réussie
        
        Args:
            identifier: Identifiant de la tentative
        """
        if not is_production():
            return
        
        # Réinitialiser les compteurs
        if identifier in self.failed_attempts:
            del self.failed_attempts[identifier]
        if identifier in self.lockouts:
            del self.lockouts[identifier]

    def generate_secure_token(self, length: int = 32) -> str:
        """
        Génère un token sécurisé
        
        Args:
            length: Longueur du token
        
        Returns:
            Token sécurisé
        """
        return secrets.token_urlsafe(length)

    def sanitize_input(self, input_string: str) -> str:
        """
        Nettoie une chaîne d'entrée
        
        Args:
            input_string: Chaîne à nettoyer
        
        Returns:
            Chaîne nettoyée
        """
        if not input_string:
            return ""
        
        # Supprimer les caractères de contrôle
        cleaned = ''.join(char for char in input_string if ord(char) >= 32)
        
        # Limiter la longueur
        if len(cleaned) > 1000:
            cleaned = cleaned[:1000]
        
        return cleaned.strip()

    def validate_email(self, email: str) -> bool:
        """
        Valide une adresse email
        
        Args:
            email: Adresse email à valider
        
        Returns:
            True si l'email est valide
        """
        import re
        
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return bool(re.match(pattern, email))

    def get_security_headers(self) -> Dict[str, str]:
        """
        Retourne les en-têtes de sécurité recommandés
        
        Returns:
            Dictionnaire des en-têtes de sécurité
        """
        return {
            "X-Content-Type-Options": "nosniff",
            "X-Frame-Options": "DENY",
            "X-XSS-Protection": "1; mode=block",
            "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
            "Referrer-Policy": "strict-origin-when-cross-origin",
            "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'",
        }

    def log_security_event(self, event_type: str, details: Dict[str, Any]):
        """
        Enregistre un événement de sécurité
        
        Args:
            event_type: Type d'événement
            details: Détails de l'événement
        """
        if not is_production():
            return
        
        logger.warning(f"Événement de sécurité: {event_type}", extra=details)


# Instance globale de sécurité
production_security = ProductionSecurity()
