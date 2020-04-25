FROM nginx:1.17 as nginx

RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf-orig

FROM php:7.2-fpm as php

# Set working directory
WORKDIR /var/www/covidledger

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/covidledger/

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    locales \
    zip \
    vim \
    unzip \
    git \
    curl \
    libcurl4-gnutls-dev \
    zlib1g-dev \
    libxml2-dev \
    libc-client-dev \
    libkrb5-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mysqli zip 
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install imap
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install

EXPOSE 9000
CMD ["php-fpm"]
