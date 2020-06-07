# All-in-one TinyTinyRSS image
A all-in-one docker image for TinyTinyRSS based on Alpine 3.12 x64 and integrating Apache, PHP7 and MariaDB.
Inspired by https://hub.docker.com/r/wangqiru/ttrss

## List of plugins included 
- tinytinyrss-fever-plugin
- mercury_fulltext
- ttrss_plugin-feediron
- ttrss_opencc
- tt-rss-newsplus-plugin
- FeedReader
- options_per_feed
- ttrss-plugin-remove-iframe-sandbox

## Themes included
- tt-rss-feedly-theme
- ttrss-theme-rsshu

## Installation
Example :

    docker create --name tinytinyrss \
        -v /path/to/data/mysql:/var/lib/mysql \
        -e TIMEZONE=Europe/Paris \
        -e DB_NAME=ttrss \
        -e DB_USER=ttrss \
        -e DB_PASSWD=ttrss \
        -p 80:80 \
        --restart always \
    docker start tinytinyrss


## Update 
Example :

    docker pull diakweb/docker-tinytinyrss
    docker stop tinytinyrss
    docker rm tinytinyrss
    docker create --name tinytinyrss \
        -v /path/to/data/mysql:/var/lib/mysql \
        -e TIMEZONE=Europe/Paris \
        -e DB_NAME=ttrss \
        -e DB_USER=ttrss \
        -e DB_PASSWD=ttrss \
        -p 80:80 \
        --restart always \
    docker start tinytinyrss

