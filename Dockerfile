FROM ubuntu:14.04

# Define the OSM argument, use monaco as default
ARG DBHOST=localhost
ARG DBPORT=5432

RUN apt-get update

# Note: libgeos++-dev is included here too (the nominatim install page suggests installing it if there is a problem with the 'pear install DB' below - it seems safe to install it anyway)
RUN apt-get -y install build-essential gcc git osmosis  libxml2-dev libgeos-dev libpq-dev libbz2-dev libtool cmake libproj-dev proj-bin libgeos-c1 libgeos++-dev libexpat1-dev

# Install Boost (required by osm2pqsql)
RUN apt-get -y install autoconf make g++ libboost-dev libboost-system-dev libboost-filesystem-dev libboost-thread-dev lua5.2 liblua5.2-dev

# Install PHP5
RUN apt-get -y install php5 php-pear php5-pgsql php5-json php-db php5-intl

# From the website "If you plan to install the source from github, the following additional packages are needed:"
# RUN apt-get -y install git autoconf-archive

# Install Postgres, PostGIS and dependencies
RUN apt-get -y install postgresql postgis postgresql-contrib postgresql-9.3-postgis-2.1 postgresql-server-dev-9.3


# Install Apache
RUN apt-get -y install apache2

RUN apt-get  -y install sudo git

RUN pear install DB
RUN useradd -m -p password1234 nominatim
RUN mkdir -p /app/git/
RUN git clone --recursive https://github.com/youscan/Nominatim.git /app/git/
RUN mkdir -p /app/nominatim

WORKDIR /app/nominatim

RUN cmake /app/git/
RUN make

ADD local.php /app/nominatim/settings/local.php

WORKDIR /app/nominatim/settings

RUN sed -i.bak "s/pgsql:\/\/\@\/nominatim/pgsql:\/\/nominatim\@$DBHOST:$DBPORT\/nominatim/g" local.php

RUN cat local.php

WORKDIR /app/nominatim

RUN chown -R nominatim:nominatim /app/nominatim
RUN mkdir -p /var/www/nominatim
RUN cp -R /app/nominatim/website /var/www/nominatim/
RUN cp -R /app/nominatim/settings /var/www/nominatim/
RUN chown -R nominatim:www-data /var/www/nominatim

RUN apt-get install -y curl
ADD 400-nominatim.conf /etc/apache2/sites-available/400-nominatim.conf
RUN service apache2 start && \
  a2ensite 400-nominatim.conf && \
  /etc/init.d/apache2 reload

# Expose the HTTP port
EXPOSE 8080

WORKDIR /app/nominatim
ADD start.sh /app/nominatim/start.sh
RUN chmod +x /app/nominatim/start.sh

CMD /app/nominatim/start.sh
