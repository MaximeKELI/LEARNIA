"""
Optimisations d'API pour améliorer les performances
"""
import time
import asyncio
from typing import Any, Dict, List, Optional, Callable
from functools import wraps
from loguru import logger

from ..cache.redis_cache import redis_cache, cached_result, cache_key
from ..cache.memory_cache import memory_cache


def performance_monitor(func: Callable) -> Callable:
    """
    Décorateur pour monitorer les performances des fonctions
    
    Args:
        func: Fonction à monitorer
    
    Returns:
        Fonction wrappée avec monitoring
    """
    @wraps(func)
    async def async_wrapper(*args, **kwargs):
        start_time = time.time()
        function_name = f"{func.__module__}.{func.__name__}"
        
        try:
            result = await func(*args, **kwargs)
            execution_time = time.time() - start_time
            
            logger.info(
                f"API {function_name} exécutée en {execution_time:.3f}s"
            )
            
            # Log des performances lentes
            if execution_time > 1.0:
                logger.warning(
                    f"Performance lente détectée: {function_name} "
                    f"a pris {execution_time:.3f}s"
                )
            
            return result
            
        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(
                f"Erreur dans {function_name} après {execution_time:.3f}s: {e}"
            )
            raise
    
    @wraps(func)
    def sync_wrapper(*args, **kwargs):
        start_time = time.time()
        function_name = f"{func.__module__}.{func.__name__}"
        
        try:
            result = func(*args, **kwargs)
            execution_time = time.time() - start_time
            
            logger.info(
                f"API {function_name} exécutée en {execution_time:.3f}s"
            )
            
            # Log des performances lentes
            if execution_time > 1.0:
                logger.warning(
                    f"Performance lente détectée: {function_name} "
                    f"a pris {execution_time:.3f}s"
                )
            
            return result
            
        except Exception as e:
            execution_time = time.time() - start_time
            logger.error(
                f"Erreur dans {function_name} après {execution_time:.3f}s: {e}"
            )
            raise
    
    # Retourner le bon wrapper selon si la fonction est async
    if asyncio.iscoroutinefunction(func):
        return async_wrapper
    else:
        return sync_wrapper


def cache_response(
    cache_duration: int = 300,  # 5 minutes par défaut
    cache_key_prefix: str = "api_response"
):
    """
    Décorateur pour mettre en cache les réponses d'API
    
    Args:
        cache_duration: Durée du cache en secondes
        cache_key_prefix: Préfixe pour la clé de cache
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            # Générer une clé de cache basée sur les arguments
            cache_key_str = cache_key(
                cache_key_prefix,
                func.__name__,
                str(args),
                str(sorted(kwargs.items()))
            )
            
            # Essayer de récupérer depuis le cache
            cache = redis_cache if redis_cache.available else memory_cache
            cached_result = cache.get(cache_key_str)
            
            if cached_result is not None:
                logger.debug(f"Cache hit pour {cache_key_str}")
                return cached_result
            
            # Exécuter la fonction et mettre en cache le résultat
            result = await func(*args, **kwargs)
            cache.set(cache_key_str, result, cache_duration)
            logger.debug(f"Cache miss pour {cache_key_str}, résultat mis en cache")
            
            return result
        
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            # Générer une clé de cache basée sur les arguments
            cache_key_str = cache_key(
                cache_key_prefix,
                func.__name__,
                str(args),
                str(sorted(kwargs.items()))
            )
            
            # Essayer de récupérer depuis le cache
            cache = redis_cache if redis_cache.available else memory_cache
            cached_result = cache.get(cache_key_str)
            
            if cached_result is not None:
                logger.debug(f"Cache hit pour {cache_key_str}")
                return cached_result
            
            # Exécuter la fonction et mettre en cache le résultat
            result = func(*args, **kwargs)
            cache.set(cache_key_str, result, cache_duration)
            logger.debug(f"Cache miss pour {cache_key_str}, résultat mis en cache")
            
            return result
        
        # Retourner le bon wrapper selon si la fonction est async
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
    
    return decorator


class APIOptimizer:
    """Classe pour optimiser les performances des APIs"""

    def __init__(self):
        self.cache = redis_cache if redis_cache.available else memory_cache

    def get_cache_stats(self) -> Dict[str, Any]:
        """Obtient les statistiques du cache"""
        return self.cache.get_stats()

    def clear_cache_pattern(self, pattern: str) -> int:
        """Supprime les entrées de cache correspondant à un pattern"""
        return self.cache.clear_pattern(pattern)

    def warm_up_cache(self, functions: List[Callable], *args, **kwargs):
        """Préchauffe le cache avec des fonctions données"""
        logger.info("Préchauffage du cache...")
        
        for func in functions:
            try:
                if asyncio.iscoroutinefunction(func):
                    asyncio.create_task(func(*args, **kwargs))
                else:
                    func(*args, **kwargs)
                logger.debug(f"Cache préchauffé pour {func.__name__}")
            except Exception as e:
                logger.error(f"Erreur lors du préchauffage de {func.__name__}: {e}")

    def optimize_response_size(self, data: Any, max_size: int = 1024 * 1024) -> Any:
        """
        Optimise la taille de la réponse
        
        Args:
            data: Données à optimiser
            max_size: Taille maximale en bytes
        
        Returns:
            Données optimisées
        """
        if isinstance(data, dict):
            # Supprimer les champs inutiles
            optimized = {}
            for key, value in data.items():
                if value is not None and value != "":
                    optimized[key] = value
            return optimized
        
        return data

    def paginate_response(
        self, 
        data: List[Any], 
        page: int = 1, 
        page_size: int = 20
    ) -> Dict[str, Any]:
        """
        Pagine une réponse pour réduire la taille
        
        Args:
            data: Liste de données à paginer
            page: Numéro de page (commence à 1)
            page_size: Taille de la page
        
        Returns:
            Réponse paginée
        """
        total_items = len(data)
        total_pages = (total_items + page_size - 1) // page_size
        
        start_index = (page - 1) * page_size
        end_index = start_index + page_size
        
        paginated_data = data[start_index:end_index]
        
        return {
            "data": paginated_data,
            "pagination": {
                "page": page,
                "page_size": page_size,
                "total_items": total_items,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_prev": page > 1
            }
        }


# Instance globale de l'optimiseur d'API
api_optimizer = APIOptimizer()


def rate_limit_by_user(
    max_requests: int = 100,
    window_seconds: int = 3600
):
    """
    Décorateur pour limiter le taux de requêtes par utilisateur
    
    Args:
        max_requests: Nombre maximum de requêtes
        window_seconds: Fenêtre de temps en secondes
    """
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            # Ici on pourrait implémenter la logique de rate limiting
            # Pour l'instant, on exécute simplement la fonction
            return await func(*args, **kwargs)
        
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            # Ici on pourrait implémenter la logique de rate limiting
            # Pour l'instant, on exécute simplement la fonction
            return func(*args, **kwargs)
        
        # Retourner le bon wrapper selon si la fonction est async
        if asyncio.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
    
    return decorator


def compress_response(func: Callable) -> Callable:
    """
    Décorateur pour compresser les réponses volumineuses
    
    Args:
        func: Fonction à wrapper
    """
    @wraps(func)
    async def async_wrapper(*args, **kwargs):
        result = await func(*args, **kwargs)
        
        # Ici on pourrait ajouter la compression gzip
        # Pour l'instant, on retourne le résultat tel quel
        return result
    
    @wraps(func)
    def sync_wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        
        # Ici on pourrait ajouter la compression gzip
        # Pour l'instant, on retourne le résultat tel quel
        return result
    
    # Retourner le bon wrapper selon si la fonction est async
    if asyncio.iscoroutinefunction(func):
        return async_wrapper
    else:
        return sync_wrapper
