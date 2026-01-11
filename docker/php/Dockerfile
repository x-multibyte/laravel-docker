ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm-alpine

ARG PHP_EXTENSIONS="pdo pdo_mysql mysqli mbstring exif pcntl bcmath opcache intl zip gd redis"
ARG PHP_TIMEZONE="Asia/Shanghai"

RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    oniguruma-dev \
    libzip-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    icu-dev \
    mysql-client \
    tzdata \
    $PHPIZE_DEPS

# 设置时区
RUN cp /usr/share/zoneinfo/${PHP_TIMEZONE} /etc/localtime && \
    echo "${PHP_TIMEZONE}" > /etc/timezone

# 配置 GD 扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg || true

# 动态安装 PHP 扩展
RUN if [ -n "$PHP_EXTENSIONS" ]; then \
        for ext in $(echo "$PHP_EXTENSIONS" | tr ' ' '\n' | grep -v '^$'); do \
            case "$ext" in \
                redis|pcov) \
                    pecl install $ext && docker-php-ext-enable $ext || echo "Warning: Failed to install $ext" \
                    ;; \
                *) \
                    docker-php-ext-install -j$(nproc) $ext || echo "Warning: Failed to install $ext" \
                    ;; \
            esac \
        done \
    fi

# 清理构建依赖
RUN apk del .build-deps 2>/dev/null || true

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY php.ini /usr/local/etc/php/conf.d/custom.ini

RUN chown -R www-data:www-data /var/www/html

USER www-data

EXPOSE 9000

CMD ["php-fpm"]
