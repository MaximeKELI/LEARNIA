from fastapi import APIRouter, Depends, HTTPException, status
from loguru import logger
from sqlmodel import Session

from ..database import get_session
from ..models.ai_models import TutorRequest, TutorResponse
from ..models.user import User
from ..services.ai_service import ai_service
from ..services.auth import get_current_active_user

router = APIRouter(prefix="/ai/tutor", tags=["Tuteur Intelligent"])


@router.post("/", response_model=TutorResponse)
async def ask_tutor(
    request: TutorRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_session),
):
    """
    Pose une question au tuteur intelligent

    - **question**: La question de l'élève
    - **subject**: La matière concernée
    - **grade_level**: Le niveau de l'élève (optionnel)
    - **context**: Contexte supplémentaire (optionnel)
    """
    try:
        logger.info(
            f"Question tuteur de {current_user.email}: "
            f"{request.question[:50]}..."
        )

        # Générer la réponse via le service IA
        response = await ai_service.generate_tutor_response(request)

        # Log de l'activité
        logger.info(
            f"Réponse tuteur générée pour {current_user.email} - "
            f"Source: {response.source}"
        )

        return response

    except Exception as e:
        logger.error(f"Erreur lors de la génération de réponse tuteur: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la génération de la réponse",
        )


@router.get("/suggestions/{subject}")
async def get_suggestions(
    subject: str, current_user: User = Depends(get_current_active_user)
):
    """
    Obtient des suggestions de questions pour une matière donnée
    """
    try:
        suggestions = {
            "mathématiques": [
                "Qu'est-ce qu'une fraction ?",
                "Comment calculer l'aire d'un cercle ?",
                "Qu'est-ce qu'une équation ?",
                "Comment résoudre une inéquation ?",
                "Qu'est-ce que le théorème de Pythagore ?",
            ],
            "français": [
                "Qu'est-ce qu'un verbe ?",
                "Comment conjuguer le verbe être ?",
                "Qu'est-ce qu'un adjectif ?",
                "Qu'est-ce qu'une proposition ?",
                "Comment analyser une phrase ?",
            ],
            "histoire": [
                "Qu'est-ce que la colonisation ?",
                "Quand le Togo a-t-il obtenu son indépendance ?",
                "Qu'est-ce qu'une révolution ?",
                "Qui était Kwame Nkrumah ?",
                "Qu'est-ce que la décolonisation ?",
            ],
            "sciences": [
                "Qu'est-ce que l'électricité ?",
                "Comment fonctionne la photosynthèse ?",
                "Qu'est-ce qu'une réaction chimique ?",
                "Qu'est-ce que l'ADN ?",
                "Comment fonctionne le système digestif ?",
            ],
        }

        return {
            "subject": subject,
            "suggestions": suggestions.get(
                subject.lower(),
                [
                    "Pouvez-vous expliquer ce concept ?",
                    "Comment résoudre ce problème ?",
                    "Quelle est la définition de ce terme ?",
                ],
            ),
        }

    except Exception as e:
        logger.error(f"Erreur lors de la récupération des suggestions: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la récupération des suggestions",
        )


@router.get("/subjects")
async def get_subjects():
    """
    Obtient la liste des matières supportées
    """
    return {
        "subjects": [
            "Mathématiques",
            "Français",
            "Histoire",
            "Géographie",
            "Sciences",
            "Anglais",
            "Philosophie",
            "Économie",
        ]
    }


@router.get("/health")
async def tutor_health():
    """
    Vérifie l'état du service tuteur
    """
    return {
        "status": "healthy",
        "service": "tutor",
        "ai_available": ai_service.openai_client is not None,
        "local_fallback": True,
    }
