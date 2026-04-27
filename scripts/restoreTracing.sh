#!/bin/bash
#https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html
#https://www.postgresql.org/docs/13/libpq-envars.html

set -euo pipefail
set +f

PSQL_BIN=psql

echo "psql version" $($PSQL_BIN --version)

for f in "$LOCAL_TRACING_DUMPS"/*; do
  echo "Tracing: restoring dump $f"
  $PSQL_BIN --set ON_ERROR_STOP=on < "$f"
done;
