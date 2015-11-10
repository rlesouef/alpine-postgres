# alpine-postgres
[![](https://badge.imagelayers.io/rlesouef/alpine-nginx:latest.svg)](https://imagelayers.io/?images=rlesouef/alpine-nginx:latest 'Get your own badge on imagelayers.io')

## PostgreSQL docker image based on Alpine Linux

This repo builds a docker image that accepts the same env vars as the [official postgres build](https://registry.hub.docker.com/_/postgres/) but with a much smaller footprint.

## How to use this image start a postgres instance

```bash
$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d rlesouef/alpine-postgres
```

This image includes EXPOSE 5432 (the postgres port), so standard container linking will make it automatically available to the linked containers. The default postgres user and database are created in the entrypoint with initdb.

>The postgres database is a default database meant for use by users, utilities and third party applications.
postgresql.org/docs

connect to it from an application

```bash
$ docker run --name some-app --link some-postgres:postgres -d application-that-uses-postgres
```

... or via psql

```bash
$ docker run -it --link some-postgres:postgres --rm postgres sh -c 'exec psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres'
```

### Environment Variables

The PostgreSQL image uses several environment variables which are easy to miss. While none of the variables are required, they may significantly aid you in using the image.

__POSTGRES_PASSWORD__

This environment variable is recommended for you to use the PostgreSQL image. This environment variable sets the superuser password for PostgreSQL. The default superuser is defined by the `POSTGRES_USER` environment variable. In the above example, it is being set to "mysecretpassword".

__POSTGRES_USER__

This optional environment variable is used in conjunction with `POSTGRES_PASSWORD` to set a user and its password. This variable will create the specified user with superuser power and a database with the same name. If it is not specified, then the default user of `postgres` will be used.

__PGDATA__

This optional environment variable can be used to define another location - like a subdirectory - for the database files. The default is `/var/lib/postgresql/data`, but if the data volume you're using is a fs mountpoint (like with GCE persistent disks), Postgres initdb recommends a subdirectory (for example `/var/lib/postgresql/data/pgdata` ) be created to contain the data.
How to extend this image

If you would like to do additional initialization in an image derived from this one, add one or more `*.sql` or `*.sh` scripts under `/docker-entrypoint-initdb.d` (creating the directory if necessary). After the entrypoint calls `initdb` to create the default postgres user and database, it will run any *.sql files and source any *.sh scripts found in that directory to do further initialization before starting the service.

These initialization files will be executed in sorted name order as defined by the current locale, which defaults to `en_US.utf8`. Any `*.sql` files will be executed by POSTGRES_USER, which defaults to the `postgres` superuser. It is recommended that any `psql` commands that are run inside of a `*.sh` script be executed as `POSTGRES_USER` by using the `--username "$POSTGRES_USER"` flag. This user will be able to connect without a password due to the presence of `trust` authentication for Unix socket connections made inside the container.

You can also extend the image with a simple Dockerfile to set a different locale. The following example will set the default locale to de_DE.utf8:

```bash
FROM rlesouef/alpine-postgres
RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8
ENV LANG de_DE.utf8
```

Since database initialization only happens on container startup, this allows us to set the language before it is created.
Caveats

If there is no database when postgres starts in a container, then postgres will create the default database for you. While this is the expected behavior of postgres, this means that it will not accept incoming connections during that time. This may cause issues when using automation tools, such as fig, that start several containers simultaneously.
