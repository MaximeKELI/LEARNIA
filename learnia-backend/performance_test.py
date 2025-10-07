#!/usr/bin/env python3
"""
Script de test de performance pour Learnia Backend
"""
import asyncio
import time
import requests
import json
from concurrent.futures import ThreadPoolExecutor
from typing import List, Dict, Any
import statistics


class PerformanceTester:
    """Classe pour tester les performances de l'API"""

    def __init__(self, base_url: str = "http://localhost:8000"):
        self.base_url = base_url
        self.results = []

    def test_endpoint_performance(
        self, 
        endpoint: str, 
        method: str = "GET", 
        data: Dict = None,
        headers: Dict = None,
        num_requests: int = 10
    ) -> Dict[str, Any]:
        """
        Teste les performances d'un endpoint
        
        Args:
            endpoint: URL de l'endpoint
            method: Méthode HTTP
            data: Données à envoyer
            headers: En-têtes HTTP
            num_requests: Nombre de requêtes à effectuer
        
        Returns:
            Statistiques de performance
        """
        print(f"🧪 Test de performance: {method} {endpoint}")
        
        response_times = []
        success_count = 0
        error_count = 0
        
        for i in range(num_requests):
            start_time = time.time()
            
            try:
                if method.upper() == "GET":
                    response = requests.get(
                        f"{self.base_url}{endpoint}",
                        headers=headers,
                        timeout=30
                    )
                elif method.upper() == "POST":
                    response = requests.post(
                        f"{self.base_url}{endpoint}",
                        json=data,
                        headers=headers,
                        timeout=30
                    )
                else:
                    raise ValueError(f"Méthode non supportée: {method}")
                
                response_time = time.time() - start_time
                response_times.append(response_time)
                
                if response.status_code < 400:
                    success_count += 1
                else:
                    error_count += 1
                    print(f"   ❌ Erreur {response.status_code}: {response.text[:100]}")
                
            except Exception as e:
                error_count += 1
                response_time = time.time() - start_time
                response_times.append(response_time)
                print(f"   ❌ Exception: {e}")
        
        # Calculer les statistiques
        if response_times:
            stats = {
                "endpoint": endpoint,
                "method": method,
                "total_requests": num_requests,
                "success_count": success_count,
                "error_count": error_count,
                "success_rate": (success_count / num_requests) * 100,
                "avg_response_time": statistics.mean(response_times),
                "min_response_time": min(response_times),
                "max_response_time": max(response_times),
                "median_response_time": statistics.median(response_times),
                "p95_response_time": self._percentile(response_times, 95),
                "p99_response_time": self._percentile(response_times, 99),
            }
        else:
            stats = {
                "endpoint": endpoint,
                "method": method,
                "total_requests": num_requests,
                "success_count": 0,
                "error_count": error_count,
                "success_rate": 0,
                "avg_response_time": 0,
                "min_response_time": 0,
                "max_response_time": 0,
                "median_response_time": 0,
                "p95_response_time": 0,
                "p99_response_time": 0,
            }
        
        self.results.append(stats)
        self._print_stats(stats)
        
        return stats

    def _percentile(self, data: List[float], percentile: int) -> float:
        """Calcule un percentile"""
        if not data:
            return 0
        sorted_data = sorted(data)
        index = int(len(sorted_data) * percentile / 100)
        return sorted_data[min(index, len(sorted_data) - 1)]

    def _print_stats(self, stats: Dict[str, Any]):
        """Affiche les statistiques de performance"""
        print(f"   📊 Résultats:")
        print(f"      Succès: {stats['success_count']}/{stats['total_requests']} ({stats['success_rate']:.1f}%)")
        print(f"      Temps moyen: {stats['avg_response_time']:.3f}s")
        print(f"      Temps médian: {stats['median_response_time']:.3f}s")
        print(f"      P95: {stats['p95_response_time']:.3f}s")
        print(f"      P99: {stats['p99_response_time']:.3f}s")
        print(f"      Min: {stats['min_response_time']:.3f}s")
        print(f"      Max: {stats['max_response_time']:.3f}s")
        print()

    def test_concurrent_requests(
        self, 
        endpoint: str, 
        method: str = "GET",
        data: Dict = None,
        headers: Dict = None,
        num_requests: int = 50,
        max_workers: int = 10
    ) -> Dict[str, Any]:
        """
        Teste les performances avec des requêtes concurrentes
        
        Args:
            endpoint: URL de l'endpoint
            method: Méthode HTTP
            data: Données à envoyer
            headers: En-têtes HTTP
            num_requests: Nombre de requêtes à effectuer
            max_workers: Nombre de threads concurrents
        
        Returns:
            Statistiques de performance
        """
        print(f"🚀 Test de performance concurrente: {method} {endpoint}")
        print(f"   Requêtes: {num_requests}, Workers: {max_workers}")
        
        def make_request():
            start_time = time.time()
            try:
                if method.upper() == "GET":
                    response = requests.get(
                        f"{self.base_url}{endpoint}",
                        headers=headers,
                        timeout=30
                    )
                elif method.upper() == "POST":
                    response = requests.post(
                        f"{self.base_url}{endpoint}",
                        json=data,
                        headers=headers,
                        timeout=30
                    )
                else:
                    raise ValueError(f"Méthode non supportée: {method}")
                
                response_time = time.time() - start_time
                return {
                    "success": response.status_code < 400,
                    "response_time": response_time,
                    "status_code": response.status_code
                }
            except Exception as e:
                response_time = time.time() - start_time
                return {
                    "success": False,
                    "response_time": response_time,
                    "error": str(e)
                }
        
        # Exécuter les requêtes concurrentes
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = [executor.submit(make_request) for _ in range(num_requests)]
            results = [future.result() for future in futures]
        
        total_time = time.time() - start_time
        
        # Analyser les résultats
        response_times = [r["response_time"] for r in results]
        success_count = sum(1 for r in results if r["success"])
        error_count = num_requests - success_count
        
        stats = {
            "endpoint": endpoint,
            "method": method,
            "total_requests": num_requests,
            "max_workers": max_workers,
            "total_time": total_time,
            "requests_per_second": num_requests / total_time,
            "success_count": success_count,
            "error_count": error_count,
            "success_rate": (success_count / num_requests) * 100,
            "avg_response_time": statistics.mean(response_times),
            "min_response_time": min(response_times),
            "max_response_time": max(response_times),
            "median_response_time": statistics.median(response_times),
            "p95_response_time": self._percentile(response_times, 95),
            "p99_response_time": self._percentile(response_times, 99),
        }
        
        self.results.append(stats)
        self._print_concurrent_stats(stats)
        
        return stats

    def _print_concurrent_stats(self, stats: Dict[str, Any]):
        """Affiche les statistiques de performance concurrente"""
        print(f"   📊 Résultats concurrents:")
        print(f"      Temps total: {stats['total_time']:.3f}s")
        print(f"      Requêtes/seconde: {stats['requests_per_second']:.2f}")
        print(f"      Succès: {stats['success_count']}/{stats['total_requests']} ({stats['success_rate']:.1f}%)")
        print(f"      Temps moyen: {stats['avg_response_time']:.3f}s")
        print(f"      P95: {stats['p95_response_time']:.3f}s")
        print(f"      P99: {stats['p99_response_time']:.3f}s")
        print()

    def run_comprehensive_test(self):
        """Exécute une suite complète de tests de performance"""
        print("🚀 Test de performance complet - Learnia Backend")
        print("=" * 60)
        
        # Test 1: Santé du backend
        print("1. Test de santé du backend")
        self.test_endpoint_performance("/health", "GET", num_requests=5)
        
        # Test 2: Endpoints d'authentification
        print("2. Test des endpoints d'authentification")
        
        # Test d'inscription
        register_data = {
            "email": f"perf_test_{int(time.time())}@example.com",
            "username": f"perf_test_{int(time.time())}",
            "full_name": "Performance Test User",
            "password": "TestPassword123!",
            "grade_level": "Collège"
        }
        
        self.test_endpoint_performance(
            "/api/v1/auth/register", 
            "POST", 
            data=register_data,
            num_requests=5
        )
        
        # Test de connexion
        login_data = {
            "email": register_data["email"],
            "password": register_data["password"]
        }
        
        login_stats = self.test_endpoint_performance(
            "/api/v1/auth/login", 
            "POST", 
            data=login_data,
            num_requests=5
        )
        
        # Test 3: Endpoints authentifiés (si la connexion a réussi)
        if login_stats["success_count"] > 0:
            print("3. Test des endpoints authentifiés")
            
            # Récupérer le token (simulation)
            # En réalité, il faudrait parser la réponse de login
            token = "test_token"  # Placeholder
            
            headers = {"Authorization": f"Bearer {token}"}
            
            # Test du profil utilisateur
            self.test_endpoint_performance(
                "/api/v1/auth/me", 
                "GET", 
                headers=headers,
                num_requests=5
            )
            
            # Test du tuteur intelligent
            tutor_data = {
                "question": "Qu'est-ce qu'une fraction ?",
                "subject": "Mathématiques",
                "grade_level": "Collège"
            }
            
            self.test_endpoint_performance(
                "/api/v1/ai/tutor/", 
                "POST", 
                data=tutor_data,
                headers=headers,
                num_requests=5
            )
        
        # Test 4: Tests de charge
        print("4. Tests de charge")
        
        # Test de charge sur l'endpoint de santé
        self.test_concurrent_requests(
            "/health", 
            "GET", 
            num_requests=100,
            max_workers=20
        )
        
        # Test de charge sur l'endpoint de connexion
        self.test_concurrent_requests(
            "/api/v1/auth/login", 
            "POST", 
            data=login_data,
            num_requests=50,
            max_workers=10
        )
        
        # Résumé des résultats
        self.print_summary()

    def print_summary(self):
        """Affiche un résumé des résultats"""
        print("\n" + "=" * 60)
        print("📊 RÉSUMÉ DES PERFORMANCES")
        print("=" * 60)
        
        if not self.results:
            print("Aucun résultat à afficher.")
            return
        
        # Calculer les moyennes globales
        total_requests = sum(r["total_requests"] for r in self.results)
        total_success = sum(r["success_count"] for r in self.results)
        avg_response_time = statistics.mean([r["avg_response_time"] for r in self.results])
        
        print(f"Total des requêtes: {total_requests}")
        print(f"Taux de succès global: {(total_success/total_requests)*100:.1f}%")
        print(f"Temps de réponse moyen: {avg_response_time:.3f}s")
        
        print("\n📈 Détails par endpoint:")
        for result in self.results:
            print(f"  {result['method']} {result['endpoint']}:")
            print(f"    Succès: {result['success_count']}/{result['total_requests']} ({result['success_rate']:.1f}%)")
            print(f"    Temps moyen: {result['avg_response_time']:.3f}s")
            if 'requests_per_second' in result:
                print(f"    Requêtes/seconde: {result['requests_per_second']:.2f}")
        
        print("\n✅ Test de performance terminé!")


def main():
    """Fonction principale"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Test de performance Learnia Backend")
    parser.add_argument("--url", default="http://localhost:8000", help="URL du backend")
    parser.add_argument("--endpoint", help="Endpoint spécifique à tester")
    parser.add_argument("--requests", type=int, default=10, help="Nombre de requêtes")
    parser.add_argument("--concurrent", action="store_true", help="Test concurrent")
    parser.add_argument("--workers", type=int, default=10, help="Nombre de workers concurrents")
    
    args = parser.parse_args()
    
    tester = PerformanceTester(args.url)
    
    if args.endpoint:
        # Test d'un endpoint spécifique
        if args.concurrent:
            tester.test_concurrent_requests(
                args.endpoint, 
                num_requests=args.requests,
                max_workers=args.workers
            )
        else:
            tester.test_endpoint_performance(
                args.endpoint, 
                num_requests=args.requests
            )
    else:
        # Test complet
        tester.run_comprehensive_test()


if __name__ == "__main__":
    main()
