# postgres-docker-image

General purpose postgresql docker image with some preloaded extensions.

It is based on the [official postgres image](https://hub.docker.com/_/postgres/) so the same characteristics apply.

The main features of this image are:

* **[postgis](https://postgis.net/)** extends the capabilities of the PostgreSQL relational database by adding support for storing, indexing, and querying geospatial data.

* **[plperl](https://www.postgresql.org/docs/current/plperl.html)** PL/Perl is a loadable procedural language that enables you to write PostgreSQL functions and procedures in the Perl programming language.The following modules [libwww-perl](https://metacpan.org/dist/libwww-perl) and [API::Google](https://metacpan.org/pod/API::Google) come pre-installed.

* **[plpython3u](https://www.postgresql.org/docs/current/plpython.html)**  The PL/Python procedural language allows PostgreSQL functions and procedures to be written in the Python language.

> **Security Considerations:** PL/Python is considered an untrusted language in PostgreSQL because Python code executed through it can access the host machine's file system. There is no built-in mechanism to restrict this access, so caution should be used when using PL/Python functions.

* **[pg-safeupdate](https://github.com/eradman/pg-safeupdate)** is a simple PostgreSQL extension that generates an error if UPDATE and DELETE are executed without specifying conditions (WHERE). This extension was initially designed to protect data from accidentally deleting data that PostgREST can write to.

* **[wait-for-it.sh](https://github.com/vishnubob/wait-for-it)** is a pure bash script that will wait on the availability of a host and TCP port

## Build

This section indicates the steps to build the postgres image based on [Dockerfile](Dockerfile), where **postgresql-docker-image** is the name of the image to be generated and **latest** is the tag. The necessary requirements to build the image are:

* **docker**

For the latest version use the default dockerfile.

```bash
# clone local repo
git clone https://github.com/robertbruno/postgres-docker-image

# We enter the root of the project.
cd postgres-docker-image

# we execute the image build
docker build -t postgres-docker-image -f Dockerfile .
```

### Use

You can use the images already published:

```bash
mkdir -p ~/docker/volume/postgres && \
    docker run --name db -p 5432:5432 \
    -v ~/docker/volume/postgres:/var/lib/postgresql/data \
    robertbruno/postgres-docker-image:latest
```

> It is important that you define a volume for the server data otherwise you will lose the changes when the container execution ends.

You can indicate different connection information

```bash
mkdir -p ~/docker/volume/postgres && \
    docker run --name db -p 5432:5432 \
    -v ~/docker/volume/postgres:/var/lib/postgresql/data \
    -e POSTGRES_USER=my_user \
    -e POSTGRES_DB=my_database \
    -e POSTGRES_PASSWORD=my_password \
    robertbruno/postgres-docker-image:latest
```

### Backup

You will need to run the following command and replace the necessary values:
```bash
 docker exec -t < container id > \
 pg_dump  --port 5432   --username my_user_name \
 --no-password --format plain --encoding UTF8 \
  dbname  >  backup_postgresql_`date +%d-%m-%Y"_"%H_%M_%S`.sql
```

### Restore

Having a backup in sql format, you can run it in your container by running the following command and replacing the necessary values:
```bash
cat ~/restore.sql  | docker exec -i < container id > psql > -U < user > -d < database >
```
> PaFor more information visit:
>
> * [Postgres docker](https://hub.docker.com/_/postgres)
