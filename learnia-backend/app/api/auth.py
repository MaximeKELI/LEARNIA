from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from loguru import logger
from sqlmodel import Session

from ..database import get_session
from ..models.user import Token, User, UserCreate, UserResponse, UserLogin
from ..services.auth import (
    authenticate_user,
    create_access_token,
    create_user,
    get_current_active_user,
)

router = APIRouter(prefix="/auth", tags=["Authentification"])


@router.post("/register", response_model=UserResponse)
async def register(
    user_create: UserCreate, db: Session = Depends(get_session)
):
    """
    Enregistre un nouvel utilisateur

    - **email**: Email de l'utilisateur
    - **username**: Nom d'utilisateur unique
    - **password**: Mot de passe
    - **full_name**: Nom complet (optionnel)
    - **grade_level**: Niveau scolaire (optionnel)
    - **school**: École (optionnel)
    - **is_teacher**: Si c'est un enseignant (optionnel)
    - **birth_date**: Date de naissance (optionnel, format YYYY-MM-DD)
    - **phone**: Numéro de téléphone (optionnel)
    """
    try:
        user = create_user(db, user_create)
        logger.info(f"Nouvel utilisateur enregistré: {user.email}")

        return UserResponse(
            id=user.id,
            email=user.email,
            username=user.username,
            full_name=user.full_name,
            grade_level=user.grade_level,
            school=user.school,
            is_active=user.is_active,
            is_teacher=user.is_teacher,
            created_at=user.created_at,
            updated_at=user.updated_at,
            last_login=user.last_login,
            birth_date=user.birth_date,
            phone=user.phone,
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur lors de l'enregistrement: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'enregistrement",
        )


@router.post("/login", response_model=Token)
async def login(
    user_login: UserLogin,
    db: Session = Depends(get_session),
):
    """
    Connecte un utilisateur et retourne un token d'accès

    - **username**: Email de l'utilisateur
    - **password**: Mot de passe
    """
    try:
        user = authenticate_user(db, user_login.email, user_login.password)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Email ou mot de passe incorrect",
                headers={"WWW-Authenticate": "Bearer"},
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Compte inactif",
            )

        access_token_expires = timedelta(minutes=30)
        access_token = create_access_token(
            data={"sub": user.email}, expires_delta=access_token_expires
        )

        logger.info(f"Connexion réussie: {user.email}")

        return {"access_token": access_token, "token_type": "bearer"}

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Erreur lors de la connexion: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de la connexion",
        )


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user),
):
    """
    Obtient les informations de l'utilisateur connecté
    """
    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        username=current_user.username,
        full_name=current_user.full_name,
        grade_level=current_user.grade_level,
        school=current_user.school,
        is_active=current_user.is_active,
        is_teacher=current_user.is_teacher,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
        last_login=current_user.last_login,
        birth_date=current_user.birth_date,
        phone=current_user.phone,
    )


@router.post("/logout")
async def logout(current_user: User = Depends(get_current_active_user)):
    """
    Déconnecte l'utilisateur (côté client)
    """
    logger.info(f"Déconnexion: {current_user.email}")
    return {"message": "Déconnexion réussie"}


@router.get("/health")
async def auth_health():
    """
    Vérifie l'état du service d'authentification
    """
    return {
        "status": "healthy",
        "service": "authentication",
        "jwt_enabled": True,
    }
