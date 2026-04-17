import { KafkaJS } from "@confluentinc/kafka-javascript";
import { KafkaMessage } from "@confluentinc/kafka-javascript/types/kafkajs";
import {
  buildKafkaConfig,
  logError,
  logInfo,
} from "../src/utilities/resetTopics";
import { config } from "../src/config/config";
import {
  buildGroupNames,
  cleanupExistingTestGroups,
  waitForGroupsStability,
} from "./consumerGroup";
import { ensureTopics } from "./topic";
import { produceRandomMessages } from "./producer";

type Kafka = KafkaJS.Kafka;
type Consumer = KafkaJS.Consumer;

const DEFAULT_BROKER = "localhost:9092";
const TOPICS = [
  "test.queue.alpha",
  "test.queue.beta",
  "test.queue.gamma",
  "i.am.not.used",
];
const MESSAGES_PER_TOPIC = 12;
const CONSUMERS_PER_GROUP = 2;
const RUN_ID = Date.now().toString();
const GROUPS = buildGroupNames(3, "local-test-group");
const GROUPS_MISSING_MESSAGES = buildGroupNames(3, "local-test-group-missing");
const DESTROY_CONSUMERS = process.env.DESTROY_CONSUMERS !== "false";
const DESTROY_PRODUCER = process.env.DESTROY_PRODUCER !== "false";

const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

function getBrokers(): string[] {
  return config.brokers || [DEFAULT_BROKER];
}

function createMessageHandler(
  groupId: string,
  deliveredMessages: Map<string, Set<string>>,
  messageCountPerGroup: Map<string, number>,
  markCompletionIfNeeded: () => void
) {
  return async ({
    topic,
    partition,
    message,
  }: {
    topic: string;
    partition: number;
    message: KafkaMessage;
  }) => {
    try {
      const valueStr = message.value?.toString();
      if (!valueStr) {
        return;
      }

      const parsed = JSON.parse(valueStr);
      const messageId = parsed.id ?? null;
      if (!messageId) {
        return;
      }

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
      logError(
        `Error processing message from ${topic}:${partition}:${message.offset} ${error}`
      );
    }
  };
}

function createCompletionTracker(
  groups: string[],
  messageCountPerGroup: Map<string, number>,
  expectedMessagesPerGroup: number
): {
  completion: Promise<void>;
  markCompletionIfNeeded: () => void;
} {
  let resolveCompletion!: () => void;
  const completion = new Promise<void>((resolve) => {
    resolveCompletion = resolve;
  });

  let completed = false;

  const markCompletionIfNeeded = () => {
    if (completed) {
      return;
    }

    const allDone = groups.every(
      (groupId) =>
        (messageCountPerGroup.get(groupId) ?? 0) >= expectedMessagesPerGroup
    );

    if (!allDone) {
      return;
    }

    completed = true;
    logInfo(`✓ All groups reached ${expectedMessagesPerGroup} messages`);

    for (const groupId of groups) {
      logInfo(
        `Group ${groupId}: ${
          messageCountPerGroup.get(groupId) ?? 0
        }/${expectedMessagesPerGroup}`
      );
    }

    resolveCompletion();
  };

  return { completion, markCompletionIfNeeded };
}

async function createGroupConsumers(
  kafka: Kafka,
  groupId: string,
  deliveredMessages: Map<string, Set<string>>,
  messageCountPerGroup: Map<string, number>,
  markCompletionIfNeeded: () => void
): Promise<Consumer[]> {
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
        markCompletionIfNeeded
      ),
    });

    consumers.push(consumer);
  }

  return consumers;
}

async function createConsumers(
  kafka: Kafka,
  groups: string[],
  expectedMessagesPerGroup: number
): Promise<{
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

  const { completion, markCompletionIfNeeded } = createCompletionTracker(
    groups,
    messageCountPerGroup,
    expectedMessagesPerGroup
  );

  for (const groupId of groups) {
    const groupConsumers = await createGroupConsumers(
      kafka,
      groupId,
      deliveredMessages,
      messageCountPerGroup,
      markCompletionIfNeeded
    );

    consumers.push(...groupConsumers);
  }

  return { consumers, completion, messageCountPerGroup };
}

async function disconnectConsumers(consumers: Consumer[]): Promise<void> {
  await Promise.all(
    consumers.map(async (consumer) => {
      try {
        await consumer.disconnect();
      } catch (error) {
        logError(`Failed to disconnect consumer ${error}`);
      }
    })
  );
}

async function run(): Promise<void> {
  const kafka = new KafkaJS.Kafka({
    kafkaJS: buildKafkaConfig(
      config.authMode,
      config.brokers,
      config.kafkaClientId,
      config.awsRegion
    ),
  });
  const admin = kafka.admin();

  await cleanupExistingTestGroups(admin, [
    ...GROUPS,
    ...GROUPS_MISSING_MESSAGES,
  ]);

  const producer = kafka.producer();
  let consumers: Consumer[] = [];
  let consumers_missingmessages: Consumer[] = [];

  logInfo(`Using brokers: ${getBrokers().join(", ")}`);
  logInfo(`Run id: ${RUN_ID}`);

  await ensureTopics(kafka, TOPICS);
  logInfo(`Ensured topics: ${TOPICS.join(", ")}`);

  await producer.connect();

  const expectedMessagesPerGroup = TOPICS.length * MESSAGES_PER_TOPIC;
  const consumerSetup = await createConsumers(
    kafka,
    GROUPS,
    expectedMessagesPerGroup
  );
  const consumerSetup_missingmessages = await createConsumers(
    kafka,
    GROUPS_MISSING_MESSAGES,
    expectedMessagesPerGroup - TOPICS.length * 3
  );

  consumers = consumerSetup.consumers;
  consumers_missingmessages = consumerSetup_missingmessages.consumers;

  await waitForGroupsStability(kafka, [...GROUPS, ...GROUPS_MISSING_MESSAGES]);
  await produceRandomMessages(producer, TOPICS, MESSAGES_PER_TOPIC, RUN_ID);

  await Promise.race([
    Promise.all([
      consumerSetup.completion,
      consumerSetup_missingmessages.completion,
    ]),
    sleep(120_000).then(() => {
      const status = GROUPS.map(
        (g) =>
          `${g}: ${
            consumerSetup.messageCountPerGroup.get(g) ?? 0
          }/${expectedMessagesPerGroup}`
      ).join(", ");
      const status_missing = GROUPS_MISSING_MESSAGES.map(
        (g) =>
          `${g}: ${
            consumerSetup_missingmessages.messageCountPerGroup.get(g) ?? 0
          }/${expectedMessagesPerGroup - TOPICS.length * 3}`
      ).join(", ");
      throw new Error(
        `Timed out waiting for the consumer groups to read all produced messages. Final status: ${status}, ${status_missing}`
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
      "DESTROY_CONSUMERS=false: consumers left active (process will keep running)."
    );
  }

  if (DESTROY_PRODUCER) {
    logInfo("Destroying producer immediately after data preparation...");
    await producer.disconnect();
  } else {
    logInfo(
      "DESTROY_PRODUCER=false: producer left active (process may keep running)."
    );
  }
}

run()
  .then(() => {
    logInfo("Data preparation completed successfully.");
    process.exit(0);
  })
  .catch((error: unknown) => {
    logError(`Data preparation failed with error: ${error}`);
    process.exitCode = 1;
  });
