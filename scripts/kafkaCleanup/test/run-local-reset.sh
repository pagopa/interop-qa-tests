#!/usr/bin/env sh
set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SCRIPTS_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

KAFKA_BROKERS="${KAFKA_BROKERS:-localhost:9092}"
DOMAIN_TOPIC_PREFIX="${DOMAIN_TOPIC_PREFIX:-test.queue}"
DOMAIN_TOPIC_EXCLUDE="${DOMAIN_TOPIC_EXCLUDE:-}"
DEBEZIUM_OFFSETS_TOPIC="${DEBEZIUM_OFFSETS_TOPIC:-}"
QUIET_MODE="${QUIET_MODE:-0}"
KAFKA_CLIENT_ID="${KAFKA_CLIENT_ID:-kafka-reset-topics-client}"
KAFKA_READY_TIMEOUT_SECONDS="${KAFKA_READY_TIMEOUT_SECONDS:-120}"
DATA_PREP_READY_TIMEOUT_SECONDS="${DATA_PREP_READY_TIMEOUT_SECONDS:-90}"
RESET_KAFKA="${RESET_KAFKA:-0}"
DATA_PREP_PID=""
DATA_PREP_LOG="${SCRIPT_DIR}/.local-data-preparation.log"

require_command() {
  command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}" >&2
    exit 1
  fi
}

wait_for_kafka() {
  elapsed=0
  step=3

  while [ "${elapsed}" -lt "${KAFKA_READY_TIMEOUT_SECONDS}" ]; do
    if docker compose -f "${SCRIPT_DIR}/docker-compose.yml" exec -T kafka bash -lc "/opt/bitnami/kafka/bin/kafka-topics.sh --bootstrap-server localhost:9092 --list >/dev/null 2>&1"; then
      echo "Kafka is ready."
      return 0
    fi

    sleep "${step}"
    elapsed=$(( elapsed + step ))
  done

  echo "Kafka not ready after ${KAFKA_READY_TIMEOUT_SECONDS}s." >&2
  return 1
}

wait_for_data_preparation_ready() {
  elapsed=0
  step=2

  while [ "${elapsed}" -lt "${DATA_PREP_READY_TIMEOUT_SECONDS}" ]; do
    if grep -q "All consumer groups received the produced messages." "${DATA_PREP_LOG}"; then
      echo "Data preparation is ready."
      return 0
    fi

    if [ -n "${DATA_PREP_PID}" ] && ! kill -0 "${DATA_PREP_PID}" >/dev/null 2>&1; then
      echo "Data preparation process exited unexpectedly." >&2
      echo "--- Data preparation log ---" >&2
      cat "${DATA_PREP_LOG}" >&2 || true
      return 1
    fi

    sleep "${step}"
    elapsed=$(( elapsed + step ))
  done

  echo "Data preparation not ready after ${DATA_PREP_READY_TIMEOUT_SECONDS}s." >&2
  echo "--- Data preparation log ---" >&2
  cat "${DATA_PREP_LOG}" >&2 || true
  return 1
}

cleanup_data_preparation() {
  if [ -n "${DATA_PREP_PID}" ] && kill -0 "${DATA_PREP_PID}" >/dev/null 2>&1; then
    echo "Stopping background data preparation process (PID=${DATA_PREP_PID})..."
    kill "${DATA_PREP_PID}" >/dev/null 2>&1 || true
    wait "${DATA_PREP_PID}" >/dev/null 2>&1 || true
  fi
}

run() {
  require_command docker
  require_command pnpm

  if [ "${RESET_KAFKA}" -eq 1 ]; then
    echo "Resetting local Kafka data volumes..."
    docker compose -f "${SCRIPT_DIR}/docker-compose.yml" down -v --remove-orphans
    sleep 10
  fi

  echo "Starting local Kafka with docker compose..."
  docker compose -f "${SCRIPT_DIR}/docker-compose.yml" up -d

  echo "Waiting for Kafka health..."
  wait_for_kafka

  #trap cleanup_data_preparation 0

  echo "Starting local Kafka data preparation in background..."
  #: > "${DATA_PREP_LOG}"
  (
    cd "${SCRIPTS_DIR}"
    KAFKA_BROKERS="${KAFKA_BROKERS}" \
    DESTROY_CONSUMERS=true \
    DESTROY_PRODUCER=true \
    KAFKA_AUTH_MODE=none \
    DOMAIN_TOPIC_PREFIX="${DOMAIN_TOPIC_PREFIX}" \
    DOMAIN_TOPIC_EXCLUDE="${DOMAIN_TOPIC_EXCLUDE}" \
    DEBEZIUM_OFFSETS_TOPIC="${DEBEZIUM_OFFSETS_TOPIC}" \
    QUIET_MODE="${QUIET_MODE}" \
    LOG_LEVEL=1 \
    KAFKA_LOG_LEVEL=2 \
    pnpm run kafka:test:local
  ) 
  #> "${DATA_PREP_LOG}" 2>&1 &

  #DATA_PREP_PID=$!
  #echo "Data preparation PID: ${DATA_PREP_PID}"

  #echo "Waiting for data preparation to complete initial consume/produce phase..."
  #echo "--- Data preparation log (last lines) ---"
  #tail -n 40 "${DATA_PREP_LOG}" || true
  #wait_for_data_preparation_ready
 
 
  echo "Running resetTopics in local auth mode (none)..."
  (
    cd "${SCRIPTS_DIR}"
    KAFKA_AUTH_MODE=none \
    KAFKA_BROKERS="${KAFKA_BROKERS}" \
    DOMAIN_TOPIC_PREFIX="${DOMAIN_TOPIC_PREFIX}" \
    DOMAIN_TOPIC_EXCLUDE="${DOMAIN_TOPIC_EXCLUDE}" \
    DEBEZIUM_OFFSETS_TOPIC="${DEBEZIUM_OFFSETS_TOPIC}" \
    QUIET_MODE="${QUIET_MODE}" \
    LOG_LEVEL=1 \
    KAFKA_LOG_LEVEL=2 \
    pnpm run kafka:resetTopics
  )

  echo "Reset completed."
  echo "Completed setup + data preparation + reset in local mode."
}

run
