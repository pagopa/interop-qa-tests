#!/bin/bash

set -euo pipefail
# mongodb://"${encodedAdminUser}":"${encodedAdminPassword}"@"$READ_MODEL_DB_HOST":"$READ_MODEL_DB_PORT"/admin
mongosh mongodb://"$READ_MODEL_USERNAME":"$READ_MODEL_PASSWORD"@"$READ_MODEL_HOST":"$READ_MODEL_PORT/${READ_MODEL_DB_NAME}" \
  --eval "var collections = db.getCollectionNames(); 
          for (let coll of collections) {
            db.getCollection(coll).deleteMany({});
          }
          exit;" 
