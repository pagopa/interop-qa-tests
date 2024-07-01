#!/bin/bash
#https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/PostgreSQL.Concepts.General.SSL.html
#https://www.postgresql.org/docs/13/libpq-envars.html

set -euo pipefail

export PGUSER=$EVENT_STORE_USERNAME
export PGPASSWORD=$EVENT_STORE_PASSWORD
export PGHOST=$EVENT_STORE_HOST
export PGPORT=$EVENT_STORE_PORT
export PGDATABASE=$EVENT_STORE_DB_NAME

PSQL_BIN=psql

echo "psql version" $($PSQL_BIN --version)

#Get schema list - ignore schemas without <ENV>_* prefix
SCHEMA_LIST=$($PSQL_BIN -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name LIKE '${K8S_NAMESPACE}\_%';" | grep -i "${K8S_NAMESPACE}_*")

for CURRENT_SCHEMA in $SCHEMA_LIST
do
    echo "Schema:" $CURRENT_SCHEMA

    #Get table names list - exclude flyway
    TABLE_LIST=$($PSQL_BIN -c "SELECT table_name FROM information_schema.tables WHERE table_schema = '$CURRENT_SCHEMA';" | grep -v -e "-" -e '^(.*)$' -e "flyway" -e "table_name")
    for TABLE_NAME in $TABLE_LIST
    do
        $PSQL_BIN -c "TRUNCATE TABLE \"$CURRENT_SCHEMA\".\"$TABLE_NAME\" CASCADE;"
        if [[ $? -eq 0 ]]; then
            echo "\t-" $TABLE_NAME "truncated"
        else
            echo "::error::Error -" $TABLE_NAME "truncate error"
            exit 1
        fi
    done
done
