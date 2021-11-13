#!/bin/bash

echo "chown -R www-data:www-data /var/www/html/storage"
chown -R www-data:www-data /var/www/html/storage
echo "chmod -R 755 /var/www/html/storage"
chmod -R 755 /var/www/html/storage

echo "start migrate script"

function mysql_exec {
  # тут проблема
 /usr/bin/mysql -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -e "$@" >&2
}

echo "start Waiting db ${DB_DATABASE}"

while true; do
  if mysql_exec "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${DB_DATABASE}'" > /dev/null; then
    break;
  fi
  echo "Waiting for mysql ${DB_DATABASE} loaded!"
  sleep 1;
done

echo "start Waiting file autoload.php"

while true; do
  if [ -f /var/www/html/vendor/autoload.php ]; then
    break;
  fi
  echo "Waiting for file autoload.php!"
  echo "start Waiting db ${DB_DATABASE}"
  sleep 1;
done

php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
php artisan migrate --force
php artisan db:seed

echo "finish"