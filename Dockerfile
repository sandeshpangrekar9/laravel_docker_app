FROM php:8.3-apache

# set your user name, ex: user=carlos
ARG user=sdp
ARG uid=1000

# Install required PHP extensions and utilities
RUN apt-get update \
    && apt-get install -y \
        curl \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libzip-dev \
        libxml2-dev \
        zip \
        unzip \
        git \
        nano \
        vim \
        openssl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        gd \
        pdo \
        pdo_mysql \
        mbstring \
        xml \
        opcache \
        zip \
    && a2enmod rewrite \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]

USER $user