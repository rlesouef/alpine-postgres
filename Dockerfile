FROM rlesouef/alpine-base
MAINTAINER Richard Lesouef <rlesouef@gmail.com>

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN apk --update add \
    curl \
    "postgresql@edge>9.4" && \
    rm -rf /var/cache/apk/*

RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-amd64" && \
	chmod +x /usr/local/bin/gosu

ENV LANG en_US.utf8
ENV PGDATA /var/lib/postgresql/data

COPY src/ .
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5432
VOLUME /var/lib/postgresql/data

CMD ["postgres"]
