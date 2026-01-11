#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}==> $1${NC}"; }
warn() { echo -e "${YELLOW}==> $1${NC}"; }

# Determine execution flags
if [ -t 0 ]; then
    EXEC_FLAGS="-it"
else
    EXEC_FLAGS="-i"
fi

# 1. Check .env
if [ ! -f .env ]; then
    log "复制 .env.example 到 .env"
    cp .env.example .env
fi

# 2. Load environment variables
set -a
source .env 2>/dev/null || true
set +a

# 3. Build
log "构建 Docker 镜像..."
docker-compose build --no-cache

# 4. Prepare services
log "准备启动服务..."
SERVICES=""

[ "${ENABLE_NGINX}" != "false" ] && SERVICES="$SERVICES nginx"
[ "${ENABLE_PHP}" != "false" ] && SERVICES="$SERVICES php"
[ "${ENABLE_MYSQL}" != "false" ] && SERVICES="$SERVICES mysql"
[ "${ENABLE_REDIS}" != "false" ] && SERVICES="$SERVICES redis"
[ "${ENABLE_PHPMYADMIN}" != "false" ] && SERVICES="$SERVICES phpmyadmin"

if [ -z "$SERVICES" ]; then
    SERVICES="nginx php mysql redis phpmyadmin"
fi

log "启动服务: $SERVICES"
docker-compose up -d $SERVICES

# 5. Wait for MySQL
if [ "${ENABLE_MYSQL}" != "false" ]; then
    log "等待 MySQL 启动..."
    sleep 15
fi

# 6. Project Path
PROJECT_PATH=${PROJECT_PATH:-./src}

# 7. Create Laravel Project
if [ ! -d "$PROJECT_PATH/vendor" ]; then
    log "创建 Laravel 项目..."
    docker exec $EXEC_FLAGS laravel-php composer create-project --prefer-dist laravel/laravel . --no-interaction
    
    # Configure DB in Laravel .env if newly created
    if [ -f "$PROJECT_PATH/.env" ]; then
        log "配置 Laravel 数据库连接..."
        # Replace DB_CONNECTION=sqlite with mysql
        sed -i '' 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g' "$PROJECT_PATH/.env"
        # Uncomment and set DB host/port
        sed -i '' 's/# DB_HOST=127.0.0.1/DB_HOST=mysql/g' "$PROJECT_PATH/.env"
        sed -i '' 's/# DB_PORT=3306/DB_PORT=3306/g' "$PROJECT_PATH/.env"
        sed -i '' 's/# DB_DATABASE=laravel/DB_DATABASE=laravel/g' "$PROJECT_PATH/.env"
        sed -i '' 's/# DB_USERNAME=root/DB_USERNAME=laravel/g' "$PROJECT_PATH/.env"
        sed -i '' 's/# DB_PASSWORD=/DB_PASSWORD=secret/g' "$PROJECT_PATH/.env"
        # Set Redis Host
        sed -i '' 's/REDIS_HOST=127.0.0.1/REDIS_HOST=redis/g' "$PROJECT_PATH/.env"
    fi
fi

# 8. Fix Permissions
log "修复文件权限..."
# Use root to chown
docker exec -u root $EXEC_FLAGS laravel-php chown -R www-data:www-data /var/www/html
docker exec $EXEC_FLAGS laravel-php chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Generate Key
log "生成应用密钥..."
docker exec $EXEC_FLAGS laravel-php php artisan key:generate

# 10. Run Migrations
if [ "${ENABLE_MYSQL}" != "false" ]; then
    log "运行数据库迁移..."
    docker exec $EXEC_FLAGS laravel-php php artisan migrate --force
fi

# 11. Setup Helper Scripts
log "配置便捷指令..."
chmod +x docker-artisan docker-composer
if [ ! -L "artisan" ]; then
    ln -s docker-artisan artisan
    log "  - 已创建 ./artisan"
fi
if [ ! -L "composer" ]; then
    ln -s docker-composer composer
    log "  - 已创建 ./composer"
fi

# 12. Show Info
HTTP_PORT=${NGINX_HTTP_PORT:-80}
HTTPS_PORT=${NGINX_HTTPS_PORT:-443}
PMA_PORT=${PHPMYADMIN_PORT:-8080}

echo ""
log "安装完成!"
echo "  - 应用地址: http://localhost:${HTTP_PORT}"
[ "${ENABLE_PHPMYADMIN}" != "false" ] && echo "  - phpMyAdmin: http://localhost:${PMA_PORT}"
echo "  - Artisan: ./artisan"
echo "  - Composer: ./composer"