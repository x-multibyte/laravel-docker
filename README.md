# Laravel Docker 开发环境

一个完整的 Laravel + LNMP Docker 开发环境，包含 Nginx、PHP 8.2、MySQL 8.0、Redis 和 phpMyAdmin。

## 技术栈

| 服务 | 版本 | 说明 |
|------|------|------|
| Nginx | Alpine | Web 服务器 |
| PHP | 8.2-FPM | 应用服务器 |
| MySQL | 8.0 | 数据库 |
| Redis | Alpine | 缓存/队列 |
| phpMyAdmin | Latest | 数据库管理工具 |
| Composer | Latest | PHP 依赖管理 |

## 系统要求

- Docker >= 20.10
- Docker Compose >= 2.0
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

## 快速开始

### 1. 配置环境变量

```bash
cp .env.example .env
# 根据需要修改 .env 文件
```

### 2. 启动环境

```bash
./install.sh
```

这将自动完成以下操作：
- 构建 Docker 镜像
- 启动所有容器
- 创建 Laravel 项目
- 配置文件权限
- 生成应用密钥
- 运行数据库迁移

### 3. 访问应用

- **应用**: http://localhost
- **phpMyAdmin**: http://localhost:8080

## 常用命令

### 容器管理

```bash
docker-compose up -d          # 启动容器
docker-compose down           # 停止容器
docker-compose restart        # 重启容器
docker-compose ps             # 查看容器状态
docker-compose logs -f        # 查看日志
```

### 进入容器

```bash
docker exec -it laravel-php sh                    # 进入 PHP 容器
docker exec -it laravel-mysql mysql -ularavel -psecret laravel  # 进入 MySQL
docker exec -it laravel-redis redis-cli           # 进入 Redis
```

### Composer 命令

```bash
docker exec -it laravel-php composer install                 # 安装依赖
docker exec -it laravel-php composer require package/name   # 添加包
docker exec -it laravel-php composer update                 # 更新依赖
```

### Artisan 命令

```bash
docker exec -it laravel-php php artisan migrate         # 运行迁移
docker exec -it laravel-php php artisan migrate:fresh --seed  # 重置数据库
docker exec -it laravel-php php artisan cache:clear     # 清除缓存
docker exec -it laravel-php php artisan route:list      # 查看路由
docker exec -it laravel-php php artisan make:model User # 自定义命令
```

### NPM 命令

```bash
docker exec -it laravel-php npm install                 # 安装依赖
docker exec -it laravel-php npm run dev                 # 开发构建
docker exec -it laravel-php npm run build               # 生产构建
```

### 数据库操作

```bash
docker exec -it laravel-php php artisan migrate         # 运行迁移
docker exec -it laravel-php php artisan db:seed         # 运行填充
docker exec -it laravel-php php artisan migrate:fresh --seed  # 重置数据库
docker exec -it laravel-mysql mysqldump -ularavel -psecret laravel > dump.sql  # 备份
docker exec -i laravel-mysql mysql -ularavel -psecret laravel < dump.sql       # 导入
```

### 测试

```bash
docker exec -it laravel-php php artisan test           # 运行所有测试
docker exec -it laravel-php php artisan test --testsuite=Unit     # 单元测试
docker exec -it laravel-php php artisan test --testsuite=Feature # 功能测试
```

## 项目结构

```
laravel-docker/
├── docker/
│   ├── nginx/
│   │   ├── Dockerfile
│   │   └── conf.d/
│   │       └── default.conf
│   ├── php/
│   │   ├── Dockerfile
│   │   └── php.ini
│   └── mysql/
│       └── my.cnf
├── src/                    # Laravel 项目目录
├── docker-compose.yml
├── .env.example
├── .gitignore
├── install.sh              # 初始化安装脚本
└── README.md
```

## 配置说明

### 环境变量

主要配置项：

```bash
# 数据库配置
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret
DB_ROOT_PASSWORD=root

# Redis 配置
REDIS_HOST=redis
REDIS_PORT=6379

# 缓存配置
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
```

### PHP 配置

- 内存限制: 512M
- 上传文件大小: 100M
- 最大执行时间: 300秒
- 时区: Asia/Shanghai
- OPcache: 已启用

### MySQL 配置

- 字符集: utf8mb4
- 默认时区: +08:00
- 慢查询日志: 已启用
- 查询时间阈值: 2秒

### Nginx 配置

- 静态资源缓存: 30天
- 客户端上传限制: 100M
- 隐藏敏感文件: 已配置

## 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker-compose logs -f

# 检查端口占用
lsof -i :80
lsof -i :3306
```

### 权限问题

```bash
docker exec -it laravel-php chown -R www-data:www-data /var/www/html
docker exec -it laravel-php chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache
```

### 数据库连接失败

```bash
# 检查 MySQL 是否就绪
docker exec laravel-mysql mysql -u laravel -psecret -e "SHOW DATABASES;"
```

### 清除所有缓存

```bash
docker exec -it laravel-php php artisan cache:clear
docker exec -it laravel-php php artisan config:clear
docker exec -it laravel-php php artisan route:clear
docker exec -it laravel-php php artisan view:clear
```

### 完全重置

```bash
docker-compose down -v
docker system prune -f
rm -rf src/*
./install.sh
```

## 安全注意事项

**重要提示**:

1. 生产环境使用前，请修改所有默认密码
2. 不要将 `.env` 文件提交到版本控制
3. 定期更新 Docker 镜像
4. 启用 HTTPS(生产环境)
5. 配置防火墙规则

## 性能优化

### OPcache 配置

PHP OPcache 已启用并优化：

- 内存: 256M
- 最大文件数: 10000
- 重新验证频率: 2秒

### MySQL 优化

- InnoDB 缓冲池: 512M
- 查询缓存: 已配置
- 慢查询日志: 已启用

### Redis 持久化

- AOF 模式: 已启用
- 数据卷: 已配置

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

---

Happy Coding!
