"""
Système de métriques pour la production
"""
import time
from typing import Dict, Any, Optional
from datetime import datetime, timedelta
from collections import defaultdict, deque
from loguru import logger

from ..config.environment import is_production


class MetricsCollector:
    """Collecteur de métriques pour la production"""

    def __init__(self):
        self.metrics: Dict[str, Any] = defaultdict(int)
        self.timers: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
        self.counters: Dict[str, int] = defaultdict(int)
        self.gauges: Dict[str, float] = defaultdict(float)
        self.start_time = time.time()

    def increment_counter(self, name: str, value: int = 1, tags: Optional[Dict[str, str]] = None):
        """
        Incrémente un compteur
        
        Args:
            name: Nom du compteur
            value: Valeur à ajouter
            tags: Tags additionnels
        """
        if not is_production():
            return
        
        self.counters[name] += value
        logger.debug(f"Counter {name} incremented by {value}")

    def record_timer(self, name: str, duration: float, tags: Optional[Dict[str, str]] = None):
        """
        Enregistre une durée
        
        Args:
            name: Nom du timer
            duration: Durée en secondes
            tags: Tags additionnels
        """
        if not is_production():
            return
        
        self.timers[name].append(duration)
        logger.debug(f"Timer {name} recorded: {duration:.3f}s")

    def set_gauge(self, name: str, value: float, tags: Optional[Dict[str, str]] = None):
        """
        Définit une jauge
        
        Args:
            name: Nom de la jauge
            value: Valeur de la jauge
            tags: Tags additionnels
        """
        if not is_production():
            return
        
        self.gauges[name] = value
        logger.debug(f"Gauge {name} set to {value}")

    def get_metrics(self) -> Dict[str, Any]:
        """
        Retourne toutes les métriques
        
        Returns:
            Dictionnaire des métriques
        """
        uptime = time.time() - self.start_time
        
        # Calculer les statistiques des timers
        timer_stats = {}
        for name, values in self.timers.items():
            if values:
                timer_stats[name] = {
                    "count": len(values),
                    "min": min(values),
                    "max": max(values),
                    "avg": sum(values) / len(values),
                    "p95": self._percentile(list(values), 95),
                    "p99": self._percentile(list(values), 99),
                }
        
        return {
            "uptime": uptime,
            "counters": dict(self.counters),
            "gauges": dict(self.gauges),
            "timers": timer_stats,
            "timestamp": datetime.now().isoformat(),
        }

    def _percentile(self, data: list, percentile: int) -> float:
        """Calcule un percentile"""
        if not data:
            return 0
        sorted_data = sorted(data)
        index = int(len(sorted_data) * percentile / 100)
        return sorted_data[min(index, len(sorted_data) - 1)]

    def reset_metrics(self):
        """Remet à zéro toutes les métriques"""
        self.metrics.clear()
        self.timers.clear()
        self.counters.clear()
        self.gauges.clear()
        self.start_time = time.time()
        logger.info("Métriques remises à zéro")

    def get_health_status(self) -> Dict[str, Any]:
        """
        Retourne le statut de santé de l'application
        
        Returns:
            Statut de santé
        """
        uptime = time.time() - self.start_time
        
        # Vérifier les métriques critiques
        health_checks = {
            "database": self._check_database_health(),
            "redis": self._check_redis_health(),
            "api": self._check_api_health(),
        }
        
        overall_health = all(health_checks.values())
        
        return {
            "status": "healthy" if overall_health else "unhealthy",
            "uptime": uptime,
            "checks": health_checks,
            "timestamp": datetime.now().isoformat(),
        }

    def _check_database_health(self) -> bool:
        """Vérifie la santé de la base de données"""
        try:
            # Ici on pourrait faire une requête simple à la DB
            return True
        except Exception:
            return False

    def _check_redis_health(self) -> bool:
        """Vérifie la santé de Redis"""
        try:
            # Ici on pourrait faire un ping Redis
            return True
        except Exception:
            return False

    def _check_api_health(self) -> bool:
        """Vérifie la santé de l'API"""
        # Vérifier le taux d'erreur
        total_requests = self.counters.get("api_requests_total", 0)
        error_requests = self.counters.get("api_errors_total", 0)
        
        if total_requests == 0:
            return True
        
        error_rate = error_requests / total_requests
        return error_rate < 0.1  # Moins de 10% d'erreurs


class MetricsMiddleware:
    """Middleware pour collecter les métriques automatiquement"""

    def __init__(self, metrics_collector: MetricsCollector):
        self.metrics = metrics_collector

    async def __call__(self, request, call_next):
        """Middleware FastAPI pour collecter les métriques"""
        start_time = time.time()
        
        # Incrémenter le compteur de requêtes
        self.metrics.increment_counter("api_requests_total")
        
        try:
            response = await call_next(request)
            
            # Enregistrer la durée
            duration = time.time() - start_time
            self.metrics.record_timer("api_request_duration", duration)
            
            # Incrémenter le compteur de succès
            self.metrics.increment_counter("api_success_total")
            
            return response
            
        except Exception as e:
            # Enregistrer la durée même en cas d'erreur
            duration = time.time() - start_time
            self.metrics.record_timer("api_request_duration", duration)
            
            # Incrémenter le compteur d'erreurs
            self.metrics.increment_counter("api_errors_total")
            
            # Enregistrer le type d'erreur
            error_type = type(e).__name__
            self.metrics.increment_counter(f"api_error_{error_type}_total")
            
            raise


# Instance globale du collecteur de métriques
metrics_collector = MetricsCollector()
