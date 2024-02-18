
set -e

# If the DEBUG variable exists, the commands and their arguments will be displayed as they are executed.
[ -n "${DEBUG:-}" ] && set -x

export SHARED_PRELOAD_LIBRARIES=${SHARED_PRELOAD_LIBRARIES:-"pg_cron.so"}
export PSQL=${PSQL:-"psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB"}

echo "Settings \$SHARED_PRELOAD_LIBRARIES [$SHARED_PRELOAD_LIBRARIES]..."
printf "\nshared_preload_libraries = '$SHARED_PRELOAD_LIBRARIES'" >> $PGDATA/postgresql.conf

echo "Setting [cron.database_name=$POSTGRES_DB]..."
printf "\ncron.database_name = '$POSTGRES_DB'" >> $PGDATA/postgresql.conf

# reatart db
pg_ctl -D $PGDATA restart -mf

# validate standby native mode
if [[ "$PG_REPLICATION_MODE" == "standby" ]]; then
echo "skiping db initialization, native standby mode is defined."
exit 0
fi

# validate standby repmgr mode
if [[ "$REPMGR_MODE" == "standby" ]]; then
echo "skiping db initialization, repmgr standby mode is defined."
exit 0
fi

# Perform all actions as $POSTGRES_USER
export PGUSER="$POSTGRES_USER"

echo "Setting postgis extensions..."
$PSQL <<-EOSQL
    CREATE DATABASE template_postgis;
	UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'template_postgis';
EOSQL

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
echo "Loading PostGIS extensions into $DB"
$PSQL <<-EOSQL
    CREATE EXTENSION IF NOT EXISTS postgis;
	CREATE EXTENSION IF NOT EXISTS postgis_topology;
	CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
	CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder;
EOSQL
done

echo "Setting [udp_send]..."
$PSQL -f /usr/local/pg_udp_send/udp_send.sql
