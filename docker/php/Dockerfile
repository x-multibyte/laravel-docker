ARG PHP_VERSION=8.2

# =================================================================================================
# Stage 1: Run (Production Runtime)
# Contains only the minimal requirements to run the PHP application.
# =================================================================================================
FROM php:${PHP_VERSION}-fpm-alpine AS run

# Use the highly effective docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

ARG PHP_EXTENSIONS="pdo pdo_mysql mysqli mbstring exif pcntl bcmath opcache intl zip gd redis"
ARG PHP_TIMEZONE="Asia/Shanghai"

# Install PHP extensions and system dependencies
# install-php-extensions handles build deps automatically and removes them afterwards.
# We explicitly add runtime dependencies if needed, though most are handled by the extensions.
RUN chmod +x /usr/local/bin/install-php-extensions && \
    install-php-extensions ${PHP_EXTENSIONS}

RUN apk add --no-cache \
    mysql-client \
    tzdata \
    icu-libs \
    libzip \
    libpng \
    libjpeg-turbo \
    freetype

# Set timezone
RUN cp /usr/share/zoneinfo/${PHP_TIMEZONE} /etc/localtime && \
    echo "${PHP_TIMEZONE}" > /etc/timezone

WORKDIR /var/www/html

COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Ensure correct permissions
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

# =================================================================================================
# Stage 2: Development (Default Target)
# Adds tools needed for development (Composer, Git, etc.)
# =================================================================================================
FROM run AS dev

# Install development tools
RUN apk add --no-cache \
    git \
    curl \
    unzip \
    openssh-client \
    linux-headers

# Install Composer (Only needed in Dev/Build stage, or if you run composer in prod)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

USER www-data

CMD ["php-fpm"]
