import { randomUUID } from "node:crypto";
import { KafkaJS } from "@confluentinc/kafka-javascript";
import { KafkaMessage } from "@confluentinc/kafka-javascript/types/kafkajs";
import { buildKafkaConfig, logError, logInfo } from "../src/utilities/resetTopics";
import { config } from "../src/config/config";

type Kafka = KafkaJS.Kafka;
type Producer = KafkaJS.Producer;
type Consumer = KafkaJS.Consumer;

const DEFAULT_BROKER = "localhost:9092";
const TOPICS = [
  "test.queue.alpha",
  "test.queue.beta",
  "test.queue.gamma",
] as const;
const PARTITIONS_PER_TOPIC = 3;
const MESSAGES_PER_TOPIC = 12;
const GROUP_PREFIXES = ["local-test-group-a", "local-test-group-b",  "local-test-group-c"] as const;
const GROUP_PREFIXES_MISSING_MESSAGES = ["local-test-group-a-missing", "local-test-group-b-missing",  "local-test-group-c-missing"] as const;
const CONSUMERS_PER_GROUP = 2;
const RUN_ID = Date.now().toString();
const GROUPS = GROUP_PREFIXES.map((prefix) => `${prefix}`);
const GROUPS_MISSING_MESSAGES = GROUP_PREFIXES_MISSING_MESSAGES.map((prefix) => `${prefix}`);
const DESTROY_CONSUMERS = process.env.DESTROY_CONSUMERS !== "false";
const DESTROY_PRODUCER = process.env.DESTROY_PRODUCER !== "false";
const CLEANUP_TIMEOUT_MS = 45_000;
const CLEANUP_POLL_INTERVAL_MS = 1_500;

const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

function getBrokers(): string[] {
  const rawValue = process.env.KAFKA_BROKERS ?? DEFAULT_BROKER;

  return rawValue
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);
}

async function ensureTopics(kafka: Kafka): Promise<void> {
  const admin = kafka.admin();

  await admin.connect();
  try {
    await admin.createTopics({
      topics: TOPICS.map((topic) => ({
        topic,
        numPartitions: PARTITIONS_PER_TOPIC,
        replicationFactor: 1,
      })),
    });
  } finally {
    await admin.disconnect();
  }
}

function buildRandomMessage(topic: string, index: number) {
  return {
    key: randomUUID(),
    value: JSON.stringify({
      id: randomUUID(),
      topic,
      index,
      amount: Math.floor(Math.random() * 10_000),
      createdAt: new Date().toISOString(),
      source: "local-data-preparation",
      runId: RUN_ID,
      payload: {
        reference: randomUUID(),
        note: `message-${index}`,
      },
    }),
  };
}

async function produceRandomMessages(producer: Producer): Promise<number> {
  let totalMessages = 0;

  for (const topic of TOPICS) {
    const messages = Array.from({ length: MESSAGES_PER_TOPIC }, (_, index) =>
      buildRandomMessage(topic, index),
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

function createMessageHandler(
  groupId: string,
  deliveredMessages: Map<string, Set<string>>,
  messageCountPerGroup: Map<string, number>,
  markCompletionIfNeeded: () => void,
) {
  return async ({ topic, partition, message }: { topic: string; partition: number; message: KafkaMessage }) => {
    try {
      const valueStr = message.value?.toString();
      if (!valueStr) {return;}
      
      const parsed = JSON.parse(valueStr);
      const messageId = parsed.id ?? null;
      if (!messageId) { return; }

      const deliveredMessagesSet = deliveredMessages.get(groupId);
      if (!deliveredMessagesSet || deliveredMessagesSet.has(messageId)) {
        // not a new message for this group, ignore
        return;
      }
      
      deliveredMessagesSet.add(messageId);
  
      // increment group count
      const current = messageCountPerGroup.get(groupId) ?? 0;
      messageCountPerGroup.set(groupId, current + 1);

      // mark for completion check
      markCompletionIfNeeded();
    } catch (error) {
      logError(`Error processing message from ${topic}:${partition}:${message.offset} ${error}`);
    }
  };
}

function createCompletionTracker(groups: string[], messageCountPerGroup: Map<string, number>, expectedMessagesPerGroup: number): {
  completion: Promise<void>;
  markCompletionIfNeeded: () => void;
} {

  let resolveCompletion!: () => void;
  const completion = new Promise<void>((resolve) => {
    resolveCompletion = resolve;
  });

  let completed = false;

  const markCompletionIfNeeded = () => {
    if (completed) { return; }

    const allDone = groups.every((groupId) => (messageCountPerGroup.get(groupId) ?? 0) >= expectedMessagesPerGroup);

    if (!allDone) { return; }

    completed = true;
    logInfo(`✓ All groups reached ${expectedMessagesPerGroup} messages`);

    for (const groupId of groups) {
      logInfo(`Group ${groupId}: ${messageCountPerGroup.get(groupId) ?? 0}/${expectedMessagesPerGroup}`);
    }

    resolveCompletion();
  };

  return { completion, markCompletionIfNeeded };
}

async function createGroupConsumers(kafka: Kafka, groupId: string, deliveredMessages: Map<string, Set<string>>, messageCountPerGroup: Map<string, number>, markCompletionIfNeeded: () => void): Promise<Consumer[]> {
  const consumers: Consumer[] = [];

  for (let i = 0; i < CONSUMERS_PER_GROUP; i += 1) {
    const consumer = kafka.consumer({
      "group.instance.id": `local-kafka-data-prep-${groupId}-consumer-${i}`,
      kafkaJS: {
        groupId,
        fromBeginning: true,
        sessionTimeout: 30_000,
        heartbeatInterval: 3_000,
      },
    });

    await consumer.connect();
    await Promise.all(TOPICS.map((topic) => consumer.subscribe({ topic })));

    await consumer.run({
      eachMessage: createMessageHandler(
        groupId,
        deliveredMessages,
        messageCountPerGroup,
        markCompletionIfNeeded,
      ),
    });

    consumers.push(consumer);
  }

  return consumers;
}

async function createConsumers(kafka: Kafka, groups: string[], expectedMessagesPerGroup: number): Promise<{
  consumers: Consumer[];
  completion: Promise<void>;
  messageCountPerGroup: Map<string, number>;
}> {
  const consumers: Consumer[] = [];
  
  const deliveredMessages = new Map<string, Set<string>>();
  for (const groupId of groups) {
    deliveredMessages.set(groupId, new Set());
  }
  
  const messageCountPerGroup = new Map<string, number>();
  for (const groupId of groups) {
    messageCountPerGroup.set(groupId, 0);
  }

  const { completion, markCompletionIfNeeded } = createCompletionTracker(groups, messageCountPerGroup, expectedMessagesPerGroup);

  for (const groupId of groups) {
    const groupConsumers = await createGroupConsumers(
      kafka,
      groupId,
      deliveredMessages,
      messageCountPerGroup,
      markCompletionIfNeeded,
    );

    consumers.push(...groupConsumers);
  }

  return { consumers, completion, messageCountPerGroup };
}

async function waitForGroupsStability(kafka: Kafka, groups: string[]): Promise<void> {
  const admin = kafka.admin();
  const timeoutMs = 30_000;
  const pollIntervalMs = 1_000;
  let elapsedMs = 0;

  await admin.connect();

  try {
    while (elapsedMs < timeoutMs) {
      const result = await admin.describeGroups(groups);
      const allStable = result.groups.every((group) => group.state === KafkaJS.ConsumerGroupStates.STABLE && group.members.length > 0);

      if (allStable) {
        logInfo("All consumer groups are stable.");
        return;
      }

      await sleep(pollIntervalMs);
      elapsedMs += pollIntervalMs;
    }
  } finally {
    await admin.disconnect();
  }

  throw new Error(
    "Timed out waiting for consumer groups to reach Stable state.",
  );
}

async function disconnectConsumers(consumers: Consumer[]): Promise<void> {
  await Promise.all(
    consumers.map(async (consumer) => {
      try {
        await consumer.disconnect();
      } catch (error) {
        logError(`Failed to disconnect consumer ${error}`);
      }
    }),
  );
}

function isNonEmptyGroupDeleteError(error: unknown): boolean {
  if (!error || typeof error !== "object") {
    return false;
  }

  const groups = (error as { groups?: Array<{ errorCode?: number }> }).groups;
  return (
    Array.isArray(groups) &&
    groups.length > 0 &&
    groups.every((group) => group.errorCode === 68)
  );
}

function isUnknownGroupDeleteError(error: unknown): boolean {
  if (!error || typeof error !== "object") {
    return false;
  }

  const groups = (error as { groups?: Array<{ errorCode?: number }> }).groups;
  return (
    Array.isArray(groups) &&
    groups.length > 0 &&
    groups.every((group) => group.errorCode === 69)
  );
}

async function cleanupExistingTestGroups(admin: KafkaJS.Admin): Promise<void> {
  const groups = await admin.listGroups();
  const listedGroupIds = new Set(groups.groups.map((group) => group.groupId));
  let existingGroups = GROUPS.filter((groupId) => listedGroupIds.has(groupId));
  existingGroups = existingGroups.concat(GROUPS_MISSING_MESSAGES.filter((groupId) => listedGroupIds.has(groupId)));

  if (!existingGroups.length) {
    logInfo("No existing test groups to delete.");
    return;
  }
  const startedAt = Date.now();

  while (Date.now() - startedAt < CLEANUP_TIMEOUT_MS) {
    try {
      await admin.deleteGroups(existingGroups);
      logInfo(`Deleted existing groups: ${existingGroups.join(", ")}`);
      return;
    } catch (error) {
      if (isUnknownGroupDeleteError(error)) {
        logInfo("Test groups already deleted or not found.");
        return;
      }

      if (!isNonEmptyGroupDeleteError(error)) {
        throw error;
      }

      const statusParts: string[] = await getConsumerGroupsStatus(admin, existingGroups);
      
      console.warn(`Groups still non-empty, waiting for consumers to stop before delete (${statusParts.join(", ")}).`);
      await sleep(CLEANUP_POLL_INTERVAL_MS);
    }
  }

  throw new Error(
    `Timed out waiting to delete non-empty groups: ${existingGroups.join(", ")}. Stop active consumers and retry.`,
  );
}

async function getConsumerGroupsStatus(admin: KafkaJS.Admin, groups: string[]): Promise<string[]> {
  const statusParts: string[] = [];
  for (const groupId of groups) {
        try {
          // Get group members count
          let membersCount = -1;
          const result = await admin.describeGroups([groupId]);
          const description = result.groups[0];

          if (!description) {
            membersCount = 0;
          } else {
            membersCount = description.members.length;
          }

          statusParts.push(`${groupId}: ${membersCount} member(s)`);
        } catch {
          statusParts.push(`${groupId}: n/a`);
        }
      }

  return statusParts;
}

async function run(): Promise<void> {
  const kafka = new KafkaJS.Kafka({
    kafkaJS: buildKafkaConfig(config.authMode, config.brokers, config.kafkaClientId, config.awsRegion)
  });
  const admin = kafka.admin();
  await admin.connect();
  try {
    await cleanupExistingTestGroups(admin);
  } finally {
    await admin.disconnect();
  }
  const producer = kafka.producer();
  let consumers: Consumer[] = [];
  let consumers_missingmessages: Consumer[] = [];

  logInfo(`Using brokers: ${getBrokers().join(", ")}`);
  logInfo(`Run id: ${RUN_ID}`);

  await ensureTopics(kafka);
  logInfo(`Ensured topics: ${TOPICS.join(", ")}`);

  await producer.connect();

  const expectedMessagesPerGroup = TOPICS.length * MESSAGES_PER_TOPIC;
  const consumerSetup = await createConsumers(kafka, GROUPS, expectedMessagesPerGroup);
  const consumerSetup_missingmessages = await createConsumers(kafka, GROUPS_MISSING_MESSAGES, expectedMessagesPerGroup-(TOPICS.length * 3));

  consumers = consumerSetup.consumers;
  consumers_missingmessages = consumerSetup_missingmessages.consumers;

  await waitForGroupsStability(kafka, [...GROUPS, ...GROUPS_MISSING_MESSAGES]);
  await produceRandomMessages(producer);

  await Promise.race([
    Promise.all([consumerSetup.completion, consumerSetup_missingmessages.completion]),
    sleep(120_000).then(() => {
      const status = GROUPS.map((g) => `${g}: ${consumerSetup.messageCountPerGroup.get(g) ?? 0}/${expectedMessagesPerGroup}`).join(", ");
      const status_missing = GROUPS_MISSING_MESSAGES.map((g) => `${g}: ${consumerSetup_missingmessages.messageCountPerGroup.get(g) ?? 0}/${expectedMessagesPerGroup-(TOPICS.length * 3)}`).join(", ");
      throw new Error(
        `Timed out waiting for the consumer groups to read all produced messages. Final status: ${status}, ${status_missing}`,
      );
    }),
  ]);

  logInfo("All consumer groups received the produced messages.");

  if (DESTROY_CONSUMERS) {
    logInfo("Destroying consumers immediately after data preparation...");
    await disconnectConsumers(consumers);
    await disconnectConsumers(consumers_missingmessages);
  } else {
    logInfo(
      "DESTROY_CONSUMERS=false: consumers left active (process will keep running).",
    );
  }

  if (DESTROY_PRODUCER) {
    logInfo("Destroying producer immediately after data preparation...");
    await producer.disconnect();
  } else {
    logInfo(
      "DESTROY_PRODUCER=false: producer left active (process may keep running).",
    );
  }
}

run().then(() => {
  logInfo("Data preparation completed successfully.");
  process.exit(0);
}).catch((error: unknown) => {
  logError(`Data preparation failed with error: ${error}`);
  process.exitCode = 1;
});
