#!/bin/bash

set -euo pipefail

mongosh -u $READ_MODEL_USERNAME -p $READ_MODEL_PASSWORD --host $READ_MODEL_HOST --port $READ_MODEL_PORT $READ_MODEL_DB_NAME \
  --eval "var collections = db.getCollectionNames(); 
          for (let coll of collections) {
            db.getCollection(coll).deleteMany({});
          }" 
