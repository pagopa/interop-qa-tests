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
  logWarning
} from "./utilities/resetTopics";

import { 
  config
} from "./config/config";

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

async function getTopicHighOffsetsByPartition(admin: Admin, topics: string[]): Promise<Map<string, Map<number, string>>> {
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
  topicHighOffsetsByPartition: Map<string, Map<number, string>>,
): Promise<void> {
  const offsetsToCommit: TopicPartitionOffsetAndMetadata[] = [];

  for (const [topic, highByPartition] of topicHighOffsetsByPartition.entries()) {
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
    // "group.instance.id": `reset-offsets-${groupId}-${Date.now()}-${Math.random()}`,
    kafkaJS: {
      groupId,
      autoCommit: false,
    },
  });

  try {
    await consumer.connect();
    await consumer.commitOffsets(offsetsToCommit);
    logInfo(`Group ${groupId}: reset to latest committed on ${offsetsToCommit.length} topic-partitions.`);
  } finally {
    await consumer.disconnect();
  }
}

async function alignConsumerGroups(kafka: Kafka, admin: Admin, topics: string[]): Promise<void> {
  const topicHighOffsetsByPartition: Map<string, Map<number, string>> = await getTopicHighOffsetsByPartition(admin, topics);

  if (!topicHighOffsetsByPartition.size) {
    logWarning("No topic offsets available for consumer-group alignment check.");
    return;
  }

  const groupsResponse: { groups: GroupOverview[] } = await admin.listGroups();
  const groupIds = groupsResponse.groups.map((group) => group.groupId);

  if (!groupIds.length) {
    logWarning("No consumer groups found, skipping alignment check.");
    return;
  }

  let recap = ``;
  for (const groupId of groupIds) {
    await resetConsumerGroupOffsetsToLatest(kafka, groupId, topicHighOffsetsByPartition);
    logDebug(`Checking consumer-group offset alignment for group: ${groupId}`);
    const statuses: GroupTopicPartitionStatus[] = [];

    for (const [topic, highByPartition] of topicHighOffsetsByPartition.entries()) {
      /* fetchOffsets returns the consumer group offset for a list of topics. */
      const groupOffsets = await admin.fetchOffsets({ groupId, topics: [topic] });
      const topicOffsets = groupOffsets.find((item) => item.topic === topic);

      if (!topicOffsets) {
        continue;
      }

      for (const groupOffsetInfo of topicOffsets.partitions) {
        const topicHigh = highByPartition.get(groupOffsetInfo.partition);

        if (typeof topicHigh === "undefined") {
          continue;
        }

        const aligned = groupOffsetInfo.offset === topicHigh;
        statuses.push({
          topic,
          partition: groupOffsetInfo.partition,
          groupOffset: groupOffsetInfo.offset,
          topicHigh,
          aligned,
        });
      }
    }

    const alignedCount = statuses.filter((status) => status.aligned).length;
    const totalCount = statuses.length;
    const isGroupAligned = totalCount > 0 && alignedCount === totalCount;

    logInfo(`Group ${groupId} alignment: ${alignedCount}/${totalCount} partitions aligned (${isGroupAligned ? "OK" : "NOT_ALIGNED"})`);
    for (const status of statuses) {
      logDebug(`Group ${groupId} - topic ${status.topic} partition ${status.partition}: group offset ${status.groupOffset}, topic high ${status.topicHigh}, aligned: ${status.aligned}`);
    }
    if (!isGroupAligned && statuses.length) {
      const notAligned = statuses.filter((status) => !status.aligned);
      logWarning(`Group ${groupId} not aligned details: ${JSON.stringify(notAligned)}`);
    }
  }
}

const run = async (): Promise<void> => {
  let admin: Admin | null = null;

  try {
    logDebug("Setup Kafka connection.");
    const kafka: Kafka = new KafkaJS.Kafka({
      kafkaJS: buildKafkaConfig(config.authMode, config.brokers, config.awsRegion),
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
        await purgeTopics(
          admin,
          topicsToReset,
        );
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
