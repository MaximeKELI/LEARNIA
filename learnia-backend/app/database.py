from loguru import logger
from sqlalchemy.orm import sessionmaker
from sqlmodel import SQLModel, create_engine

from .config import settings

# Création du moteur de base de données
engine = create_engine(
    settings.database_url,
    echo=settings.debug,
    connect_args=(
        {"check_same_thread": False}
        if "sqlite" in settings.database_url
        else {}
    ),
)

# Création de la session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def create_db_and_tables():
    """Crée les tables de la base de données"""
    try:
        SQLModel.metadata.create_all(engine)
        logger.info("Base de données et tables créées avec succès")
    except Exception as e:
        logger.error(f"Erreur lors de la création de la base de données: {e}")
        raise


def get_session():
    """Dependency pour obtenir une session de base de données"""
    with SessionLocal() as session:
        try:
            yield session
        except Exception as e:
            logger.error(f"Erreur de session de base de données: {e}")
            session.rollback()
            raise
        finally:
            session.close()


def init_db():
    """Initialise la base de données"""
    create_db_and_tables()
    logger.info("Base de données initialisée")
