COMPOSE := docker-compose
EXEC_PHP := docker exec -it laravel-php
EXEC_MYSQL := docker exec -it laravel-mysql
ARTISAN := $(EXEC_PHP) php artisan
COMPOSER := $(EXEC_PHP) composer

.DEFAULT_GOAL := help

.PHONY: help
help: ## 显示帮助信息
	@echo "可用的命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: install
install: ## 首次安装:启动容器并创建 Laravel 项目
	@echo "开始安装..."
	@$(MAKE) build
	@$(MAKE) up
	@echo "等待 MySQL 启动..."
	@sleep 15
	@$(MAKE) create-laravel
	@$(MAKE) permission
	@$(MAKE) key-generate
	@$(MAKE) migrate
	@echo "安装完成!"
	@echo "访问地址: http://localhost"

.PHONY: create-laravel
create-laravel: ## 创建 Laravel 项目
	@echo "创建 Laravel 项目..."
	@$(EXEC_PHP) composer create-project --prefer-dist laravel/laravel . --no-interaction

.PHONY: key-generate
key-generate: ## 生成应用密钥
	@echo "生成应用密钥..."
	@$(ARTISAN) key:generate

.PHONY: build
build: ## 构建镜像
	@echo "构建镜像..."
	@$(COMPOSE) build --no-cache

.PHONY: up
up: ## 启动所有容器
	@echo "启动容器..."
	@$(COMPOSE) up -d

.PHONY: down
down: ## 停止所有容器
	@echo "停止容器..."
	@$(COMPOSE) down

.PHONY: restart
restart: ## 重启所有容器
	@echo "重启容器..."
	@$(COMPOSE) restart

.PHONY: ps
ps: ## 查看容器状态
	@$(COMPOSE) ps

.PHONY: logs
logs: ## 查看所有日志
	@$(COMPOSE) logs -f

.PHONY: shell
shell: ## 进入 PHP 容器
	@$(EXEC_PHP) sh

.PHONY: mysql
mysql: ## 进入 MySQL
	@$(EXEC_MYSQL) mysql -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE)

.PHONY: redis
redis: ## 进入 Redis
	@docker exec -it laravel-redis redis-cli

.PHONY: composer
composer: ## 运行 Composer 命令 (用法: make composer cmd="require package/name")
	@$(COMPOSER) $(cmd)

.PHONY: composer-install
composer-install: ## 安装 Composer 依赖
	@$(COMPOSER) install

.PHONY: composer-update
composer-update: ## 更新 Composer 依赖
	@$(COMPOSER) update

.PHONY: composer-dump
composer-dump: ## 重新生成自动加载文件
	@$(COMPOSER) dump-autoload

.PHONY: npm
npm: ## 运行 NPM 命令 (用法: make npm cmd="install")
	@$(EXEC_PHP) npm $(cmd)

.PHONY: npm-install
npm-install: ## 安装 NPM 依赖
	@$(EXEC_PHP) npm install

.PHONY: npm-dev
npm-dev: ## 运行开发服务器
	@$(EXEC_PHP) npm run dev

.PHONY: npm-build
npm-build: ## 构建生产资源
	@$(EXEC_PHP) npm run build

.PHONY: artisan
artisan: ## 运行 Artisan 命令 (用法: make artisan cmd="route:list")
	@$(ARTISAN) $(cmd)

.PHONY: routes
routes: ## 显示路由列表
	@$(ARTISAN) route:list

.PHONY: cache-clear
cache-clear: ## 清除所有缓存
	@echo "清除缓存..."
	@$(ARTISAN) cache:clear
	@$(ARTISAN) config:clear
	@$(ARTISAN) route:clear
	@$(ARTISAN) view:clear
	@$(ARTISAN) config:cache
	@echo "缓存清除完成"

.PHONY: optimize
optimize: ## 优化应用性能
	@echo "优化应用..."
	@$(ARTISAN) config:cache
	@$(ARTISAN) route:cache
	@$(ARTISAN) view:cache
	@echo "优化完成"

.PHONY: migrate
migrate: ## 运行数据库迁移
	@$(ARTISAN) migrate

.PHONY: migrate-fresh
migrate-fresh: ## 删除所有表并重新迁移
	@$(ARTISAN) migrate:fresh

.PHONY: migrate-rollback
migrate-rollback: ## 回滚上一次迁移
	@$(ARTISAN) migrate:rollback

.PHONY: seed
seed: ## 运行数据库填充
	@$(ARTISAN) db:seed

.PHONY: fresh
fresh: ## 重置数据库(迁移+填充)
	@$(ARTISAN) migrate:fresh --seed

.PHONY: dump
dump: ## 备份数据库
	@$(EXEC_MYSQL) mysqldump -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) > dump_$$(date +%Y%m%d_%H%M%S).sql
	@echo "数据库备份完成"

.PHONY: import
import: ## 导入数据库 (用法: make import file=dump.sql)
	@$(EXEC_MYSQL) mysql -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < $(file)
	@echo "数据库导入完成"

.PHONY: test
test: ## 运行所有测试
	@$(ARTISAN) test

.PHONY: test-coverage
test-coverage: ## 运行测试并生成覆盖率报告
	@$(ARTISAN) test --coverage

.PHONY: test-unit
test-unit: ## 运行单元测试
	@$(ARTISAN) test --testsuite=Unit

.PHONY: test-feature
test-feature: ## 运行功能测试
	@$(ARTISAN) test --testsuite=Feature

.PHONY: queue-work
queue-work: ## 运行队列处理器
	@$(ARTISAN) queue:work

.PHONY: queue-listen
queue-listen: ## 监听队列
	@$(ARTISAN) queue:listen

.PHONY: permission
permission: fix-permission ## 修复文件权限
	@echo "修复权限..."
	@$(EXEC_PHP) chown -R www-data:www-data /var/www/html
	@$(EXEC_PHP) chmod -R 755 /var/www/html/storage
	@$(EXEC_PHP) chmod -R 755 /var/www/html/bootstrap/cache
	@echo "权限修复完成"

.PHONY: clean
clean: ## 清理 Docker 资源
	@echo "清理 Docker 资源..."
	@$(COMPOSE) down -v
	@docker system prune -f
	@echo "清理完成"

.PHONY: reset
reset: ## 完全重置项目(警告:会删除所有数据)
	@echo "警告:这将删除所有数据!"
	@read -p "确定要继续吗? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(MAKE) clean; \
		rm -rf src/*; \
		echo "重置完成"; \
	fi
