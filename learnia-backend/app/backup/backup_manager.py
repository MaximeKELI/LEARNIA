"""
Gestionnaire de sauvegarde pour la production
"""
import os
import shutil
import gzip
import json
from datetime import datetime, timedelta
from typing import List, Dict, Any
from pathlib import Path
from loguru import logger

from ..config.environment import is_production


class BackupManager:
    """Gestionnaire de sauvegarde pour la production"""

    def __init__(self, backup_dir: str = "/var/backups/learnia"):
        self.backup_dir = Path(backup_dir)
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        self.retention_days = 30

    def create_database_backup(self, database_url: str) -> str:
        """
        Crée une sauvegarde de la base de données
        
        Args:
            database_url: URL de la base de données
        
        Returns:
            Chemin vers le fichier de sauvegarde
        """
        if not is_production():
            logger.info("Sauvegarde ignorée en mode développement")
            return ""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"learnia_db_{timestamp}.sql"
        backup_path = self.backup_dir / backup_filename
        
        try:
            if database_url.startswith("sqlite"):
                # Sauvegarde SQLite
                db_path = database_url.replace("sqlite:///", "")
                shutil.copy2(db_path, backup_path)
                logger.info(f"Sauvegarde SQLite créée: {backup_path}")
                
            elif database_url.startswith("postgresql"):
                # Sauvegarde PostgreSQL
                import subprocess
                cmd = [
                    "pg_dump",
                    database_url,
                    "-f", str(backup_path)
                ]
                subprocess.run(cmd, check=True)
                logger.info(f"Sauvegarde PostgreSQL créée: {backup_path}")
                
            else:
                logger.error(f"Type de base de données non supporté: {database_url}")
                return ""
            
            # Compresser la sauvegarde
            compressed_path = self._compress_backup(backup_path)
            
            # Nettoyer l'ancien fichier
            if compressed_path != backup_path:
                backup_path.unlink()
            
            return str(compressed_path)
            
        except Exception as e:
            logger.error(f"Erreur lors de la sauvegarde de la base de données: {e}")
            return ""

    def create_application_backup(self) -> str:
        """
        Crée une sauvegarde de l'application
        
        Returns:
            Chemin vers le fichier de sauvegarde
        """
        if not is_production():
            logger.info("Sauvegarde d'application ignorée en mode développement")
            return ""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"learnia_app_{timestamp}.tar.gz"
        backup_path = self.backup_dir / backup_filename
        
        try:
            # Créer une archive de l'application
            import tarfile
            
            with tarfile.open(backup_path, "w:gz") as tar:
                # Ajouter les fichiers de l'application (sans node_modules, __pycache__, etc.)
                app_dir = Path(__file__).parent.parent.parent
                
                for file_path in app_dir.rglob("*"):
                    if file_path.is_file():
                        # Ignorer les fichiers temporaires
                        if any(part in str(file_path) for part in [
                            "__pycache__", ".pyc", ".pyo", ".pyd",
                            "node_modules", ".git", ".env", "*.log"
                        ]):
                            continue
                        
                        # Ajouter le fichier à l'archive
                        arcname = file_path.relative_to(app_dir)
                        tar.add(file_path, arcname=arcname)
            
            logger.info(f"Sauvegarde d'application créée: {backup_path}")
            return str(backup_path)
            
        except Exception as e:
            logger.error(f"Erreur lors de la sauvegarde de l'application: {e}")
            return ""

    def create_config_backup(self) -> str:
        """
        Crée une sauvegarde de la configuration
        
        Returns:
            Chemin vers le fichier de sauvegarde
        """
        if not is_production():
            logger.info("Sauvegarde de configuration ignorée en mode développement")
            return ""
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_filename = f"learnia_config_{timestamp}.json"
        backup_path = self.backup_dir / backup_filename
        
        try:
            # Collecter la configuration (sans les secrets)
            config = {
                "timestamp": datetime.now().isoformat(),
                "environment": os.getenv("ENVIRONMENT", "unknown"),
                "app_name": os.getenv("APP_NAME", "Learnia Backend"),
                "version": os.getenv("VERSION", "1.0.0"),
                "database_url": os.getenv("DATABASE_URL", "").replace(
                    os.getenv("DATABASE_PASSWORD", ""), "***"
                ),
                "cors_origins": os.getenv("CORS_ORIGINS", "").split(","),
                "log_level": os.getenv("LOG_LEVEL", "INFO"),
            }
            
            with open(backup_path, 'w') as f:
                json.dump(config, f, indent=2)
            
            logger.info(f"Sauvegarde de configuration créée: {backup_path}")
            return str(backup_path)
            
        except Exception as e:
            logger.error(f"Erreur lors de la sauvegarde de la configuration: {e}")
            return ""

    def _compress_backup(self, backup_path: Path) -> Path:
        """
        Compresse un fichier de sauvegarde
        
        Args:
            backup_path: Chemin vers le fichier à compresser
        
        Returns:
            Chemin vers le fichier compressé
        """
        compressed_path = backup_path.with_suffix(backup_path.suffix + ".gz")
        
        with open(backup_path, 'rb') as f_in:
            with gzip.open(compressed_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        
        return compressed_path

    def cleanup_old_backups(self):
        """Nettoie les anciennes sauvegardes"""
        if not is_production():
            return
        
        cutoff_date = datetime.now() - timedelta(days=self.retention_days)
        deleted_count = 0
        
        try:
            for backup_file in self.backup_dir.iterdir():
                if backup_file.is_file():
                    # Vérifier l'âge du fichier
                    file_time = datetime.fromtimestamp(backup_file.stat().st_mtime)
                    if file_time < cutoff_date:
                        backup_file.unlink()
                        deleted_count += 1
                        logger.info(f"Ancienne sauvegarde supprimée: {backup_file}")
            
            logger.info(f"Nettoyage terminé: {deleted_count} fichiers supprimés")
            
        except Exception as e:
            logger.error(f"Erreur lors du nettoyage des sauvegardes: {e}")

    def list_backups(self) -> List[Dict[str, Any]]:
        """
        Liste toutes les sauvegardes disponibles
        
        Returns:
            Liste des sauvegardes avec leurs métadonnées
        """
        backups = []
        
        try:
            for backup_file in self.backup_dir.iterdir():
                if backup_file.is_file():
                    stat = backup_file.stat()
                    backups.append({
                        "filename": backup_file.name,
                        "size": stat.st_size,
                        "created": datetime.fromtimestamp(stat.st_mtime).isoformat(),
                        "type": self._get_backup_type(backup_file.name)
                    })
            
            # Trier par date de création (plus récent en premier)
            backups.sort(key=lambda x: x["created"], reverse=True)
            
        except Exception as e:
            logger.error(f"Erreur lors de la liste des sauvegardes: {e}")
        
        return backups

    def _get_backup_type(self, filename: str) -> str:
        """Détermine le type de sauvegarde à partir du nom de fichier"""
        if "db_" in filename:
            return "database"
        elif "app_" in filename:
            return "application"
        elif "config_" in filename:
            return "configuration"
        else:
            return "unknown"

    def restore_database(self, backup_path: str, database_url: str) -> bool:
        """
        Restaure une base de données à partir d'une sauvegarde
        
        Args:
            backup_path: Chemin vers le fichier de sauvegarde
            database_url: URL de la base de données de destination
        
        Returns:
            True si la restauration a réussi
        """
        if not is_production():
            logger.warning("Restauration ignorée en mode développement")
            return False
        
        try:
            backup_file = Path(backup_path)
            
            if not backup_file.exists():
                logger.error(f"Fichier de sauvegarde introuvable: {backup_path}")
                return False
            
            # Décompresser si nécessaire
            if backup_file.suffix == ".gz":
                import tempfile
                with tempfile.NamedTemporaryFile(delete=False) as temp_file:
                    with gzip.open(backup_file, 'rb') as f_in:
                        shutil.copyfileobj(f_in, temp_file)
                    temp_path = temp_file.name
            else:
                temp_path = str(backup_file)
            
            if database_url.startswith("sqlite"):
                # Restauration SQLite
                db_path = database_url.replace("sqlite:///", "")
                shutil.copy2(temp_path, db_path)
                logger.info(f"Base de données SQLite restaurée depuis: {backup_path}")
                
            elif database_url.startswith("postgresql"):
                # Restauration PostgreSQL
                import subprocess
                cmd = [
                    "psql",
                    database_url,
                    "-f", temp_path
                ]
                subprocess.run(cmd, check=True)
                logger.info(f"Base de données PostgreSQL restaurée depuis: {backup_path}")
                
            else:
                logger.error(f"Type de base de données non supporté: {database_url}")
                return False
            
            # Nettoyer le fichier temporaire
            if temp_path != str(backup_file):
                os.unlink(temp_path)
            
            return True
            
        except Exception as e:
            logger.error(f"Erreur lors de la restauration: {e}")
            return False


# Instance globale du gestionnaire de sauvegarde
backup_manager = BackupManager()
