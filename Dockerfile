FROM alpine:3.15

ENV TIMEZONE Europe/Paris
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASSWD ttrss

RUN apk update && apk upgrade
RUN apk add --no-cache bash \
    mariadb \
    mariadb-client \
    apache2 \ 
    apache2-utils \
    curl \
    tzdata \
    tar \
    gzip \
    git \
    sudo \
    php7-apache2 \
    php7-cli \
    php7-phar \
    php7-zlib \
    php7-zip \
    php7-bz2 \
    php7-ctype \
    php7-curl \
    php7-pdo_mysql \
    php7-mysqli \
    php7-json \
    php7-mcrypt \
    php7-xml \
    php7-dom \
    php7-iconv \
    php7-xdebug \
    php7-session \
    php7-intl \
    php7-gd \
    php7-mbstring \
    php7-apcu \
    php7-opcache \
    php7-tokenizer \
    php7-fpm \
    php7-fileinfo \
    php7-pcntl \
    php7-posix 

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer

RUN rm -rf https://git.tt-rss.org/fox/tt-rss.git /var/www/localhost/htdocs/* && \
    git clone https://git.tt-rss.org/fox/tt-rss.git /var/www/localhost/htdocs

# Download plugins
## Fever
ADD https://github.com/HenryQW/tinytinyrss-fever-plugin/archive/master.tar.gz /var/www/localhost/htdocs/plugins/fever/
## Mercury Fulltext
ADD https://github.com/HenryQW/mercury_fulltext/archive/master.tar.gz /var/www/localhost/htdocs/plugins/mercury_fulltext/
## Feediron
ADD https://github.com/feediron/ttrss_plugin-feediron/archive/master.tar.gz /var/www/localhost/htdocs/plugins/feediron/
## OpenCC
ADD https://github.com/HenryQW/ttrss_opencc/archive/master.tar.gz /var/www/localhost/htdocs/plugins/opencc/
## News+ API
ADD https://github.com/voidstern/tt-rss-newsplus-plugin/archive/master.tar.gz /var/www/localhost/htdocs/plugins/api_newsplus/
## FeedReader API
ADD https://raw.githubusercontent.com/jangernert/FeedReader/master/data/tt-rss-feedreader-plugin/api_feedreader/init.php /var/www/localhost/htdocs/plugins/api_feedreader/
## Options per feed
ADD https://github.com/sergey-dryabzhinsky/options_per_feed/archive/master.tar.gz /var/www/localhost/htdocs/plugins/options_per_feed/
## Remove iframe sandbox
ADD https://github.com/DIYgod/ttrss-plugin-remove-iframe-sandbox/archive/master.tar.gz /var/www/localhost/htdocs/plugins/remove_iframe_sandbox/
## Wallabag
ADD https://github.com/joshp23/ttrss-to-wallabag-v2/archive/master.tar.gz /var/www/localhost/htdocs/plugins/wallabag_v2/

# Download themes
## Feedly
ADD https://github.com/levito/tt-rss-feedly-theme/archive/master.tar.gz /var/www/localhost/htdocs/themes.local/feedly.tar.gz
## RSSHub
ADD https://github.com/DIYgod/ttrss-theme-rsshub/archive/master.tar.gz /var/www/localhost/htdocs/themes.local/rsshub.tar.gz

# Untar ttrss plugins
RUN tar xzvpf /var/www/localhost/htdocs/plugins/fever/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/fever tinytinyrss-fever-plugin-master && rm /var/www/localhost/htdocs/plugins/fever/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/mercury_fulltext/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/mercury_fulltext/ mercury_fulltext-master && rm /var/www/localhost/htdocs/plugins/mercury_fulltext/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/feediron/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/feediron/ ttrss_plugin-feediron-master && rm /var/www/localhost/htdocs/plugins/feediron/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/opencc/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/opencc/ ttrss_opencc-master && rm /var/www/localhost/htdocs/plugins/opencc/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/api_newsplus/master.tar.gz --strip-components=2 -C /var/www/localhost/htdocs/plugins/api_newsplus tt-rss-newsplus-plugin-master/api_newsplus && rm /var/www/localhost/htdocs/plugins/api_newsplus/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/options_per_feed/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/options_per_feed options_per_feed-master && rm /var/www/localhost/htdocs/plugins/options_per_feed/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/remove_iframe_sandbox/master.tar.gz --strip-components=1 -C /var/www/localhost/htdocs/plugins/remove_iframe_sandbox ttrss-plugin-remove-iframe-sandbox-master && rm /var/www/localhost/htdocs/plugins/remove_iframe_sandbox/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/plugins/wallabag_v2/master.tar.gz --strip-components=2 -C /var/www/localhost/htdocs/plugins/wallabag_v2 ttrss-to-wallabag-v2-master/wallabag_v2 && rm /var/www/localhost/htdocs/plugins/wallabag_v2/master.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/themes.local/feedly.tar.gz --strip-components=1 --wildcards -C /var/www/localhost/htdocs/themes.local/ tt-rss-feedly-theme-master/feedly tt-rss-feedly-theme-master/feedly*.css && rm -rf /var/www/localhost/htdocs/themes.local/feedly.tar.gz && \
    tar xzvpf /var/www/localhost/htdocs/themes.local/rsshub.tar.gz --strip-components=2 -C /var/www/localhost/htdocs/themes.local/ ttrss-theme-rsshub-master/dist/rsshub.css && rm -rf /var/www/localhost/htdocs/themes.local/rsshub.tar.gz 

# configure mysql, apache
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mkdir -p /run/apache2 && chown -R apache:apache /run/apache2 && chown -R apache:apache /var/www/localhost/htdocs/ && \
    sed -i 's#\#LoadModule rewrite_module modules\/mod_rewrite.so#LoadModule rewrite_module modules\/mod_rewrite.so#' /etc/apache2/httpd.conf && \
    sed -i 's#ServerName www.example.com:80#\nServerName localhost:80#' /etc/apache2/httpd.conf && \
    sed -i 's/skip-networking/\#skip-networking/i' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a log_error = \/var\/lib\/mysql\/error.log' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i '/mariadb\]/a skip-external-locking' /etc/my.cnf.d/mariadb-server.cnf 

RUN sed -i 's#display_errors = Off#display_errors = On#' /etc/php7/php.ini && \
    sed -i 's#upload_max_filesize = 2M#upload_max_filesize = 100M#' /etc/php7/php.ini && \
    sed -i 's#post_max_size = 8M#post_max_size = 100M#' /etc/php7/php.ini && \
    sed -i 's#session.cookie_httponly =#session.cookie_httponly = true#' /etc/php7/php.ini && \
    sed -i 's#error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT#error_reporting = E_ALL#' /etc/php7/php.ini


# Configure xdebug
#RUN echo "zend_extension=xdebug.so" > /etc/php7/conf.d/xdebug.ini && \ 
#    echo -e "\n[XDEBUG]"  >> /etc/php7/conf.d/xdebug.ini && \ 
#    echo "xdebug.remote_enable=1" >> /etc/php7/conf.d/xdebug.ini && \  
#    echo "xdebug.remote_connect_back=1" >> /etc/php7/conf.d/xdebug.ini && \ 
#    echo "xdebug.idekey=PHPSTORM" >> /etc/php7/conf.d/xdebug.ini && \ 
#    echo "xdebug.remote_log=\"/tmp/xdebug.log\"" >> /etc/php7/conf.d/xdebug.ini

# Copy entrypoint
COPY entry.sh /entry.sh
RUN chmod u+x /entry.sh

# Copy cron job to update RSS feeds
COPY cron-ttrss /etc/periodic/15min/ttrss
RUN chmod u+x /etc/periodic/15min/ttrss

# Copy cron job to update TTRSS every hour
COPY cron-update-ttrss /etc/periodic/hourly/ttrss-update
RUN chmod u+x /etc/periodic/hourly/ttrss-update

WORKDIR /var/www/localhost/htdocs/
VOLUME /var/lib/mysql

EXPOSE 80

ENTRYPOINT ["/entry.sh"]
