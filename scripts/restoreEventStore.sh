#!/bin/bash
#https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html
#https://www.postgresql.org/docs/13/libpq-envars.html

set -euo pipefail
set +f

export PGUSER=$EVENT_STORE_USERNAME
export PGPASSWORD=$EVENT_STORE_PASSWORD
export PGHOST=$EVENT_STORE_HOST
export PGPORT=$EVENT_STORE_PORT
export PGDATABASE=$EVENT_STORE_DB_NAME


PSQL_BIN=psql

echo "psql version" $($PSQL_BIN --version)

for f in "$LOCAL_ATTRIBUTE_REGISTRY_DUMPS"/*; do 
  echo "EventStore: restoring dump $f"
  $PSQL_BIN --set ON_ERROR_STOP=on < "$f"
done;

for f in "$LOCAL_TENANT_DUMPS"/*; do 
  echo "EventStore: restoring dump $f"
  $PSQL_BIN --set ON_ERROR_STOP=on < "$f"
done;
