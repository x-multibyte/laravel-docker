ARG PHP_VERSION=8.2
FROM php:${PHP_VERSION}-fpm-alpine

# Use the highly effective docker-php-extension-installer for multi-version support
# This script handles dependencies and configuration for PHP 5.5 to 8.x automatically
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG PHP_EXTENSIONS="pdo pdo_mysql mysqli mbstring exif pcntl bcmath opcache intl zip gd redis"
ARG PHP_TIMEZONE="Asia/Shanghai"

RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}

# Install build dependencies that might be needed for composer or system
RUN apk add --no-cache \
    git \
    curl \
    mysql-client \
    tzdata \
    unzip

# Set timezone
RUN cp /usr/share/zoneinfo/${PHP_TIMEZONE} /etc/localtime && \
    echo "${PHP_TIMEZONE}" > /etc/timezone

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY php.ini /usr/local/etc/php/conf.d/custom.ini

RUN chown -R www-data:www-data /var/www/html

USER www-data

EXPOSE 9000

CMD ["php-fpm"]