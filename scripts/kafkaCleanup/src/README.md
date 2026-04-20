# interop-kafka-utility

Utilities for Kafka topic cleanup and consumer-group offset alignment used by QA flows.

## What is in this folder

- `src/resetTopics.ts`: main reset entrypoint.
- `src/utilities/resetTopics.ts`: Kafka config, auth helpers, topic selection, purge logic, logger helpers.
- `src/config/config.ts`: environment parsing and validation (Zod).
- `src/models/types.ts`: shared types and enums.
- `test/localKafkaDataPreparation.ts`: local data seeding for test topics and consumer groups.
- `test/run-local-reset.sh`: end-to-end local orchestration with Docker Compose.
- `test/docker-compose.yml`: local Kafka stack definition.

## Core behavior

The reset flow in `src/resetTopics.ts` does the following:

1. Connects with Kafka admin.
2. Lists topics and filters them by include/exclude/exact rules.
3. Purges selected topics using `deleteTopicRecords` to latest offsets.
4. Aligns consumer-group committed offsets to topic high-water marks.
5. Logs alignment details for each group/topic/partition.

## Configuration

Environment variables parsed by `src/config/config.ts`:

- `KAFKA_BROKERS` (required): comma-separated broker list.
- `KAFKA_AUTH_MODE`: `aws-iam` (default) or `none`.
- `AWS_REGION` (required when `KAFKA_AUTH_MODE=aws-iam`).
- `KAFKA_CLIENT_ID` (optional, default: `kafka-scripts`).
- `DOMAIN_TOPIC_PREFIX` (optional): comma-separated include prefixes.
- `DOMAIN_TOPIC_EXCLUDE` (optional): comma-separated exclude prefixes.
- `DEBEZIUM_OFFSETS_TOPIC` (optional): comma-separated exact topic names.
- `EXACT_MATCHES_FILE_PATH` (optional): path to a file containing exact topic names to include. Supports JSON array (`["topic.a","topic.b"]`) or plain text (one topic per line, or comma-separated).
- `QUIET_MODE`: `1` disables non-error console output.
- `LOG_LEVEL`: app logger level (`0=DEBUG`, `1=INFO`, `2=WARNING`, `3=ERROR`).
- `KAFKA_LOG_LEVEL`: Kafka client logger level (`0=DEBUG`, `1=INFO`, `2=WARNING`, `3=ERROR`).

Validation rules:

- At least one of `DOMAIN_TOPIC_PREFIX`, `DEBEZIUM_OFFSETS_TOPIC`, or `EXACT_MATCHES_FILE_PATH` must be set.
- `KAFKA_BROKERS` must be set.
- `AWS_REGION` is mandatory in `aws-iam` mode.

## Typical commands

From `scripts/kafkaCleanup`:

- `pnpm run kafka:resetTopics`
- `pnpm run kafka:test:local`
- `sh test/run-local-reset.sh`

## Local test flow

`test/run-local-reset.sh` can:

- optionally recreate local Kafka volumes (`RESET_KAFKA=1`),
- start Kafka via `test/docker-compose.yml`,
- run data preparation (`kafka:test:local`),
- run reset/alignment (`kafka:resetTopics`) with local auth (`KAFKA_AUTH_MODE=none`).

Example:

`RESET_KAFKA=1 QUIET_MODE=0 LOG_LEVEL=1 KAFKA_LOG_LEVEL=2 sh test/run-local-reset.sh`
