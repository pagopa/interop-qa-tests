#!/usr/bin/env bash

# Script to remove all items from a DynamoDB table using parallel scans and batch deletes.
#
# Usage:
#   ./purge-dynamodb-tables.sh <table> [--region REGION] [--parallelism N]
#
# Options:
#   --region         AWS region to target (default: eu-south-1)
#   --parallelism    Number of parallel segments to scan (default: 4)

# Stop on any error, on use of uninitialized variable, or if any part of a pipeline fails
set -euo pipefail

# Name of the DynamoDB table to purge
TBL="$1"; shift || true

# Default configuration values
REGION="eu-south-1"
PARALLELISM=4
BATCH=25  # Always fixed to 25

# Parse command-line arguments to override defaults
while [[ $# -gt 0 ]]; do
  case "$1" in
    --region)
      REGION="$2"
      shift 2
      ;;
    --parallelism)
      PARALLELISM="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# Region for AWS CLI configuration
AWS_ARGS=(--region "$REGION")

# The partition key is fixed to "PK"; retrieve optional sort key if defined
KEYS_JSON=$(aws dynamodb describe-table \
  --table-name "$TBL" "${AWS_ARGS[@]}" \
  --query "Table.KeySchema" --output json)
HASH="PK"
RANGE=$(echo "$KEYS_JSON" | jq -r '.[] | select(.KeyType=="RANGE") .AttributeName // empty')

echo "Table: $TBL  PK=$HASH  RangeKey=${RANGE:-<none>}  Parallelism=$PARALLELISM  Batch=$BATCH"

# Function to scan a table segment and delete items in batches
process_segment() {
  local SEG_ID="$1"
  local TOKEN="INIT"

  # Continue scanning until no more pages are returned
  while [[ "$TOKEN" != "null" ]]; do
    # First scan call without pagination token
    if [[ "$TOKEN" == "INIT" ]]; then
      PAGE=$(aws dynamodb scan \
               --table-name "$TBL" "${AWS_ARGS[@]}" \
               --segment "$SEG_ID" --total-segments "$PARALLELISM" --output json)
    else
      # Subsequent scans include the LastEvaluatedKey for pagination
      PAGE=$(aws dynamodb scan \
               --table-name "$TBL" "${AWS_ARGS[@]}" \
               --segment "$SEG_ID" --total-segments "$PARALLELISM" \
               --exclusive-start-key "$TOKEN" --output json)
    fi

    # Extract only the key attributes from each item to prepare delete requests
    KEYS=$(echo "$PAGE" | jq -c --arg h "$HASH" --arg r "$RANGE" '
      .Items | map(
        if $r == "" then { ($h): .[$h] }
        else                  { ($h): .[$h], ($r): .[$r] } end
      )')
    LEN=$(echo "$KEYS" | jq 'length')

    echo "Segment $SEG_ID: preparing to delete $LEN items"

    # Divide into fixed-size batches and issue batch-write-item calls
    for ((i=0; i<LEN; i+=BATCH)); do
      CHUNK=$(echo "$KEYS" | jq -c ".[$i:$((i+BATCH))]")
      REQ=$(echo "$CHUNK" | jq -c '[ .[] | { DeleteRequest: { Key: . } } ]')
      aws dynamodb batch-write-item "${AWS_ARGS[@]}" \
           --request-items "{\"$TBL\": $REQ}" >/dev/null
    done

    # Update TOKEN; if null, scanning is complete for this segment
    TOKEN=$(echo "$PAGE" | jq -c '.LastEvaluatedKey // null')
  done

  echo "Segment $SEG_ID completed"
}

# Launch parallel deletion jobs for each segment
pids=()
for ((id=0; id<PARALLELISM; id++)); do
  process_segment "$id" &
  pids+=("$!")
done

# Wait for all background jobs to finish
for pid in "${pids[@]}"; do
  wait "$pid"
done

echo "PURGE complete!"