# interop-kafka-utility

## Kafka Topic deletion procedure
### Environment Variables
- QUIET_MODE: If set to "1" avoids info logging
- DOMAIN_TOPIC_PREFIX: String prefix matching topics to delete (possible multiple matches on Kafka broker)
- DEBEZIUM_OFFSETS_TOPIC: Exact matching string of Debezium topic to delete
- KAFKA_BROKERS: Kafka broker url
- AWS_REGION: AWS region hosting Kafka instance

## Kafka Topic creation procedure
### Environment Variables
- QUIET_MODE: If set to "1" avoids info logging
- TOPICS_PROPERTIES_PATH: Absolute path where Topic properties files resides
- KAFKA_BROKERS: Kafka broker url
- AWS_REGION: AWS region hosting Kafka instance