# 🚀 Guide de Déploiement en Production - Learnia

## 📋 Prérequis

### Serveur de Production
- **OS** : Ubuntu 20.04+ ou CentOS 8+
- **RAM** : Minimum 4GB, recommandé 8GB+
- **CPU** : Minimum 2 cœurs, recommandé 4 cœurs+
- **Stockage** : Minimum 50GB, recommandé 100GB+
- **Réseau** : Accès Internet stable

### Logiciels Requis
- **Docker** : 20.10+
- **Docker Compose** : 2.0+
- **Git** : 2.25+
- **OpenSSL** : 1.1.1+

## 🔧 Installation

### 1. Préparation du Serveur

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer les dépendances
sudo apt install -y curl wget git unzip

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 2. Cloner le Projet

```bash
# Cloner le repository
git clone https://github.com/your-org/learnia.git
cd learnia

# Vérifier la structure
ls -la
```

### 3. Configuration

```bash
# Copier le fichier d'environnement
cp env.production.example .env.production

# Éditer la configuration
nano .env.production
```

**Configuration requise :**
```env
# Environnement
ENVIRONMENT=production

# Base de données
POSTGRES_PASSWORD=your-super-secure-postgres-password-here

# Sécurité
SECRET_KEY=your-super-secret-key-here-change-this-immediately

# APIs externes
OPENAI_API_KEY=your-openai-api-key-here
HUGGINGFACE_API_KEY=your-huggingface-api-key-here

# Monitoring
GRAFANA_PASSWORD=your-grafana-admin-password-here

# Domaine
DOMAIN=learnia.tg
```

### 4. Génération des Clés Secrètes

```bash
# Générer une clé secrète sécurisée
openssl rand -hex 32

# Générer un mot de passe PostgreSQL
openssl rand -base64 32

# Générer un mot de passe Grafana
openssl rand -base64 16
```

## 🐳 Déploiement avec Docker

### 1. Déploiement Simple

```bash
# Démarrer tous les services
docker-compose -f docker-compose.production.yml up -d

# Vérifier le statut
docker-compose -f docker-compose.production.yml ps

# Voir les logs
docker-compose -f docker-compose.production.yml logs -f
```

### 2. Déploiement avec SSL

```bash
# Installer Certbot
sudo apt install -y certbot

# Obtenir un certificat SSL
sudo certbot certonly --standalone -d learnia.tg -d www.learnia.tg

# Copier les certificats
sudo cp /etc/letsencrypt/live/learnia.tg/fullchain.pem ./ssl/learnia.crt
sudo cp /etc/letsencrypt/live/learnia.tg/privkey.pem ./ssl/learnia.key
sudo chown $USER:$USER ./ssl/*

# Mettre à jour la configuration
# Modifier docker-compose.production.yml pour inclure les volumes SSL
```

## 🔧 Déploiement Manuel

### 1. Installation des Dépendances

```bash
# Backend
cd learnia-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Frontend
cd ../learnia
flutter pub get
flutter build web
```

### 2. Configuration de la Base de Données

```bash
# Installer PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Créer la base de données
sudo -u postgres psql
CREATE DATABASE learnia_prod;
CREATE USER learnia WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE learnia_prod TO learnia;
\q
```

### 3. Configuration de Redis

```bash
# Installer Redis
sudo apt install -y redis-server

# Configurer Redis
sudo nano /etc/redis/redis.conf
# Modifier : bind 127.0.0.1
# Modifier : maxmemory 256mb
# Modifier : maxmemory-policy allkeys-lru

# Redémarrer Redis
sudo systemctl restart redis-server
sudo systemctl enable redis-server
```

### 4. Configuration de Nginx

```bash
# Installer Nginx
sudo apt install -y nginx

# Créer la configuration
sudo nano /etc/nginx/sites-available/learnia
```

**Configuration Nginx :**
```nginx
server {
    listen 80;
    server_name learnia.tg www.learnia.tg;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name learnia.tg www.learnia.tg;
    
    ssl_certificate /etc/letsencrypt/live/learnia.tg/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/learnia.tg/privkey.pem;
    
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location / {
        root /opt/learnia/learnia/build/web;
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
# Activer le site
sudo ln -s /etc/nginx/sites-available/learnia /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 5. Service Systemd

```bash
# Créer le service
sudo nano /etc/systemd/system/learnia-backend.service
```

**Configuration du service :**
```ini
[Unit]
Description=Learnia Backend API
After=network.target postgresql.service redis.service

[Service]
Type=exec
User=learnia
Group=learnia
WorkingDirectory=/opt/learnia/learnia-backend
Environment=PATH=/opt/learnia/learnia-backend/venv/bin
Environment=ENVIRONMENT=production
ExecStart=/opt/learnia/learnia-backend/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Activer le service
sudo systemctl daemon-reload
sudo systemctl enable learnia-backend
sudo systemctl start learnia-backend
```

## 🔍 Validation

### 1. Test de Validation

```bash
# Valider la configuration
python3 validate_production.py

# Test de connectivité
python3 test_connection.py

# Test de performance
cd learnia-backend && python performance_test.py
```

### 2. Vérifications Manuelles

```bash
# Vérifier les services
systemctl status learnia-backend
systemctl status nginx
systemctl status postgresql
systemctl status redis-server

# Vérifier les ports
netstat -tlnp | grep -E ':(80|443|8000|5432|6379)'

# Vérifier les logs
journalctl -u learnia-backend -f
tail -f /var/log/nginx/access.log
```

## 📊 Monitoring

### 1. Métriques de Base

```bash
# Vérifier l'utilisation des ressources
htop
df -h
free -h

# Vérifier les performances
curl -s http://localhost:8000/health | jq
curl -s http://localhost:8000/metrics
```

### 2. Monitoring Avancé

```bash
# Accéder à Grafana
http://your-domain:3000
# Login: admin / your-grafana-password

# Accéder à Prometheus
http://your-domain:9090

# Accéder à Kibana (si ELK activé)
http://your-domain:5601
```

## 🔒 Sécurité

### 1. Configuration du Pare-feu

```bash
# Installer UFW
sudo apt install -y ufw

# Configurer le pare-feu
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. Mise à Jour de Sécurité

```bash
# Mise à jour automatique
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Mise à jour des certificats SSL
sudo crontab -e
# Ajouter : 0 12 * * * /usr/bin/certbot renew --quiet
```

### 3. Sauvegarde

```bash
# Script de sauvegarde quotidienne
sudo nano /usr/local/bin/learnia-backup.sh
```

**Script de sauvegarde :**
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/learnia"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer le répertoire
mkdir -p $BACKUP_DIR

# Sauvegarde de la base de données
pg_dump learnia_prod > $BACKUP_DIR/db_$DATE.sql

# Sauvegarde des fichiers
tar -czf $BACKUP_DIR/app_$DATE.tar.gz /opt/learnia

# Nettoyer les anciennes sauvegardes
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

```bash
# Rendre exécutable
sudo chmod +x /usr/local/bin/learnia-backup.sh

# Programmer la sauvegarde
sudo crontab -e
# Ajouter : 0 2 * * * /usr/local/bin/learnia-backup.sh
```

## 🚨 Dépannage

### 1. Problèmes Courants

**Service ne démarre pas :**
```bash
# Vérifier les logs
journalctl -u learnia-backend -f

# Vérifier la configuration
python3 validate_production.py
```

**Base de données inaccessible :**
```bash
# Vérifier PostgreSQL
sudo systemctl status postgresql
sudo -u postgres psql -c "SELECT 1;"
```

**Redis inaccessible :**
```bash
# Vérifier Redis
sudo systemctl status redis-server
redis-cli ping
```

### 2. Logs Importants

```bash
# Logs de l'application
tail -f /var/log/learnia/learnia.log

# Logs Nginx
tail -f /var/log/nginx/error.log

# Logs système
journalctl -f
```

### 3. Redémarrage des Services

```bash
# Redémarrer tous les services
sudo systemctl restart learnia-backend nginx postgresql redis-server

# Redémarrer avec Docker
docker-compose -f docker-compose.production.yml restart
```

## 📈 Optimisation

### 1. Performance

```bash
# Optimiser PostgreSQL
sudo nano /etc/postgresql/13/main/postgresql.conf
# shared_buffers = 256MB
# effective_cache_size = 1GB
# work_mem = 4MB

# Optimiser Redis
sudo nano /etc/redis/redis.conf
# maxmemory 512mb
# maxmemory-policy allkeys-lru
```

### 2. Monitoring

```bash
# Installer des outils de monitoring
sudo apt install -y htop iotop nethogs

# Configurer des alertes
# Utiliser Grafana + Prometheus pour les alertes
```

## 🔄 Mise à Jour

### 1. Mise à Jour du Code

```bash
# Sauvegarder
/usr/local/bin/learnia-backup.sh

# Mettre à jour
git pull origin main

# Redémarrer
sudo systemctl restart learnia-backend
```

### 2. Mise à Jour des Dépendances

```bash
# Backend
cd learnia-backend
source venv/bin/activate
pip install --upgrade -r requirements.txt

# Frontend
cd ../learnia
flutter pub upgrade
flutter build web
```

## 📞 Support

### 1. Informations de Débogage

```bash
# Collecter les informations
python3 validate_production.py > validation-report.txt
systemctl status learnia-backend > service-status.txt
journalctl -u learnia-backend > logs.txt
```

### 2. Contacts

- **Documentation** : [GitHub Wiki](https://github.com/your-org/learnia/wiki)
- **Issues** : [GitHub Issues](https://github.com/your-org/learnia/issues)
- **Support** : support@learnia.tg

---

## ✅ Checklist de Déploiement

- [ ] Serveur configuré avec les prérequis
- [ ] Variables d'environnement configurées
- [ ] Base de données créée et configurée
- [ ] Redis installé et configuré
- [ ] Nginx configuré avec SSL
- [ ] Services démarrés et fonctionnels
- [ ] Validation de production réussie
- [ ] Monitoring configuré
- [ ] Sauvegarde configurée
- [ ] Pare-feu configuré
- [ ] Tests de performance réussis
- [ ] Documentation mise à jour

**🎉 Félicitations ! Votre application Learnia est maintenant déployée en production !**
