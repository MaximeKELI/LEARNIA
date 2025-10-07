"""
Optimisations de base de données pour améliorer les performances
"""
from sqlmodel import Session, select, text
from loguru import logger
from typing import List, Optional, Any
import time


class DatabaseOptimizer:
    """Classe pour optimiser les requêtes de base de données"""

    def __init__(self, session: Session):
        self.session = session

    def create_indexes(self):
        """Crée les index nécessaires pour optimiser les requêtes"""
        indexes = [
            # Index pour les utilisateurs
            "CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)",
            "CREATE INDEX IF NOT EXISTS idx_users_username ON users(username)",
            "CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)",
            
            # Index pour les conversations tuteur
            "CREATE INDEX IF NOT EXISTS idx_tutor_conversations_user_id ON tutor_conversations(user_id)",
            "CREATE INDEX IF NOT EXISTS idx_tutor_conversations_created_at ON tutor_conversations(created_at)",
            "CREATE INDEX IF NOT EXISTS idx_tutor_conversations_subject ON tutor_conversations(subject)",
            
            # Index pour les résultats de quiz
            "CREATE INDEX IF NOT EXISTS idx_quiz_results_user_id ON quiz_results(user_id)",
            "CREATE INDEX IF NOT EXISTS idx_quiz_results_date ON quiz_results(date)",
            "CREATE INDEX IF NOT EXISTS idx_quiz_results_subject ON quiz_results(subject)",
            
            # Index pour les cartes Leitner
            "CREATE INDEX IF NOT EXISTS idx_leitner_cards_level ON leitner_cards(level)",
            "CREATE INDEX IF NOT EXISTS idx_leitner_cards_next_review ON leitner_cards(next_review)",
            "CREATE INDEX IF NOT EXISTS idx_leitner_cards_subject ON leitner_cards(subject)",
            
            # Index pour les plannings
            "CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON study_plans(user_id)",
            "CREATE INDEX IF NOT EXISTS idx_study_plans_day_of_week ON study_plans(day_of_week)",
            
            # Index pour les traductions
            "CREATE INDEX IF NOT EXISTS idx_translations_french_text ON translations(french_text)",
            
            # Index pour les résumés
            "CREATE INDEX IF NOT EXISTS idx_summaries_subject ON summaries(subject)",
            "CREATE INDEX IF NOT EXISTS idx_summaries_created_at ON summaries(created_at)",
        ]
        
        for index_sql in indexes:
            try:
                self.session.exec(text(index_sql))
                logger.info(f"Index créé: {index_sql}")
            except Exception as e:
                logger.error(f"Erreur lors de la création de l'index: {e}")

    def analyze_tables(self):
        """Analyse les tables pour optimiser les requêtes"""
        try:
            # ANALYZE pour SQLite
            self.session.exec(text("ANALYZE"))
            logger.info("Analyse des tables terminée")
        except Exception as e:
            logger.error(f"Erreur lors de l'analyse des tables: {e}")

    def vacuum_database(self):
        """Optimise la base de données (VACUUM)"""
        try:
            self.session.exec(text("VACUUM"))
            logger.info("Optimisation de la base de données terminée")
        except Exception as e:
            logger.error(f"Erreur lors de l'optimisation: {e}")

    def get_table_stats(self) -> dict:
        """Obtient les statistiques des tables"""
        stats = {}
        
        tables = [
            "users", "tutor_conversations", "quiz_results", 
            "leitner_cards", "study_plans", "translations", "summaries"
        ]
        
        for table in tables:
            try:
                result = self.session.exec(text(f"SELECT COUNT(*) FROM {table}")).first()
                stats[table] = result[0] if result else 0
            except Exception as e:
                logger.error(f"Erreur lors de la récupération des stats pour {table}: {e}")
                stats[table] = "Erreur"
        
        return stats

    def optimize_queries(self):
        """Applique les optimisations générales"""
        logger.info("Début des optimisations de base de données...")
        
        # Créer les index
        self.create_indexes()
        
        # Analyser les tables
        self.analyze_tables()
        
        # Optimiser la base
        self.vacuum_database()
        
        logger.info("Optimisations de base de données terminées")


class QueryOptimizer:
    """Classe pour optimiser les requêtes spécifiques"""

    @staticmethod
    def get_user_with_conversations(session: Session, user_id: int, limit: int = 10):
        """Récupère un utilisateur avec ses conversations récentes (optimisé)"""
        start_time = time.time()
        
        # Requête optimisée avec JOIN
        query = text("""
            SELECT u.*, 
                   tc.question, tc.answer, tc.subject, tc.created_at as conversation_date
            FROM users u
            LEFT JOIN tutor_conversations tc ON u.id = tc.user_id
            WHERE u.id = :user_id
            ORDER BY tc.created_at DESC
            LIMIT :limit
        """)
        
        result = session.exec(query, {"user_id": user_id, "limit": limit}).all()
        
        execution_time = time.time() - start_time
        logger.debug(f"Requête utilisateur avec conversations exécutée en {execution_time:.3f}s")
        
        return result

    @staticmethod
    def get_user_stats(session: Session, user_id: int):
        """Récupère les statistiques d'un utilisateur (optimisé)"""
        start_time = time.time()
        
        # Requête optimisée avec agrégations
        query = text("""
            SELECT 
                COUNT(DISTINCT tc.id) as total_conversations,
                COUNT(DISTINCT qr.id) as total_quizzes,
                AVG(qr.score) as average_score,
                COUNT(DISTINCT lc.id) as total_cards,
                COUNT(DISTINCT sp.id) as total_plans
            FROM users u
            LEFT JOIN tutor_conversations tc ON u.id = tc.user_id
            LEFT JOIN quiz_results qr ON u.id = qr.user_id
            LEFT JOIN leitner_cards lc ON u.id = lc.user_id
            LEFT JOIN study_plans sp ON u.id = sp.user_id
            WHERE u.id = :user_id
        """)
        
        result = session.exec(query, {"user_id": user_id}).first()
        
        execution_time = time.time() - start_time
        logger.debug(f"Requête statistiques utilisateur exécutée en {execution_time:.3f}s")
        
        return result

    @staticmethod
    def get_recent_activity(session: Session, user_id: int, days: int = 7):
        """Récupère l'activité récente d'un utilisateur (optimisé)"""
        start_time = time.time()
        
        query = text("""
            SELECT 'conversation' as type, created_at, subject as detail
            FROM tutor_conversations 
            WHERE user_id = :user_id AND created_at >= datetime('now', '-:days days')
            
            UNION ALL
            
            SELECT 'quiz' as type, date as created_at, subject as detail
            FROM quiz_results 
            WHERE user_id = :user_id AND date >= datetime('now', '-:days days')
            
            ORDER BY created_at DESC
            LIMIT 50
        """)
        
        result = session.exec(query, {"user_id": user_id, "days": days}).all()
        
        execution_time = time.time() - start_time
        logger.debug(f"Requête activité récente exécutée en {execution_time:.3f}s")
        
        return result


def optimize_database(session: Session):
    """Fonction utilitaire pour optimiser la base de données"""
    optimizer = DatabaseOptimizer(session)
    optimizer.optimize_queries()
    
    stats = optimizer.get_table_stats()
    logger.info(f"Statistiques des tables: {stats}")
    
    return stats
