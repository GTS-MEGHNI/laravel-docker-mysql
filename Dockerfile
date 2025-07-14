# -------- Stage 1: Build stage --------
FROM php:8.4-fpm-alpine AS build

# Install build dependencies and required libraries
RUN apk add --no-cache --virtual .build-deps \
        gcc g++ make autoconf freetype-dev libjpeg-turbo-dev libpng-dev oniguruma-dev gettext-dev libzip-dev bash less unzip curl zip \
    && apk add --no-cache freetype libjpeg-turbo libpng oniguruma gettext

# Install PHP extensions
RUN docker-php-ext-configure zip \
    && docker-php-ext-install zip pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-install bcmath exif gettext opcache \
    && docker-php-ext-enable bcmath exif gettext opcache

# Install PHP extensions via install-php-extensions helper
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
RUN install-php-extensions intl redis pcntl

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app source code
COPY . .

# Add Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install PHP dependencies (no-dev, optimized)
RUN composer install --no-dev --optimize-autoloader

# Laravel performance optimizations
RUN php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    php artisan storage:link

# Remove build dependencies to reduce image size
RUN apk del .build-deps

# -------- Stage 2: Production runtime stage --------
FROM php:8.4-fpm-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    freetype \
    libjpeg-turbo \
    libpng \
    oniguruma \
    gettext \
    bash \
    libzip \
    icu-libs \
    lz4-libs \
    libc6-compat

# Set working directory
WORKDIR /var/www/html

# Copy PHP config and extensions from build stage
COPY --from=build /usr/local/etc/php /usr/local/etc/php
COPY --from=build /usr/local/lib/php/extensions /usr/local/lib/php/extensions

# Copy Laravel app from build stage
COPY --from=build /var/www/html /var/www/html

# Set file permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm", "-F"]