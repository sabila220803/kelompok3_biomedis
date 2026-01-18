# Multi-stage build untuk aplikasi Laravel + AI Service
FROM php:8.2-apache

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    supervisor \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    libopencv-dev \
    python3-opencv \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pdo_sqlite mbstring exif pcntl bcmath gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache modules
RUN a2enmod rewrite headers

# Configure Apache
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf && \
    sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/c\<Directory /var/www/html/public>\n    Options Indexes FollowSymLinks\n    AllowOverride All\n    Require all granted\n</Directory>' /etc/apache2/apache2.conf

# Copy web-app files
COPY web-app/ /var/www/html/

# Set proper permissions for Laravel
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Install PHP dependencies
WORKDIR /var/www/html
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Copy .env file
RUN cp .env.example .env || true

# Generate application key
RUN php artisan key:generate

# Create SQLite database
RUN touch database/database.sqlite && \
    chown www-data:www-data database/database.sqlite

# Run migrations
RUN php artisan migrate --force || true

# Install Node.js dependencies and build assets
RUN npm install && npm run build

# Install Python dependencies for AI service
WORKDIR /var/www
COPY ai-service/ /var/www/ai/

RUN pip3 install --no-cache-dir --break-system-packages \
    flask \
    opencv-python \
    mediapipe \
    numpy

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create log directories
RUN mkdir -p /var/log/apache2 /var/log/supervisor && \
    chown -R www-data:www-data /var/log/apache2

# Expose port 80 (frontend)
EXPOSE 80

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
