FROM alpine:3.9.4
MAINTAINER brigzzy <brigzzy@gmail.com>
RUN apk update && \
apk upgrade && \
apk add apache2 apache2-ssl git openssh openssl && \
mkdir /var/www/html && \
chown -R apache.www-data /var/www/html && \
rm -rf /var/cache/apk/* && \
mkdir /root/.ssh && \
ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts


COPY ssl.conf /etc/apache2/conf.d
COPY httpd.conf /etc/apache2
COPY id_ed25519 /root/.ssh/
COPY id_ed25519.pub /root/.ssh/

RUN chmod -R 0600 /root/.ssh/

EXPOSE 80 443

RUN git clone git@bitbucket.org:brigzzy/blog.git /var/www/html/ && \
chown -R apache:www-data /var/www/html
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
