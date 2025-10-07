#!/bin/bash

# Script de déploiement en production pour Learnia
set -e  # Arrêter en cas d'erreur

echo "🚀 Déploiement de Learnia en production"
echo "======================================"

# Configuration
PROJECT_NAME="learnia"
BACKEND_DIR="learnia-backend"
FRONTEND_DIR="learnia"
PRODUCTION_USER="learnia"
PRODUCTION_DIR="/opt/learnia"
NGINX_CONFIG="/etc/nginx/sites-available/learnia"
SYSTEMD_SERVICE="learnia-backend"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction de logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Vérifier les prérequis
check_prerequisites() {
    log "Vérification des prérequis..."
    
    # Vérifier si on est root ou sudo
    if [[ $EUID -ne 0 ]]; then
        error "Ce script doit être exécuté en tant que root ou avec sudo"
    fi
    
    # Vérifier les commandes nécessaires
    for cmd in git python3 pip3 nginx systemctl; do
        if ! command -v $cmd &> /dev/null; then
            error "Commande manquante: $cmd"
        fi
    done
    
    log "Prérequis vérifiés ✓"
}

# Installer les dépendances système
install_system_dependencies() {
    log "Installation des dépendances système..."
    
    # Mettre à jour le système
    apt-get update
    
    # Installer les dépendances
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        nginx \
        postgresql \
        postgresql-contrib \
        redis-server \
        git \
        curl \
        wget \
        unzip \
        build-essential \
        libpq-dev \
        python3-dev
    
    log "Dépendances système installées ✓"
}

# Configurer PostgreSQL
setup_postgresql() {
    log "Configuration de PostgreSQL..."
    
    # Créer la base de données
    sudo -u postgres psql -c "CREATE DATABASE learnia_prod;"
    sudo -u postgres psql -c "CREATE USER learnia WITH PASSWORD 'secure_password_here';"
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE learnia_prod TO learnia;"
    
    log "PostgreSQL configuré ✓"
}

# Configurer Redis
setup_redis() {
    log "Configuration de Redis..."
    
    # Configurer Redis pour la production
    cat > /etc/redis/redis.conf << EOF
# Configuration Redis pour Learnia
bind 127.0.0.1
port 6379
timeout 300
tcp-keepalive 60
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
EOF
    
    systemctl restart redis-server
    systemctl enable redis-server
    
    log "Redis configuré ✓"
}

# Créer l'utilisateur de production
create_production_user() {
    log "Création de l'utilisateur de production..."
    
    if ! id "$PRODUCTION_USER" &>/dev/null; then
        useradd -m -s /bin/bash "$PRODUCTION_USER"
        usermod -aG www-data "$PRODUCTION_USER"
    fi
    
    log "Utilisateur de production créé ✓"
}

# Déployer le backend
deploy_backend() {
    log "Déploiement du backend..."
    
    # Créer le répertoire de production
    mkdir -p "$PRODUCTION_DIR"
    chown "$PRODUCTION_USER:$PRODUCTION_USER" "$PRODUCTION_DIR"
    
    # Copier le code source
    cp -r "$BACKEND_DIR" "$PRODUCTION_DIR/"
    chown -R "$PRODUCTION_USER:$PRODUCTION_USER" "$PRODUCTION_DIR/$BACKEND_DIR"
    
    # Aller dans le répertoire du backend
    cd "$PRODUCTION_DIR/$BACKEND_DIR"
    
    # Créer l'environnement virtuel
    sudo -u "$PRODUCTION_USER" python3 -m venv venv
    sudo -u "$PRODUCTION_USER" ./venv/bin/pip install --upgrade pip
    sudo -u "$PRODUCTION_USER" ./venv/bin/pip install -r requirements.txt
    
    # Créer le fichier de configuration de production
    sudo -u "$PRODUCTION_USER" cp env.production.example .env.production
    
    log "Backend déployé ✓"
}

# Configurer le service systemd
setup_systemd_service() {
    log "Configuration du service systemd..."
    
    cat > "/etc/systemd/system/$SYSTEMD_SERVICE.service" << EOF
[Unit]
Description=Learnia Backend API
After=network.target postgresql.service redis.service

[Service]
Type=exec
User=$PRODUCTION_USER
Group=$PRODUCTION_USER
WorkingDirectory=$PRODUCTION_DIR/$BACKEND_DIR
Environment=PATH=$PRODUCTION_DIR/$BACKEND_DIR/venv/bin
Environment=ENVIRONMENT=production
ExecStart=$PRODUCTION_DIR/$BACKEND_DIR/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable "$SYSTEMD_SERVICE"
    
    log "Service systemd configuré ✓"
}

# Configurer Nginx
setup_nginx() {
    log "Configuration de Nginx..."
    
    # Créer la configuration Nginx
    cat > "$NGINX_CONFIG" << EOF
server {
    listen 80;
    server_name learnia.tg www.learnia.tg;
    
    # Redirection HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name learnia.tg www.learnia.tg;
    
    # Configuration SSL (à configurer avec Let's Encrypt)
    ssl_certificate /etc/ssl/certs/learnia.crt;
    ssl_certificate_key /etc/ssl/private/learnia.key;
    
    # Configuration de sécurité
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
    
    # Proxy vers l'API backend
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Proxy vers l'application Flutter
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Logs
    access_log /var/log/nginx/learnia_access.log;
    error_log /var/log/nginx/learnia_error.log;
}
EOF
    
    # Activer le site
    ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/
    nginx -t
    systemctl reload nginx
    
    log "Nginx configuré ✓"
}

# Configurer les logs
setup_logging() {
    log "Configuration des logs..."
    
    # Créer le répertoire de logs
    mkdir -p /var/log/learnia
    chown "$PRODUCTION_USER:$PRODUCTION_USER" /var/log/learnia
    
    # Configurer logrotate
    cat > /etc/logrotate.d/learnia << EOF
/var/log/learnia/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 $PRODUCTION_USER $PRODUCTION_USER
    postrotate
        systemctl reload $SYSTEMD_SERVICE
    endscript
}
EOF
    
    log "Logs configurés ✓"
}

# Configurer le monitoring
setup_monitoring() {
    log "Configuration du monitoring..."
    
    # Installer htop et iotop pour le monitoring
    apt-get install -y htop iotop
    
    # Créer un script de monitoring
    cat > "/usr/local/bin/learnia-monitor.sh" << EOF
#!/bin/bash
# Script de monitoring pour Learnia

echo "=== Learnia Production Monitor ==="
echo "Date: \$(date)"
echo "Uptime: \$(uptime)"
echo ""

echo "=== Services Status ==="
systemctl status $SYSTEMD_SERVICE --no-pager
echo ""
systemctl status nginx --no-pager
echo ""
systemctl status postgresql --no-pager
echo ""
systemctl status redis-server --no-pager
echo ""

echo "=== Disk Usage ==="
df -h
echo ""

echo "=== Memory Usage ==="
free -h
echo ""

echo "=== API Health ==="
curl -s http://localhost:8000/health | jq . || echo "API non accessible"
echo ""

echo "=== Database Connections ==="
sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname='learnia_prod';"
EOF
    
    chmod +x /usr/local/bin/learnia-monitor.sh
    
    log "Monitoring configuré ✓"
}

# Démarrer les services
start_services() {
    log "Démarrage des services..."
    
    # Démarrer PostgreSQL
    systemctl start postgresql
    systemctl enable postgresql
    
    # Démarrer Redis
    systemctl start redis-server
    systemctl enable redis-server
    
    # Démarrer l'API
    systemctl start "$SYSTEMD_SERVICE"
    
    # Démarrer Nginx
    systemctl start nginx
    systemctl enable nginx
    
    log "Services démarrés ✓"
}

# Vérifier le déploiement
verify_deployment() {
    log "Vérification du déploiement..."
    
    # Attendre que les services démarrent
    sleep 10
    
    # Vérifier l'API
    if curl -s http://localhost:8000/health > /dev/null; then
        log "API backend accessible ✓"
    else
        error "API backend non accessible"
    fi
    
    # Vérifier Nginx
    if systemctl is-active --quiet nginx; then
        log "Nginx actif ✓"
    else
        error "Nginx non actif"
    fi
    
    # Vérifier PostgreSQL
    if systemctl is-active --quiet postgresql; then
        log "PostgreSQL actif ✓"
    else
        error "PostgreSQL non actif"
    fi
    
    # Vérifier Redis
    if systemctl is-active --quiet redis-server; then
        log "Redis actif ✓"
    else
        error "Redis non actif"
    fi
    
    log "Déploiement vérifié ✓"
}

# Afficher les informations de déploiement
show_deployment_info() {
    log "Informations de déploiement:"
    echo ""
    echo "📍 Répertoire de production: $PRODUCTION_DIR"
    echo "🔧 Service systemd: $SYSTEMD_SERVICE"
    echo "🌐 Configuration Nginx: $NGINX_CONFIG"
    echo "📊 Script de monitoring: /usr/local/bin/learnia-monitor.sh"
    echo ""
    echo "🔑 Actions requises:"
    echo "1. Configurer le fichier .env.production avec vos clés API"
    echo "2. Configurer SSL avec Let's Encrypt"
    echo "3. Configurer le domaine DNS"
    echo "4. Tester l'application complète"
    echo ""
    echo "📋 Commandes utiles:"
    echo "  - Voir les logs: journalctl -u $SYSTEMD_SERVICE -f"
    echo "  - Redémarrer: systemctl restart $SYSTEMD_SERVICE"
    echo "  - Monitoring: /usr/local/bin/learnia-monitor.sh"
    echo "  - Status: systemctl status $SYSTEMD_SERVICE"
    echo ""
}

# Fonction principale
main() {
    log "Début du déploiement de Learnia en production"
    
    check_prerequisites
    install_system_dependencies
    setup_postgresql
    setup_redis
    create_production_user
    deploy_backend
    setup_systemd_service
    setup_nginx
    setup_logging
    setup_monitoring
    start_services
    verify_deployment
    show_deployment_info
    
    log "Déploiement terminé avec succès! 🎉"
}

# Exécuter le script
main "$@"
