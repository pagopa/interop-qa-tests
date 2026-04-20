import { Kafka } from "@confluentinc/kafka-javascript/types/kafkajs";

export const PARTITIONS_PER_TOPIC = 3;
export const MESSAGES_PER_TOPIC = 12;

export async function ensureTopics(
  kafka: Kafka,
  topics: string[]
): Promise<void> {
  const admin = kafka.admin();

  await admin.connect();
  try {
    await admin.createTopics({
      topics: topics.map((topic) => ({
        topic,
        numPartitions: PARTITIONS_PER_TOPIC,
        replicationFactor: 1,
      })),
    });
  } finally {
    await admin.disconnect();
  }
}
