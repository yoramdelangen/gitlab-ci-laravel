FROM php:7.3

MAINTAINER Mark Wienk <mark@wienk.nl>
MAINTAINER Yoram de Langen <yoram@brandcube.nl>

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    gnupg \
    openssh-client \
    git-core \
    mysql-client \
    libbz2-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libxslt1-dev \
    libxml2-dev \
    libgd2-xpm-dev \
    cmake make \
    nasm g++ gcc \
    automake autogen autoconf libtool intltool \
    jq \
    &&  rm -r /var/lib/apt/lists/*

ENV YARN_VERSION=latest

# Install NodeJS, NPM and
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -yqq npm
RUN npm install -g yarn gulp

# PHP Extensions (curl, mbstring, hash, simplexml, xml, json, iconv are already installed in php image)
RUN docker-php-ext-configure \
    gd --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
    gd \
    bz2 \
    intl \
    mcrypt \
    pdo_mysql \
    pcntl \
    soap \
    xsl \
    zip \
    bcmath

# PHP Configuration
RUN echo "memory_limit=-1" > $PHP_INI_DIR/conf.d/memory-limit.ini
RUN echo "date.timezone=Europe/Amsterdam" > $PHP_INI_DIR/conf.d/date_timezone.ini

VOLUME /root/composer

# Environmental Variables
ENV COMPOSER_HOME /root/composer
ENV COMPOSER_CACHE_DIR /cache
ENV PATH /root/.composer/vendor/bin:$PATH

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
	composer selfupdate

# Install composer parallel downloads
RUN composer global require "hirak/prestissimo:^0.3"

# Goto temporary directory.
WORKDIR /tmp

RUN echo ">>>PHP:\n$(php --version)\n\n>>>COMPOSER:\n$(composer --version)\n\n>>>NODE:\n$(node -v)\n\n>>>YARN:\n$(yarn -v)"

RUN jq --version
