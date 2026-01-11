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

# 2. 构建
log "构建 Docker 镜像..."
docker-compose build --no-cache

# 3. 启动
log "启动容器..."
docker-compose up -d

# 4. 等待 MySQL
log "等待 MySQL 启动..."
sleep 15

# 5. 创建 Laravel 项目
if [ ! -d src/vendor ]; then
    log "创建 Laravel 项目..."
    docker exec -it laravel-php composer create-project --prefer-dist laravel/laravel . --no-interaction
fi

# 6. 修复权限
log "修复文件权限..."
docker exec -it laravel-php chown -R www-data:www-data /var/www/html
docker exec -it laravel-php chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# 7. 生成密钥
log "生成应用密钥..."
docker exec -it laravel-php php artisan key:generate

# 8. 运行迁移
log "运行数据库迁移..."
docker exec -it laravel-php php artisan migrate

echo ""
log "安装完成! 访问地址: http://localhost"
