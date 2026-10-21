FROM dunglas/frankenphp:1.13.1-php8.4 AS frankenphp

WORKDIR /app
COPY --from=composer /usr/bin/composer /usr/local/bin/composer
RUN install-php-extensions \
    zip \
    pcntl
RUN apt update && apt install -y supervisor
COPY . /app

COPY docker/Caddyfile /etc/caddy/Caddyfile
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/run /app/run

RUN composer install --no-interaction --no-dev --optimize-autoloader --classmap-authoritative
RUN touch /app/storage/logs/laravel.log
RUN chmod -R 777 /app/storage /app/bootstrap/cache

EXPOSE 80
CMD ["/app/run"]
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD curl -f http://localhost/health || exit 1
