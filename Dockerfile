FROM ubuntu

RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -q -y install nodejs-legacy nodejs-dev npm build-essential php5 libapache2-mod-php5 php5-mcrypt php5-mysql php5-json php5-curl php5-cli git curl git-core

ENV NODE_ENV="production" \
    PHP_VERSION="system"

RUN php5enmod mcrypt
RUN a2enmod rewrite
RUN mkdir -p /app
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY . /app/
WORKDIR /app
RUN rm /etc/apache2/sites-available/000-default.conf \
    && touch /etc/apache2/sites-available/000-default.conf \
    && echo '      <VirtualHost *:80>\n          DocumentRoot /app/public\n          <Directory /app/public>\n              Options -Indexes +FollowSymLinks +MultiViews\n              AllowOverride All\n              Require all granted\n          </Directory>\n          ErrorLog ${APACHE_LOG_DIR}/error.log\n          LogLevel warn\n          CustomLog ${APACHE_LOG_DIR}/access.log combined\n      </VirtualHost>' > /etc/apache2/sites-available/000-default.conf
RUN npm install -g bower && npm install bower
RUN rm -rf ./node_modules \
    && npm install --production
RUN echo '{ "allow_root": true }' > ~/.bowerrc \
    && bower install --config.interactive=false
RUN composer install --prefer-source --no-interaction --no-dev
RUN chown -R www-data:www-data /app

EXPOSE 80
