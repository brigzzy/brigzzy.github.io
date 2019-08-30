#!/bin/bash
cd /var/www/html
git pull
chown -R www-data:www-data /var/www/html
