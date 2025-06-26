import time
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from loguru import logger

from .api import auth, tutor
from .config import settings
from .database import init_db

# Configuration des logs
logger.add(
    settings.log_file,
    level=settings.log_level,
    rotation="10 MB",
    retention="7 days",
    format="{time} {level} {message}",
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Gestion du cycle de vie de l'application"""
    # Démarrage
    logger.info("Démarrage de l'application Learnia Backend")
    init_db()
    logger.info("Base de données initialisée")

    yield

    # Arrêt
    logger.info("Arrêt de l'application Learnia Backend")


# Création de l'application FastAPI
app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    description="""
    ## Learnia Backend API
    
    API backend pour l'application éducative Learnia destinée aux élèves 
    togolais.
    
    ### Fonctionnalités principales :
    
    * **Tuteur intelligent** : Chatbot éducatif avec IA
    * **Générateur de QCM** : Création automatique de quiz
    * **Résumé automatique** : Extraction des points clés
    * **Traduction** : Support des langues locales (éwé, kabiyè)
    * **Orientation scolaire** : Conseils d'orientation
    * **OCR** : Reconnaissance de texte manuscrit
    * **Authentification** : Gestion des utilisateurs avec JWT
    
    ### Environnements :
    
    * **Développement** : http://localhost:8000
    * **Production** : https://api.learnia.tg
    
    ### Documentation :
    
    * **Swagger UI** : /docs
    * **ReDoc** : /redoc
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Middleware pour les logs de requêtes
@app.middleware("http")
async def log_requests(request, call_next):
    start_time = time.time()

    # Log de la requête
    logger.info(f"Requête {request.method} {request.url}")

    response = await call_next(request)

    # Log de la réponse
    process_time = time.time() - start_time
    logger.info(f"Réponse {response.status_code} en {process_time:.3f}s")

    return response


# Gestionnaire d'erreurs global
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Erreur globale: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Erreur interne du serveur",
            "error": str(exc) if settings.debug else "Une erreur est survenue",
        },
    )


# Routes principales
@app.get("/")
async def root():
    """Point d'entrée de l'API"""
    return {
        "message": "Bienvenue sur l'API Learnia Backend",
        "version": settings.version,
        "status": "running",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health")
async def health_check():
    """Vérification de l'état de l'API"""
    return {
        "status": "healthy",
        "version": settings.version,
        "timestamp": time.time(),
        "services": {
            "database": "connected",
            "ai_service": (
                "available" if settings.openai_api_key else "local_only"
            ),
            "authentication": "enabled",
        },
    }


@app.get("/config")
async def get_config():
    """Obtient la configuration publique de l'API"""
    return {
        "app_name": settings.app_name,
        "version": settings.version,
        "supported_languages": settings.supported_languages,
        "subjects": settings.subjects,
        "grade_levels": settings.grade_levels,
        "ai_models": {
            "default": settings.default_ai_model,
            "max_tokens": settings.max_tokens,
            "temperature": settings.temperature,
        },
    }


# Inclusion des routers
app.include_router(auth.router, prefix="/api/v1")
app.include_router(tutor.router, prefix="/api/v1")


# Routes de test (uniquement en mode debug)
if settings.debug:

    @app.get("/test")
    async def test_endpoint():
        """Endpoint de test pour le développement"""
        return {
            "message": "Endpoint de test",
            "debug": True,
            "timestamp": time.time(),
        }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
        log_level=settings.log_level.lower(),
    )
