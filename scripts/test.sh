
set -e

# If the DEBUG variable exists, the commands and their arguments will be displayed as they are executed.
[ -n "${DEBUG:-}" ] && set -x

if [[ -z "$RUN_TEST" ]]; then
    echo "skiping tests."
    exit 0
fi

export PSQL=${PSQL:-"psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB"}

echo "Run tests..."

$PSQL <<-EOSQL
    SELECT NOW();
    
    SELECT version();
    
    SELECT ST_IsSimple(ST_GeomFromText('POLYGON((1 2, 3 4, 5 6, 1 2))'));
    
    CREATE SCHEMA my_schema;

    CREATE TABLE my_schema.my_spatial_table (id serial);

    SELECT AddGeometryColumn ('my_schema','my_spatial_table','geom',4326,'POINT',2);
EOSQL

# reatart db
pg_ctl -D $PGDATA stop

