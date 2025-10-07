"""
Configuration des tests pour Learnia Backend
"""
import pytest
import asyncio
from typing import Generator, AsyncGenerator
from fastapi.testclient import TestClient
from sqlmodel import Session, create_engine, SQLModel
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import get_session
from app.models.user import User
from app.services.auth import get_password_hash


# Base de données de test en mémoire
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)


@pytest.fixture(scope="session")
def event_loop():
    """Créer un event loop pour les tests asynchrones"""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
def db_session() -> Generator[Session, None, None]:
    """Créer une session de base de données pour chaque test"""
    # Créer les tables
    SQLModel.metadata.create_all(engine)
    
    # Créer une session
    with Session(engine) as session:
        yield session
    
    # Nettoyer après le test
    SQLModel.metadata.drop_all(engine)


@pytest.fixture(scope="function")
def client(db_session: Session) -> Generator[TestClient, None, None]:
    """Créer un client de test FastAPI"""
    def get_session_override():
        return db_session
    
    app.dependency_overrides[get_session] = get_session_override
    
    with TestClient(app) as test_client:
        yield test_client
    
    app.dependency_overrides.clear()


@pytest.fixture
def test_user(db_session: Session) -> User:
    """Créer un utilisateur de test"""
    user = User(
        email="test@example.com",
        username="testuser",
        full_name="Test User",
        grade_level="Collège",
        school="Test School",
        hashed_password=get_password_hash("testpassword123"),
        is_active=True,
        is_teacher=False,
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture
def test_teacher(db_session: Session) -> User:
    """Créer un enseignant de test"""
    teacher = User(
        email="teacher@example.com",
        username="testteacher",
        full_name="Test Teacher",
        grade_level="Lycée",
        school="Test School",
        hashed_password=get_password_hash("teacherpassword123"),
        is_active=True,
        is_teacher=True,
    )
    db_session.add(teacher)
    db_session.commit()
    db_session.refresh(teacher)
    return teacher


@pytest.fixture
def auth_headers(client: TestClient, test_user: User) -> dict:
    """Obtenir les headers d'authentification pour un utilisateur de test"""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_user.email, "password": "testpassword123"}
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture
def teacher_auth_headers(client: TestClient, test_teacher: User) -> dict:
    """Obtenir les headers d'authentification pour un enseignant de test"""
    response = client.post(
        "/api/v1/auth/login",
        data={"username": test_teacher.email, "password": "teacherpassword123"}
    )
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}
