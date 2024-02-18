#!/bin/bash

set -e

# If the DEBUG variable exists, the commands and their arguments will be displayed as they are executed.
[ -n "${DEBUG:-}" ] && set -x

export PSQL=${PSQL:-"psql -v ON_ERROR_STOP=1 -U $POSTGRES_USER -d $POSTGRES_DB"}
export POSTGIS_VERSION="${POSTGIS_VERSION%%+*}"

# Load PostGIS into both template_database and $POSTGRES_DB
for DB in template_postgis "$POSTGRES_DB"; do
echo "Updating PostGIS extensions '$DB' to $POSTGIS_VERSION"

$PSQL <<-EOSQL
-- Upgrade PostGIS (includes raster)
CREATE EXTENSION IF NOT EXISTS postgis VERSION '$POSTGIS_VERSION';
ALTER EXTENSION postgis  UPDATE TO '$POSTGIS_VERSION';

-- Upgrade Topology
CREATE EXTENSION IF NOT EXISTS postgis_topology VERSION '$POSTGIS_VERSION';
ALTER EXTENSION postgis_topology UPDATE TO '$POSTGIS_VERSION';

-- Upgrade US Tiger Geocoder
CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder VERSION '$POSTGIS_VERSION';
ALTER EXTENSION postgis_tiger_geocoder UPDATE TO '$POSTGIS_VERSION';
EOSQL
done