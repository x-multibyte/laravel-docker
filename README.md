# Laravel Docker Starter

一个开箱即用的 Laravel + LNMP Docker 开发环境，包含 Nginx、PHP、MySQL 8.0、Redis 和 phpMyAdmin。
支持 Laravel 5.5 (LTS) 到最新版本 (11.x+)。

## 功能特性

- **一键安装**: `install.sh` 自动完成环境构建和 Laravel 初始化。
- **多版本支持**: 支持 Laravel 5.5, 6.x, 7.x, 8.x, 9.x, 10.x, 11.x。
- **便捷指令**: 内置 `./artisan` 和 `./composer` 包装脚本，无需进入容器。
- **完整栈**: Nginx, PHP (多版本), MySQL 8.0, Redis, phpMyAdmin。
- **自动配置**: 自动修改 Laravel `.env` 以适配 Docker 环境。

## 快速开始

### 1. 启动环境

```bash
# 1. 复制配置
cp .env.example .env

# 2. (可选) 修改 Laravel 和 PHP 版本
# 打开 .env 文件，修改 LARAVEL_VERSION 和 PHP_VERSION
# 默认安装最新版 Laravel (需 PHP 8.2)

# 3. 执行安装脚本
./install.sh
```

脚本将自动执行以下操作：
1. 构建 Docker 镜像（根据配置的 PHP 版本）。
2. 启动服务容器。
3. 创建 Laravel 项目（指定版本）。
4. 自动配置数据库连接 (MySQL) 和 Redis。
5. 修复权限并运行迁移。
6. 创建便捷指令软连接。

### 2. 访问应用

- **Web 应用**: http://localhost (或你在 .env 配置的端口)
- **phpMyAdmin**: http://localhost:8080

## 版本对照表

在 `.env` 中修改 `LARAVEL_VERSION` 和 `PHP_VERSION`：

| Laravel 版本 | 推荐 PHP 版本 | 设置示例 |
|--------------|--------------|---------|
| Latest (11.x)| 8.2+         | `LARAVEL_VERSION=latest` <br> `PHP_VERSION=8.2` |
| 10.x         | 8.1 - 8.3    | `LARAVEL_VERSION=10.*` <br> `PHP_VERSION=8.2` |
| 9.x (LTS)    | 8.0 - 8.2    | `LARAVEL_VERSION=9.*` <br> `PHP_VERSION=8.1` |
| 8.x          | 7.3 - 8.1    | `LARAVEL_VERSION=8.*` <br> `PHP_VERSION=8.0` |
| 7.x          | 7.2 - 8.0    | `LARAVEL_VERSION=7.*` <br> `PHP_VERSION=7.4` |
| 6.x (LTS)    | 7.2 - 8.0    | `LARAVEL_VERSION=6.*` <br> `PHP_VERSION=7.4` |
| 5.5 (LTS)    | 7.0 - 7.3    | `LARAVEL_VERSION=5.5.*` <br> `PHP_VERSION=7.1` |

> **注意**: 修改 PHP 版本后，必须运行 `./install.sh` 或 `docker-compose build` 重新构建镜像。

## 常用命令

安装完成后，你可以在项目根目录直接使用以下命令：

### Artisan

```bash
./artisan list
./artisan make:controller UserController
./artisan migrate
```

### Composer

```bash
./composer install
./composer require laravel/sanctum
```

### 容器管理

```bash
docker-compose up -d    # 启动
docker-compose down     # 停止
docker-compose logs -f  # 查看日志
```

## 配置说明

### 端口配置 (.env)

如果本地端口被占用，请修改 `.env` 文件：

```bash
NGINX_HTTP_PORT=8081
MYSQL_PORT=3307
REDIS_PORT=6380
PHPMYADMIN_PORT=8082
```

修改后需要重启容器：`docker-compose up -d`

## 项目结构

```
.
├── docker-artisan      # artisan 包装脚本
├── docker-composer     # composer 包装脚本
├── docker-compose.yml
├── install.sh          # 安装脚本
├── src/                # Laravel 源代码目录
└── docker/             # Docker 配置目录
```

## License

MIT
