FROM public.ecr.aws/docker/library/php:8.2-apache

# 必要なPHP拡張モジュール
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libzip-dev \
    libpng-dev \
    default-mysql-client \
    && docker-php-ext-install pdo pdo_mysql zip bcmath

# Apacheのmod_rewrite有効化
RUN a2enmod rewrite

# Composerのインストール
COPY --from=public.ecr.aws/docker/library/composer:latest /usr/bin/composer /usr/bin/composer

# 作業ディレクトリ
WORKDIR /var/www/html

# Laravelのソースをコンテナにコピー
COPY ./laravel-nagoyameshi /var/www/html/laravel-nagoyameshi

# Laravel初期設定
WORKDIR /var/www/html/laravel-nagoyameshi

RUN composer install --no-dev --optimize-autoloader \
 && php artisan config:clear \
 && php artisan cache:clear \
 && php artisan view:clear

# Apache用にDocumentRootをpublicに変更
RUN sed -i 's|/var/www/html|/var/www/html/laravel-nagoyameshi/public|g' /etc/apache2/sites-available/000-default.conf

# パーミッション修正（正しいパスに変更）
RUN chown -R www-data:www-data storage bootstrap/cache

# ポート公開
EXPOSE 80

# 起動
CMD ["apache2-foreground"]
