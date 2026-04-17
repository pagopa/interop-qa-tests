import { randomUUID } from "node:crypto";
import { KafkaJS } from "@confluentinc/kafka-javascript";
import { logInfo, logWarning } from "../src/utilities/resetTopics";

function buildRandomMessage(topic: string, index: number, runId?: string) {
  return {
    key: randomUUID(),
    value: JSON.stringify({
      id: randomUUID(),
      topic,
      index,
      amount: Math.floor(Math.random() * 10_000),
      createdAt: new Date().toISOString(),
      source: "local-data-preparation",
      runId: runId || randomUUID(),
      payload: {
        reference: randomUUID(),
        note: `message-${index}`,
      },
    }),
  };
}

export async function produceRandomMessages(
  producer: KafkaJS.Producer,
  targetTopics: string[],
  messagesPerTopic: number,
  runId?: string
): Promise<number> {
  let totalMessages = 0;

  if (targetTopics.length === 0) {
    logWarning("No target topics specified for message production.");
    return totalMessages;
  }

  logInfo(
    `Starting message production: ${messagesPerTopic} messages on each of ${targetTopics.length} topics.`
  );

  for (const topic of targetTopics) {
    const messages = Array.from({ length: messagesPerTopic }, (_, index) =>
      buildRandomMessage(topic, index, runId)
    );

    await producer.send({
      topic,
      messages,
    });

    totalMessages += messages.length;
    logInfo(`Produced ${messages.length} messages on topic ${topic}`);
  }

  return totalMessages;
}
