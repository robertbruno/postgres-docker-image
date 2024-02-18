# postgres-docker-image

Este repositorio contiene los recursos necesarios para la creacion de una imagen docker de postgresql para propositos generales. 

La imagen esta basada en la [oficial de postgres](https://hub.docker.com/_/postgres/) por lo que aplican las mismas caracteristicas.

Las características principales de esta imagen son:

* **[postgis](https://postgis.net/)** PostGIS es una extensión de la base de datos PostgreSQL que agrega capacidades espaciales , convirtiendo a PostgreSQL en una base de datos espacial.

* **plperl** PL/Perl es un lenguaje de procedimientos cargable que le permite escribir funciones y procedimientos de PostgreSQL en el lenguaje de programación Perl. Vienen pre-instalado los siguiente modulos [libwww-perl](https://metacpan.org/dist/libwww-perl) y [API::Google](https://metacpan.org/pod/API::Google)

* **[plpython3u](https://www.postgresql.org/docs/current/plpython.html)**  Es una extensión en PostgreSQL que le permite escribir funciones y procedimientos en Python. Puede que le interese leer sobre: [Python 2 vs. Python 3](https://www.postgresql.org/docs/9.2/plpython-python23.html)

  En migraciones de postgres inferiores a 14 debe crear esta extension de la siguiente forma:
  ```sql
  CREATE EXTENSION plpython3u;
  ```

  > **Consideraciones de seguridad:** PL/Python se considera un lenguaje no confiable en PostgreSQL porque el código Python ejecutado a través de él puede acceder al sistema de archivos de la máquina host. No existe ningún mecanismo incorporado para restringir este acceso, por lo que se debe tener precaución al utilizar funciones de PL/Python.

* **[pg-safeupdate](https://github.com/eradman/pg-safeupdate)** es una extensión simple de PostgreSQL que genera un error si se ejecutan UPDATE y DELETE sin especificar condiciones (WHERE). Esta extensión se diseñó inicialmente para proteger los datos de la eliminación accidental de datos en los que PostgREST puede escribir.

## Build

Esta seccion indica los pasos para construir la imagen de postgres en base al [Dockerfile](Dockerfile), donde **postgresql-docker-image** es el nombre de la imagen a generar y **latest** es la tag. Los requerimientos necesarios para construir la imagen son:

* **docker**

Para la última versión use el dockerfile por defecto.

```bash
# clone local del repositorio
git clone https://github.com/robertbruno/postgres-docker-image

# ingresamos a la raíz del proyecto.
cd postgres-docker-image

# ejecutamos el buil de la imagenes
docker build -t postgres-docker-image -f Dockerfile .
```

### Use

Puede hacer uso de las imágenes ya publicadas:

```bash
mkdir -p ~/docker/volume/postgres && \
    docker run --name db -p 5432:5432 \
    -v ~/docker/volume/postgres:/var/lib/postgresql/data \
    robertbruno/postgres-docker-image:latest
```

> Es importante que defina un volumen para la data del servidor de lo contrario perdera los cambios al terminar la ejecucióń del contenedor.

Puede indicar datos de conexion diferentes

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

Deberá ejecutar el siguiente comando y reemplazar los valores necesarios:

```bash
 docker exec -t container_id \
 pg_dump  --port 5432   --username my_user_name \
 --no-password --format plain --encoding UTF8 \
  dbname  >  backup_postgresql_`date +%d-%m-%Y"_"%H_%M_%S`.sql
```

### Restore

Teniendo un respaldo en formato sql, puede ejecutarlo en su contenedor  ejecutando el siguiente comando y reeplazando los valores necesarios:

```bash
cat ~/restore.sql  | docker exec -i container_id psql > -U < user > -d < database >
```
> Para mayor información  visite:
>
> * [Postgres docker](https://hub.docker.com/_/postgres)
