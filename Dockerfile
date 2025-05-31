# ใช้ PHP 8.2 + Apache
FROM php:8.2-apache

# เปิด mod_rewrite สำหรับ Laravel routes
RUN a2enmod rewrite

# ติดตั้ง system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip

# ติดตั้ง Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ตั้ง working directory
WORKDIR /var/www/html

# คัดลอกไฟล์ Laravel เข้ามาใน container
COPY . .

# ติดตั้ง Composer dependencies
RUN composer install --no-dev --optimize-autoloader

# ให้ Laravel รันจาก public/
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# ตั้ง environment variable
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# เปลี่ยน Apache doc root เป็น /public
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

EXPOSE 80
CMD ["apache2-foreground"]
