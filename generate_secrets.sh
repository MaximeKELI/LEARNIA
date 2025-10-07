#!/bin/bash

# Script de génération de clés sécurisées pour la production
echo "🔐 Génération de clés sécurisées pour Learnia"
echo "============================================="

# Vérifier si OpenSSL est installé
if ! command -v openssl &> /dev/null; then
    echo "❌ OpenSSL n'est pas installé"
    echo "Installez-le avec: sudo apt install openssl"
    exit 1
fi

echo "🔑 Génération des clés..."

# Générer une clé secrète JWT
echo "SECRET_KEY=$(openssl rand -hex 32)"

# Générer un mot de passe PostgreSQL
echo "POSTGRES_PASSWORD=$(openssl rand -base64 32)"

# Générer un mot de passe Redis
echo "REDIS_PASSWORD=$(openssl rand -base64 16)"

# Générer un mot de passe Grafana
echo "GRAFANA_PASSWORD=$(openssl rand -base64 16)"

# Générer une clé de chiffrement
echo "ENCRYPTION_KEY=$(openssl rand -hex 32)"

# Générer un salt pour le hachage
echo "HASH_SALT=$(openssl rand -hex 16)"

echo ""
echo "✅ Clés générées avec succès!"
echo ""
echo "📝 Instructions:"
echo "1. Copiez ces clés dans votre fichier .env.production"
echo "2. Ne partagez jamais ces clés"
echo "3. Stockez-les de manière sécurisée"
echo "4. Régénérez-les régulièrement"
echo ""
echo "⚠️  IMPORTANT: Ces clés sont sensibles, ne les commitez jamais!"
