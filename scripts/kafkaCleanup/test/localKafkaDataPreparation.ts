import { KafkaJS } from "@confluentinc/kafka-javascript";
import {
  buildKafkaConfig,
  getTopicsToReset,
  logError,
  logInfo,
} from "../src/utilities/resetTopics";
import { config } from "../src/config/config";
import {
  buildGroupNames,
  cleanupExistingTestGroups,
  waitForGroupsStability,
} from "./consumerGroup";
import {
  Consumer,
  createConsumers,
  disconnectConsumers,
  runConsumers,
  startConsumerMessageProcessing,
} from "./consumer";
import { ensureTopics } from "./topic";
import { produceRandomMessages } from "./producer";

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

const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => setTimeout(resolve, ms));

function getBrokers(): string[] {
  return config.brokers || [DEFAULT_BROKER];
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

  const TOPICS_TO_RESET = getTopicsToReset(TOPICS, {
    includePrefixes: config.includePrefixes,
    excludePrefixes: config.excludePrefixes,
    exactMatches: config.exactMatches,
  });
  await ensureTopics(kafka, TOPICS_TO_RESET);
  logInfo(`Ensured topics: ${TOPICS_TO_RESET.join(", ")}`);

  await producer.connect();

  const expectedMessagesPerGroup = TOPICS_TO_RESET.length * MESSAGES_PER_TOPIC;
  const consumerSetup = await createConsumers({
    kafka,
    groups: GROUPS,
    topics: TOPICS_TO_RESET,
    consumersPerGroup: CONSUMERS_PER_GROUP,
    expectedMessagesPerGroup,
    runId: RUN_ID,
  });
  const consumerSetup_missingmessages = await createConsumers({
    kafka,
    groups: GROUPS_MISSING_MESSAGES,
    topics: TOPICS_TO_RESET,
    consumersPerGroup: CONSUMERS_PER_GROUP,
    expectedMessagesPerGroup: Math.floor(
      expectedMessagesPerGroup - expectedMessagesPerGroup * 0.15
    ),
    runId: RUN_ID,
  });

  consumers = consumerSetup.consumers;
  consumers_missingmessages = consumerSetup_missingmessages.consumers;

  await Promise.all([
    runConsumers(consumerSetup),
    runConsumers(consumerSetup_missingmessages),
  ]);
  await waitForGroupsStability(kafka, [...GROUPS, ...GROUPS_MISSING_MESSAGES]);
  await produceRandomMessages(
    producer,
    TOPICS_TO_RESET,
    MESSAGES_PER_TOPIC,
    RUN_ID
  );

  startConsumerMessageProcessing(consumerSetup);
  startConsumerMessageProcessing(consumerSetup_missingmessages);

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
          }/${Math.floor(
            expectedMessagesPerGroup - expectedMessagesPerGroup * 0.15
          )}`
      ).join(", ");
      throw new Error(
        `Timed out waiting for the consumer groups to read all produced messages. Final status: ${status}, ${status_missing}`
      );
    }),
  ]);

  logInfo("All consumer groups received the produced messages.");

  logInfo("Destroying consumers immediately after data preparation...");
  await disconnectConsumers(consumers);
  await disconnectConsumers(consumers_missingmessages);

  logInfo("Destroying producer immediately after data preparation...");
  await producer.disconnect();
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
