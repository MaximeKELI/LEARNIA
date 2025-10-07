"""
Cache en mémoire pour les cas où Redis n'est pas disponible
"""
import time
from typing import Any, Optional, Dict, Tuple, Union
from datetime import datetime, timedelta
from threading import Lock
from loguru import logger


class MemoryCache:
    """Cache en mémoire avec expiration automatique"""

    def __init__(self, max_size: int = 1000):
        """
        Initialise le cache en mémoire
        
        Args:
            max_size: Taille maximale du cache
        """
        self.max_size = max_size
        self.cache: Dict[str, Tuple[Any, float]] = {}
        self.lock = Lock()
        self.available = True

    def get(self, key: str) -> Optional[Any]:
        """
        Récupère une valeur du cache
        
        Args:
            key: Clé du cache
        
        Returns:
            Valeur mise en cache ou None
        """
        with self.lock:
            if key not in self.cache:
                return None
            
            value, expire_time = self.cache[key]
            
            # Vérifier l'expiration
            if time.time() > expire_time:
                del self.cache[key]
                return None
            
            return value

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
        with self.lock:
            # Calculer le temps d'expiration
            if expire is not None:
                if isinstance(expire, timedelta):
                    expire_seconds = expire.total_seconds()
                else:
                    expire_seconds = expire
                expire_time = time.time() + expire_seconds
            else:
                expire_time = time.time() + 3600  # 1 heure par défaut
            
            # Nettoyer le cache si nécessaire
            if len(self.cache) >= self.max_size:
                self._cleanup()
            
            self.cache[key] = (value, expire_time)
            return True

    def delete(self, key: str) -> bool:
        """
        Supprime une valeur du cache
        
        Args:
            key: Clé du cache
        
        Returns:
            True si succès, False sinon
        """
        with self.lock:
            if key in self.cache:
                del self.cache[key]
                return True
            return False

    def exists(self, key: str) -> bool:
        """
        Vérifie si une clé existe dans le cache
        
        Args:
            key: Clé du cache
        
        Returns:
            True si la clé existe, False sinon
        """
        with self.lock:
            if key not in self.cache:
                return False
            
            value, expire_time = self.cache[key]
            
            # Vérifier l'expiration
            if time.time() > expire_time:
                del self.cache[key]
                return False
            
            return True

    def clear(self) -> int:
        """
        Vide le cache
        
        Returns:
            Nombre d'éléments supprimés
        """
        with self.lock:
            count = len(self.cache)
            self.cache.clear()
            return count

    def clear_pattern(self, pattern: str) -> int:
        """
        Supprime toutes les clés correspondant à un pattern
        
        Args:
            pattern: Pattern des clés à supprimer (ex: "user:*")
        
        Returns:
            Nombre de clés supprimées
        """
        with self.lock:
            keys_to_delete = []
            for key in self.cache.keys():
                if self._match_pattern(key, pattern):
                    keys_to_delete.append(key)
            
            for key in keys_to_delete:
                del self.cache[key]
            
            return len(keys_to_delete)

    def _match_pattern(self, key: str, pattern: str) -> bool:
        """
        Vérifie si une clé correspond à un pattern
        
        Args:
            key: Clé à vérifier
            pattern: Pattern à matcher
        
        Returns:
            True si la clé correspond au pattern
        """
        if '*' not in pattern:
            return key == pattern
        
        # Conversion simple de pattern avec *
        import re
        regex_pattern = pattern.replace('*', '.*')
        return bool(re.match(regex_pattern, key))

    def _cleanup(self):
        """Nettoie les entrées expirées"""
        current_time = time.time()
        expired_keys = []
        
        for key, (value, expire_time) in self.cache.items():
            if current_time > expire_time:
                expired_keys.append(key)
        
        for key in expired_keys:
            del self.cache[key]

    def get_stats(self) -> dict:
        """
        Obtient les statistiques du cache
        
        Returns:
            Statistiques du cache
        """
        with self.lock:
            current_time = time.time()
            active_entries = 0
            expired_entries = 0
            
            for key, (value, expire_time) in self.cache.items():
                if current_time > expire_time:
                    expired_entries += 1
                else:
                    active_entries += 1
            
            return {
                "status": "available",
                "total_entries": len(self.cache),
                "active_entries": active_entries,
                "expired_entries": expired_entries,
                "max_size": self.max_size,
                "memory_usage": f"{len(str(self.cache))} bytes",
            }


# Instance globale du cache en mémoire
memory_cache = MemoryCache()


def get_cache() -> Union[RedisCache, MemoryCache]:
    """
    Retourne la meilleure instance de cache disponible
    
    Returns:
        Instance de cache (Redis si disponible, sinon mémoire)
    """
    from .redis_cache import redis_cache
    
    if redis_cache.available:
        return redis_cache
    else:
        return memory_cache
