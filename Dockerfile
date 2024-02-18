FROM postgres:16

ARG MAINTAINER=${MAINTAINER:-rbruno}
ARG POSTGRES_DB=${POSTGRES_DB:-postgres}
ARG TZ=${TZ:-UTC}

LABEL maintainer="${MAINTAINER}" \
        org.opencontainers.image.authors="${MAINTAINER}" \
        org.opencontainers.image.source="https://github.com/robertbruno/postgres-docker-image" \
        org.opencontainers.image.vendor="robertbruno" \
        org.opencontainers.image.title="postgres-docker-image" \
        org.opencontainers.image.description="Simple Postgres Docker with postgis,python,pgcron"

ENV POSTGRES_VERSION 16
ENV POSTGIS_VERSION 3
ENV PG_CRON_VERSION=1.6.2
ENV POSTGRES_PORT=${POSTGRES_PORT:-5432}
ENV SHARED_PRELOAD_LIBRARIES=${SHARED_PRELOAD_LIBRARIES:-"pg_cron.so"}
ENV TZ=${TZ:-UTC}

RUN apt-get update\
      && apt-get install -y make gcc postgresql-$POSTGRES_VERSION-postgis-$POSTGIS_VERSION \
      postgresql-$POSTGRES_VERSION-postgis-$POSTGIS_VERSION-scripts \
      postgresql-server-dev-$POSTGRES_VERSION \
      postgresql-${POSTGRES_VERSION}-cron \
      postgresql-plperl-${POSTGRES_VERSION} postgresql-pltcl-${POSTGRES_VERSION}\
      libwww-perl postgresql-$POSTGRES_VERSION-cron \
      postgresql-contrib-${POSTGRES_VERSION} \
      libpq-dev \
      build-essential wget \
      postgresql-${POSTGRES_VERSION}-repack \
      postgresql-plpython3-14 \
      tzdata \
      libmagic1 \
      python3-googleapi \
      python3-google-auth \
      python3-requests \
      pip

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Set timezone
RUN ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && echo "${TZ}" > /etc/timezone

# compile pgqr
# https://github.com/AbdulYadi/pgqr
WORKDIR /usr/local/pgqr
COPY extensions/pgqr .
RUN  make && make install

# compile pg-safeupdate
# https://github.com/eradman/pg-safeupdate
WORKDIR /usr/local/pg-safeupdate
COPY extensions/pg-safeupdate .
RUN  gmake && gmake install

# add wait-for-sh
# https://github.com/vishnubob/wait-for-it
COPY scripts/wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# init scripts
RUN mkdir -p /docker-entrypoint-initdb.d
COPY scripts/initdb.sh /docker-entrypoint-initdb.d/initdb.sh
COPY scripts/update-postgis.sh /usr/local/bin

# clean
RUN apt remove -y make gcc build-essential postgresql-server-dev-$POSTGRES_VERSION wget\
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && rm -rf /usr/local/pg_amqp 

EXPOSE ${POSTGRES_PORT}

WORKDIR /home/$USER
