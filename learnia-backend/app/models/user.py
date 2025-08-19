from datetime import datetime, date
from typing import Optional

from pydantic import EmailStr
from sqlmodel import Field, SQLModel
from sqlalchemy import UniqueConstraint  # Ajouté pour les contraintes d'unicité

class UserBase(SQLModel):
    """Modèle de base pour les utilisateurs"""

    email: EmailStr = Field(index=True)
    username: str = Field(index=True)
    full_name: Optional[str] = None
    grade_level: Optional[str] = None
    school: Optional[str] = None
    is_active: bool = True
    is_teacher: bool = False
    birth_date: Optional[date] = None
    phone: Optional[str] = None

class User(UserBase, table=True):
    """Modèle utilisateur pour la base de données"""

    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None

    __table_args__ = (
        UniqueConstraint("email"),
        UniqueConstraint("username"),
    )

class UserCreate(UserBase):
    """Modèle pour la création d'un utilisateur"""

    password: str

class UserUpdate(SQLModel):
    """Modèle pour la mise à jour d'un utilisateur"""

    email: Optional[EmailStr] = None
    username: Optional[str] = None
    full_name: Optional[str] = None
    grade_level: Optional[str] = None
    school: Optional[str] = None
    password: Optional[str] = None
    birth_date: Optional[date] = None
    phone: Optional[str] = None

class UserResponse(UserBase):
    """Modèle pour la réponse utilisateur (sans mot de passe)"""

    id: int
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None

class UserLogin(SQLModel):
    """Modèle pour la connexion utilisateur"""

    email: EmailStr
    password: str

class Token(SQLModel):
    """Modèle pour le token d'authentification"""

    access_token: str
    token_type: str = "bearer"

class TokenData(SQLModel):
    """Modèle pour les données du token"""

    email: Optional[str] = None