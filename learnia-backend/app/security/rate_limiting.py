"""
Module de rate limiting pour prévenir les abus
"""
import time
from typing import Dict, Optional
from collections import defaultdict, deque
from fastapi import HTTPException, status, Request
from loguru import logger


class RateLimiter:
    """Rate limiter simple basé sur des fenêtres glissantes"""

    def __init__(self):
        self.requests: Dict[str, deque] = defaultdict(deque)
        self.blocked_ips: Dict[str, float] = {}

    def is_allowed(
        self,
        identifier: str,
        max_requests: int = 100,
        window_seconds: int = 3600,
        block_duration: int = 3600
    ) -> bool:
        """
        Vérifie si une requête est autorisée
        
        Args:
            identifier: Identifiant unique (IP, user_id, etc.)
            max_requests: Nombre maximum de requêtes
            window_seconds: Fenêtre de temps en secondes
            block_duration: Durée de blocage en secondes
        
        Returns:
            True si la requête est autorisée
        """
        current_time = time.time()
        
        # Vérifier si l'identifiant est bloqué
        if identifier in self.blocked_ips:
            if current_time < self.blocked_ips[identifier]:
                logger.warning(f"Rate limit: {identifier} is blocked until {self.blocked_ips[identifier]}")
                return False
            else:
                # Le blocage a expiré
                del self.blocked_ips[identifier]
        
        # Nettoyer les anciennes requêtes
        cutoff_time = current_time - window_seconds
        while self.requests[identifier] and self.requests[identifier][0] < cutoff_time:
            self.requests[identifier].popleft()
        
        # Vérifier si la limite est dépassée
        if len(self.requests[identifier]) >= max_requests:
            # Bloquer l'identifiant
            self.blocked_ips[identifier] = current_time + block_duration
            logger.warning(f"Rate limit exceeded for {identifier}, blocked for {block_duration}s")
            return False
        
        # Enregistrer la requête actuelle
        self.requests[identifier].append(current_time)
        return True

    def get_remaining_requests(
        self,
        identifier: str,
        max_requests: int = 100,
        window_seconds: int = 3600
    ) -> int:
        """
        Obtient le nombre de requêtes restantes
        
        Args:
            identifier: Identifiant unique
            max_requests: Nombre maximum de requêtes
            window_seconds: Fenêtre de temps en secondes
        
        Returns:
            Nombre de requêtes restantes
        """
        current_time = time.time()
        cutoff_time = current_time - window_seconds
        
        # Nettoyer les anciennes requêtes
        while self.requests[identifier] and self.requests[identifier][0] < cutoff_time:
            self.requests[identifier].popleft()
        
        return max(0, max_requests - len(self.requests[identifier]))

    def reset_identifier(self, identifier: str):
        """Remet à zéro le compteur pour un identifiant"""
        if identifier in self.requests:
            del self.requests[identifier]
        if identifier in self.blocked_ips:
            del self.blocked_ips[identifier]


class APIRateLimiter:
    """Rate limiter spécialisé pour les APIs"""

    def __init__(self):
        self.rate_limiter = RateLimiter()
        
        # Configuration des limites par endpoint
        self.endpoint_limits = {
            "/api/v1/auth/login": {"max_requests": 5, "window_seconds": 300},  # 5 tentatives par 5 min
            "/api/v1/auth/register": {"max_requests": 3, "window_seconds": 3600},  # 3 inscriptions par heure
            "/api/v1/ai/tutor/": {"max_requests": 50, "window_seconds": 3600},  # 50 questions par heure
            "/api/v1/ai/qcm/": {"max_requests": 20, "window_seconds": 3600},  # 20 QCM par heure
            "/api/v1/ai/summary/": {"max_requests": 30, "window_seconds": 3600},  # 30 résumés par heure
            "/api/v1/ai/translate/": {"max_requests": 100, "window_seconds": 3600},  # 100 traductions par heure
            "/api/v1/ai/ocr/": {"max_requests": 10, "window_seconds": 3600},  # 10 OCR par heure
        }

    def check_rate_limit(self, request: Request, user_id: Optional[int] = None) -> bool:
        """
        Vérifie le rate limit pour une requête
        
        Args:
            request: Requête FastAPI
            user_id: ID de l'utilisateur (optionnel)
        
        Returns:
            True si la requête est autorisée
        """
        # Utiliser l'IP comme identifiant principal
        client_ip = request.client.host if request.client else "unknown"
        
        # Si un utilisateur est connecté, utiliser son ID comme identifiant secondaire
        identifier = f"user_{user_id}" if user_id else f"ip_{client_ip}"
        
        # Obtenir la configuration pour cet endpoint
        endpoint = request.url.path
        config = self.endpoint_limits.get(endpoint, {"max_requests": 100, "window_seconds": 3600})
        
        # Vérifier le rate limit
        is_allowed = self.rate_limiter.is_allowed(
            identifier=identifier,
            max_requests=config["max_requests"],
            window_seconds=config["window_seconds"]
        )
        
        if not is_allowed:
            remaining = self.rate_limiter.get_remaining_requests(
                identifier=identifier,
                max_requests=config["max_requests"],
                window_seconds=config["window_seconds"]
            )
            
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail={
                    "error": "Rate limit exceeded",
                    "message": f"Trop de requêtes. Limite: {config['max_requests']} par {config['window_seconds']}s",
                    "retry_after": config["window_seconds"],
                    "remaining_requests": remaining
                }
            )
        
        return True

    def get_rate_limit_info(self, request: Request, user_id: Optional[int] = None) -> Dict:
        """
        Obtient les informations de rate limit
        
        Args:
            request: Requête FastAPI
            user_id: ID de l'utilisateur (optionnel)
        
        Returns:
            Informations de rate limit
        """
        client_ip = request.client.host if request.client else "unknown"
        identifier = f"user_{user_id}" if user_id else f"ip_{client_ip}"
        
        endpoint = request.url.path
        config = self.endpoint_limits.get(endpoint, {"max_requests": 100, "window_seconds": 3600})
        
        remaining = self.rate_limiter.get_remaining_requests(
            identifier=identifier,
            max_requests=config["max_requests"],
            window_seconds=config["window_seconds"]
        )
        
        return {
            "endpoint": endpoint,
            "max_requests": config["max_requests"],
            "window_seconds": config["window_seconds"],
            "remaining_requests": remaining,
            "reset_time": time.time() + config["window_seconds"]
        }


# Instance globale du rate limiter
api_rate_limiter = APIRateLimiter()


def rate_limit_middleware(request: Request, call_next):
    """
    Middleware de rate limiting
    
    Args:
        request: Requête FastAPI
        call_next: Fonction suivante dans la chaîne
    
    Returns:
        Réponse HTTP
    """
    try:
        # Vérifier le rate limit
        api_rate_limiter.check_rate_limit(request)
        
        # Continuer avec la requête
        response = call_next(request)
        
        # Ajouter les headers de rate limit
        rate_info = api_rate_limiter.get_rate_limit_info(request)
        response.headers["X-RateLimit-Limit"] = str(rate_info["max_requests"])
        response.headers["X-RateLimit-Remaining"] = str(rate_info["remaining_requests"])
        response.headers["X-RateLimit-Reset"] = str(int(rate_info["reset_time"]))
        
        return response
        
    except HTTPException as e:
        if e.status_code == status.HTTP_429_TOO_MANY_REQUESTS:
            # Ajouter les headers même en cas de rate limit
            response = HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=e.detail
            )
            return response
        raise e
