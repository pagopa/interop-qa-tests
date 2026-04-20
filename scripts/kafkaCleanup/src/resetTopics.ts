// TODOs
// OK - usare zod per env var (fare riferimento ad interop ad esempio agreement-process per struttura folders e validazione env var)
// OK - kafkajs vs confluent (verificare problemi auth admin client)
// OK - latest node
// file per topic exactMatches
// check msk api
// OK - spostare tutto sotto /scripts/kafkaCleanup
import { KafkaJS } from "@confluentinc/kafka-javascript";
import {
  buildKafkaConfig,
  getTopicsToReset,
  purgeTopics,
  logInfo,
  logError,
  logDebug,
  logWarning,
} from "./utilities/resetTopics";

import { config } from "./config/config";

type Admin = KafkaJS.Admin;
type Kafka = KafkaJS.Kafka;
type GroupOverview = KafkaJS.GroupOverview;
type TopicPartitionOffsetAndMetadata = KafkaJS.TopicPartitionOffsetAndMetadata;

type GroupTopicPartitionStatus = {
  topic: string;
  partition: number;
  groupOffset: string;
  topicHigh: string;
  aligned: boolean;
};

async function getTopicHighOffsetsByPartition(
  admin: Admin,
  topics: string[]
): Promise<Map<string, Map<number, string>>> {
  const byTopic = new Map<string, Map<number, string>>();

  for (const topic of topics) {
    const offsets = await admin.fetchTopicOffsets(topic);
    const partitionMap = new Map<number, string>();

    for (const offsetInfo of offsets) {
      partitionMap.set(offsetInfo.partition, offsetInfo.high);
    }

    byTopic.set(topic, partitionMap);
  }

  return byTopic;
}

async function resetConsumerGroupOffsetsToLatest(
  kafka: Kafka,
  groupId: string,
  topicHighOffsetsByPartition: Map<string, Map<number, string>>
): Promise<void> {
  const offsetsToCommit: TopicPartitionOffsetAndMetadata[] = [];

  for (const [
    topic,
    highByPartition,
  ] of topicHighOffsetsByPartition.entries()) {
    for (const [partition, offset] of highByPartition.entries()) {
      offsetsToCommit.push({
        topic,
        partition,
        offset,
      });
    }
  }

  if (!offsetsToCommit.length) {
    logInfo(`Group ${groupId}: no offsets to reset.`);
    return;
  }

  const consumer = kafka.consumer({
    kafkaJS: {
      groupId,
      autoCommit: false,
    },
  });

  try {
    await consumer.connect();
    await consumer.commitOffsets(offsetsToCommit);
    logDebug(
      `Group ${groupId}: reset to latest committed on ${offsetsToCommit.length} topic-partitions.`
    );
  } finally {
    await consumer.disconnect();
  }
}

async function alignConsumerGroups(
  kafka: Kafka,
  admin: Admin,
  topics: string[]
): Promise<void> {
  const topicHighOffsetsByPartition: Map<
    string,
    Map<number, string>
  > = await getTopicHighOffsetsByPartition(admin, topics);

  if (!topicHighOffsetsByPartition.size) {
    logWarning(
      "No topic offsets available for consumer-group alignment check."
    );
    return;
  }

  const response: { groups: GroupOverview[] } = await admin.listGroups();
  const groupIds = response.groups.map((g) => g.groupId);

  if (!groupIds.length) {
    logWarning("No consumer groups found, skipping alignment check.");
    return;
  }

  for (const groupId of groupIds) {
    await processConsumerGroup(
      kafka,
      admin,
      groupId,
      topicHighOffsetsByPartition
    );
  }
}

async function processConsumerGroup(
  kafka: Kafka,
  admin: Admin,
  groupId: string,
  topicHighOffsetsByPartition: Map<string, Map<number, string>>
): Promise<void> {
  await resetConsumerGroupOffsetsToLatest(
    kafka,
    groupId,
    topicHighOffsetsByPartition
  );

  logDebug(`Checking consumer-group offset alignment for group: ${groupId}`);

  const statuses = await collectGroupStatuses(
    admin,
    groupId,
    topicHighOffsetsByPartition
  );
  const alignedCount = statuses.filter((s) => s.aligned).length;
  const totalCount = statuses.length;
  const isAligned = totalCount > 0 && alignedCount === totalCount;

  logInfo(
    `Group ${groupId} alignment: ${alignedCount}/${totalCount} partitions aligned (${
      isAligned ? "OK" : "NOT_ALIGNED"
    })`
  );

  for (const status of statuses) {
    logDebug(
      `Group ${groupId} - topic ${status.topic} partition ${status.partition}: group offset ${status.groupOffset}, topic high ${status.topicHigh}, aligned: ${status.aligned}`
    );
  }

  if (!isAligned && statuses.length) {
    const notAligned = statuses.filter((s) => !s.aligned);
    logWarning(
      `Group ${groupId} not aligned details: ${JSON.stringify(notAligned)}`
    );
  }
}

async function collectGroupStatuses(
  admin: Admin,
  groupId: string,
  topicHighOffsetsByPartition: Map<string, Map<number, string>>
): Promise<GroupTopicPartitionStatus[]> {
  const statuses: GroupTopicPartitionStatus[] = [];

  for (const [
    topic,
    highByPartition,
  ] of topicHighOffsetsByPartition.entries()) {
    const topicOffsets = await getGroupTopicOffsets(admin, groupId, topic);

    if (!topicOffsets) {
      continue;
    }

    for (const partitionInfo of topicOffsets.partitions) {
      const topicHigh = highByPartition.get(partitionInfo.partition);
      let status = null;

      if (typeof topicHigh !== "undefined") {
        status = {
          topic,
          partition: partitionInfo.partition,
          groupOffset: partitionInfo.offset,
          topicHigh,
          aligned: partitionInfo.offset === topicHigh,
        };
      } else {
        status = {
          topic,
          partition: partitionInfo.partition,
          groupOffset: partitionInfo.offset || "",
          topicHigh: topicHigh || "",
          aligned: false,
        };
      }

      if (status) {
        statuses.push(status);
      }
    }
  }

  return statuses;
}

async function getGroupTopicOffsets(
  admin: Admin,
  groupId: string,
  topic: string
) {
  const offsets = await admin.fetchOffsets({ groupId, topics: [topic] });
  return offsets.find(
    (o: { topic: string; partitions: KafkaJS.FetchOffsetsPartition[] }) =>
      o.topic === topic
  );
}

const run = async (): Promise<void> => {
  let admin: Admin | null = null;

  try {
    logDebug("Setup Kafka connection.");
    const kafka: Kafka = new KafkaJS.Kafka({
      kafkaJS: buildKafkaConfig(
        config.authMode,
        config.brokers,
        config.awsRegion
      ),
    });

    logDebug("Connect to Kafka with admin client.");
    admin = kafka.admin();
    await admin.connect();

    logDebug("List Kafka existing topics.");
    const kafkaTopics = await admin.listTopics();
    logInfo(`Existing topics: ${kafkaTopics}`);

    if (kafkaTopics.length) {
      const topicsToReset = getTopicsToReset(kafkaTopics, {
        includePrefixes: config.includePrefixes,
        excludePrefixes: config.excludePrefixes,
        exactMatches: config.exactMatches,
      });

      if (topicsToReset.length) {
        logInfo(`Resetting ${topicsToReset}`);
        await purgeTopics(admin, topicsToReset);
        await alignConsumerGroups(kafka, admin, topicsToReset);
      } else {
        logWarning("No topic matched the reset criteria.");
      }
    } else {
      logWarning("No topic found, skipping reset.");
    }
  } finally {
    if (admin) {
      logDebug("Disconnect Kafka admin client.");
      await admin.disconnect();
    }
  }
};

void run().catch((error: unknown) => {
  logError(error);
  process.exitCode = 1;
});
