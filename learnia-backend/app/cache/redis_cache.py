"""
Cache Redis pour optimiser les performances
"""
import json
import pickle
from typing import Any, Optional, Union
from datetime import timedelta
import redis
from loguru import logger

from ..config import settings


class RedisCache:
    """Service de cache Redis pour optimiser les performances"""

    def __init__(self):
        """Initialise la connexion Redis"""
        try:
            self.redis_client = redis.Redis(
                host=getattr(settings, 'redis_host', 'localhost'),
                port=getattr(settings, 'redis_port', 6379),
                db=getattr(settings, 'redis_db', 0),
                decode_responses=False,  # Pour gérer les objets Python
                socket_connect_timeout=5,
                socket_timeout=5,
            )
            # Test de connexion
            self.redis_client.ping()
            self.available = True
            logger.info("Cache Redis connecté avec succès")
        except Exception as e:
            logger.warning(f"Redis non disponible: {e}")
            self.redis_client = None
            self.available = False

    def get(self, key: str) -> Optional[Any]:
        """
        Récupère une valeur du cache
        
        Args:
            key: Clé du cache
        
        Returns:
            Valeur mise en cache ou None
        """
        if not self.available:
            return None
        
        try:
            value = self.redis_client.get(key)
            if value is not None:
                # Désérialiser l'objet Python
                return pickle.loads(value)
            return None
        except Exception as e:
            logger.error(f"Erreur lors de la récupération du cache: {e}")
            return None

    def set(
        self, 
        key: str, 
        value: Any, 
        expire: Optional[Union[int, timedelta]] = None
    ) -> bool:
        """
        Stocke une valeur dans le cache
        
        Args:
            key: Clé du cache
            value: Valeur à stocker
            expire: Durée d'expiration en secondes ou timedelta
        
        Returns:
            True si succès, False sinon
        """
        if not self.available:
            return False
        
        try:
            # Sérialiser l'objet Python
            serialized_value = pickle.dumps(value)
            
            if expire is not None:
                if isinstance(expire, timedelta):
                    expire = int(expire.total_seconds())
                self.redis_client.setex(key, expire, serialized_value)
            else:
                self.redis_client.set(key, serialized_value)
            
            return True
        except Exception as e:
            logger.error(f"Erreur lors de la mise en cache: {e}")
            return False

    def delete(self, key: str) -> bool:
        """
        Supprime une valeur du cache
        
        Args:
            key: Clé du cache
        
        Returns:
            True si succès, False sinon
        """
        if not self.available:
            return False
        
        try:
            result = self.redis_client.delete(key)
            return result > 0
        except Exception as e:
            logger.error(f"Erreur lors de la suppression du cache: {e}")
            return False

    def exists(self, key: str) -> bool:
        """
        Vérifie si une clé existe dans le cache
        
        Args:
            key: Clé du cache
        
        Returns:
            True si la clé existe, False sinon
        """
        if not self.available:
            return False
        
        try:
            return bool(self.redis_client.exists(key))
        except Exception as e:
            logger.error(f"Erreur lors de la vérification du cache: {e}")
            return False

    def clear_pattern(self, pattern: str) -> int:
        """
        Supprime toutes les clés correspondant à un pattern
        
        Args:
            pattern: Pattern des clés à supprimer (ex: "user:*")
        
        Returns:
            Nombre de clés supprimées
        """
        if not self.available:
            return 0
        
        try:
            keys = self.redis_client.keys(pattern)
            if keys:
                return self.redis_client.delete(*keys)
            return 0
        except Exception as e:
            logger.error(f"Erreur lors du nettoyage du cache: {e}")
            return 0

    def get_stats(self) -> dict:
        """
        Obtient les statistiques du cache
        
        Returns:
            Statistiques du cache Redis
        """
        if not self.available:
            return {"status": "unavailable"}
        
        try:
            info = self.redis_client.info()
            return {
                "status": "available",
                "used_memory": info.get("used_memory_human", "N/A"),
                "connected_clients": info.get("connected_clients", 0),
                "total_commands_processed": info.get("total_commands_processed", 0),
                "keyspace_hits": info.get("keyspace_hits", 0),
                "keyspace_misses": info.get("keyspace_misses", 0),
            }
        except Exception as e:
            logger.error(f"Erreur lors de la récupération des stats: {e}")
            return {"status": "error", "error": str(e)}


# Instance globale du cache
redis_cache = RedisCache()


def cache_key(prefix: str, *args) -> str:
    """
    Génère une clé de cache à partir d'un préfixe et d'arguments
    
    Args:
        prefix: Préfixe de la clé
        *args: Arguments à inclure dans la clé
    
    Returns:
        Clé de cache générée
    """
    return f"learnia:{prefix}:{':'.join(str(arg) for arg in args)}"


def cached_result(
    key: str, 
    expire: Optional[Union[int, timedelta]] = None,
    cache_instance: Optional[RedisCache] = None
):
    """
    Décorateur pour mettre en cache le résultat d'une fonction
    
    Args:
        key: Clé du cache
        expire: Durée d'expiration
        cache_instance: Instance de cache à utiliser
    """
    def decorator(func):
        def wrapper(*args, **kwargs):
            cache = cache_instance or redis_cache
            
            # Générer la clé de cache avec les arguments
            cache_key_full = f"{key}:{hash(str(args) + str(kwargs))}"
            
            # Essayer de récupérer depuis le cache
            cached_value = cache.get(cache_key_full)
            if cached_value is not None:
                logger.debug(f"Cache hit pour {cache_key_full}")
                return cached_value
            
            # Exécuter la fonction et mettre en cache le résultat
            result = func(*args, **kwargs)
            cache.set(cache_key_full, result, expire)
            logger.debug(f"Cache miss pour {cache_key_full}, résultat mis en cache")
            
            return result
        return wrapper
    return decorator
