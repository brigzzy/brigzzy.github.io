#!/bin/bash
cd /var/www/html
git fetch --all
git reset --hard origin/master
hugo
chown -R www-data:www-data /var/www/html
