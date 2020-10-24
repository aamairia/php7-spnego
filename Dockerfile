#Apache version
FROM debian:jessie

MAINTAINER Aymen AMAIRIA <testmail@test.test>
USER root
WORKDIR /var/www/html/webapp

#Define ENV VARIABLES
ENV LOG_STDOUT FALSE
ENV LOG_STDERR FAlSE
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC
ENV TERM xterm
ENV DEBIAN_FRONTEND noninteractive

#Configuration
COPY docker-config/debconf.selections /tmp/
COPY docker-config/docker-script.sh /usr/bin/
COPY docker-config/virtualhost/virtualhost.sh /usr/bin/virtualhost
COPY docker-config/virtualhost/locale/fr/virtualhost.mo /usr/share/locale/fr/LC_MESSAGES/
COPY docker-config/virtualhost/ssl/server.crt /etc/apache2/ssl/server.crt
COPY docker-config/virtualhost/ssl/server.key /etc/apache2/ssl/server.key
# Install PHP XDEBUG configuration, (see https://blog.eleven-labs.com/fr/debugger-avec-xdebug/)
COPY docker-config/xdebug.ini /etc/php5/apache2/conf.d/
COPY docker-config/xdebug.ini /etc/php5/cli/conf.d/

RUN debconf-set-selections /tmp/debconf.selections

#Installation des packets
RUN apt-get update && apt-get -y upgrade && apt-get -y install
 	                                                            wget \
																apt-transport-https \
																ca-certificates \
																curl \
																lsb-release \
																ca-certificates \
																software-properties-common \
																gnupg \
																apache2 \
																vim \
																nano \
																zip \
																unzip \
																dos2unix \
																git \
																tree \
				                                                locales \
																libfontconfig1 \
																libxrender1 \
                                                                ftp \
#																sendmail \
#																sendmail-cf \
#																m4 \

RUN wget  https://packages.sury.org/php/apt.gpg
RUN mv apt.gpg /etc/apt/trusted.gpg.d/php.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.4.list

RUN apt-get update && apt-get -y upgrade && apt-get install -y \
    libapache2-mod-php7.4 \
	php7.4 \
	php7.4-cgi \
	php7.4-cli \
	php7.4-common \
	php7.4-curl \
	php7.4-dev \
	php7.4-enchant \
	php7.4-fpm \
	php7.4-gd \
	php7.4-gmp \
	php7.4-imap \
	php7.4-interbase \
	php7.4-intl \
	php7.4-json \
	php7.4-ldap \
	php7.4-mysql \
	php7.4-odbc \
	php7.4-pgsql \
	php7.4-phpdbg \
	php7.4-pspell \
	php7.4-readline \
	php7.4-recode \
	php7.4-sybase \
	php7.4-tidy \
	php7.4-xmlrpc \
	php7.4-xsl \
	php7.4-xdebug \
	php7.4-soap

#Ajout Authentification via Kerberos
RUN apt-get update && apt-get -y upgrade && apt-get -y install  krb5-kdc \
                                                                krb5-admin-server \
                                                                krb5-user \
                                                                libpam-krb5 \
#                                                                libkrb5-dev \
                                                                libpam-ccreds \
                                                                libapache2-mod-auth-kerb \
                                                                realmd \
                                                                heimdal-dev \
                                                                make

#RUN apt-get update && apt-get -y upgrade && apt-get -y install  krb5_newrealm

COPY docker-config/kerberos/krb5.conf /etc/krb5.conf
COPY docker-config/kerberos/krb5dev.keytab /etc/krb5.keytab

######### Nettoyer le gestionnaire de paquet
RUN apt-get autoclean && apt-get -y autoremove
#Composer
#RUN curl -sS https://getcomposer.org/installer | php
#RUN mv composer.phar /usr/local/bin/composer
##PHPUnit
#RUN wget https://phar.phpunit.de/phpunit-6.5.phar
#RUN chmod +x phpunit-6.5.phar
#RUN mv phpunit-6.5.phar /usr/local/bin/phpunit

RUN a2enmod rewrite
RUN a2enmod ssl
## Set LOCALE to UTF8
#
RUN echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen fr_FR.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chmod +x /usr/bin/docker-script.sh
RUN chmod +x /usr/bin/virtualhost
#RUN chmod +x /usr/local/bin/composer

RUN sed -i -e 's/\r$//' /usr/bin/docker-script.sh
RUN sed -i -e 's/\r$//' /usr/bin/virtualhost
RUN export TERM=xterm
RUN chmod -R 777 /var/www/html/
RUN chown -R www-data:www-data /var/www/html/

#POSTFIX
#    RUN groupadd -g 124 postfix && \
#        groupadd -g 125 postdrop && \
#    useradd -u 116 -g 124 postfix
#
#    RUN apt-get update && \
#      DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
#        postfix \
#        bsd-mailx
#
#    CMD echo test aymen mail | mail testmail@test.test

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/docker-script.sh"]
CMD ["true"]