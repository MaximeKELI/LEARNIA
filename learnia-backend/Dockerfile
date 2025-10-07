# Dockerfile pour Learnia Backend - Production
FROM python:3.11-slim

# Métadonnées
LABEL maintainer="Learnia Team <contact@learnia.tg>"
LABEL description="Learnia Backend API"
LABEL version="1.0.0"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV ENVIRONMENT=production
ENV PORT=8000

# Créer un utilisateur non-root
RUN groupadd -r learnia && useradd -r -g learnia learnia

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Créer le répertoire de l'application
WORKDIR /app

# Copier les fichiers de dépendances
COPY requirements.txt .

# Installer les dépendances Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY . .

# Créer les répertoires nécessaires
RUN mkdir -p /app/logs /app/backups && \
    chown -R learnia:learnia /app

# Changer vers l'utilisateur non-root
USER learnia

# Exposer le port
EXPOSE 8000

# Script de santé
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Commande de démarrage
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
