#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}==> $1${NC}"; }
warn() { echo -e "${YELLOW}==> $1${NC}"; }

# 1. 检查 .env
if [ ! -f .env ]; then
    log "复制 .env.example 到 .env"
    cp .env.example .env
fi

# 2. 加载环境变量（用于读取服务开关配置）
source .env 2>/dev/null || true

# 3. 构建
log "构建 Docker 镜像..."
docker-compose build --no-cache

# 4. 构建启动服务列表
log "准备启动服务..."
SERVICES=""

[ "${ENABLE_NGINX}" != "false" ] && SERVICES="$SERVICES nginx"
[ "${ENABLE_PHP}" != "false" ] && SERVICES="$SERVICES php"
[ "${ENABLE_MYSQL}" != "false" ] && SERVICES="$SERVICES mysql"
[ "${ENABLE_REDIS}" != "false" ] && SERVICES="$SERVICES redis"
[ "${ENABLE_PHPMYADMIN}" != "false" ] && SERVICES="$SERVICES phpmyadmin"

# 如果没有配置或全部启用，启动所有服务（默认行为）
if [ -z "$SERVICES" ]; then
    SERVICES="nginx php mysql redis phpmyadmin"
fi

log "启动服务: $SERVICES"
docker-compose up -d $SERVICES

# 5. 等待 MySQL（如果启用）
if [ "${ENABLE_MYSQL}" != "false" ]; then
    log "等待 MySQL 启动..."
    sleep 15
fi

# 6. 获取项目路径
PROJECT_PATH=${PROJECT_PATH:-./src}

# 7. 创建 Laravel 项目
if [ ! -d "$PROJECT_PATH/vendor" ]; then
    log "创建 Laravel 项目..."
    docker exec -it laravel-php composer create-project --prefer-dist laravel/laravel . --no-interaction
fi

# 8. 修复权限
log "修复文件权限..."
docker exec -it laravel-php chown -R www-data:www-data /var/www/html
docker exec -it laravel-php chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# 9. 生成密钥
log "生成应用密钥..."
docker exec -it laravel-php php artisan key:generate

# 10. 运行迁移（如果启用 MySQL）
if [ "${ENABLE_MYSQL}" != "false" ]; then
    log "运行数据库迁移..."
    docker exec -it laravel-php php artisan migrate
fi

# 11. 显示访问地址
HTTP_PORT=${NGINX_HTTP_PORT:-80}
HTTPS_PORT=${NGINX_HTTPS_PORT:-443}
PMA_PORT=${PHPMYADMIN_PORT:-8080}

echo ""
log "安装完成!"
echo "  - 应用地址: http://localhost${HTTP_PORT}"
[ "${ENABLE_PHPMYADMIN}" != "false" ] && echo "  - phpMyAdmin: http://localhost:${PMA_PORT}"
