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
make install
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
make up          # 启动容器
make down        # 停止容器
make restart     # 重启容器
make ps          # 查看容器状态
make logs        # 查看日志
```

### 进入容器

```bash
make shell       # 进入 PHP 容器
make mysql       # 进入 MySQL
make redis       # 进入 Redis
```

### Composer 命令

```bash
make composer-install      # 安装依赖
make composer cmd="require laravel/ui"    # 添加包
make composer-update       # 更新依赖
```

### Artisan 命令

```bash
make migrate              # 运行迁移
make fresh                # 重置数据库
make cache-clear          # 清除缓存
make routes               # 查看路由
make artisan cmd="make:model User"    # 自定义命令
```

### 数据库操作

```bash
make migrate              # 运行迁移
make seed                 # 运行填充
make fresh                # 重置数据库
make dump                 # 备份数据库
make import file=dump.sql # 导入数据库
```

### 测试

```bash
make test                 # 运行所有测试
make test-unit            # 运行单元测试
make test-feature         # 运行功能测试
make test-coverage        # 生成覆盖率报告
```

### 其他

```bash
make permission           # 修复权限
make clean                # 清理 Docker 资源
make reset                # 完全重置项目
```

查看所有可用命令：

```bash
make help
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
├── Makefile
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
make permission
```

### 数据库连接失败

```bash
# 检查 MySQL 是否就绪
docker exec laravel-mysql mysql -u laravel -psecret -e "SHOW DATABASES;"
```

### 清除所有缓存

```bash
make cache-clear
```

### 完全重置

```bash
make reset
make install
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
