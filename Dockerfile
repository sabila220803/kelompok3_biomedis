# --- PERUBAHAN UTAMA: GANTI BASE IMAGE KE "BOOKWORM" (STABIL) ---
# Ini akan otomatis memberi kita Python 3.11 (bukan 3.13)
FROM php:8.2-apache-bookworm

# 1. Install System Dependencies & Library AI Wajib
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    supervisor \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libgl1 \
    libglib2.0-0 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# 2. Setup Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# 3. Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 4. Copy & Setup Laravel
WORKDIR /var/www/html
COPY web-app/ .  
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 5. Copy & Setup Python AI
WORKDIR /var/www/ai
COPY ai-service/ .

# --- KUNCI VERSI LIBRARY AGAR TIDAK BENTROK ---
# Kita install numpy lama & protobuf lama yang disukai MediaPipe
RUN pip3 install --break-system-packages \
    flask \
    pandas \
    scikit-learn \
    "numpy<2" \
    "protobuf<4" \
    "opencv-python-headless<4.10" \
    mediapipe

# 6. Copy Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 7. Expose Port
EXPOSE 80

# 8. Start
CMD ["/usr/bin/supervisord"]