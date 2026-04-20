import { KafkaJS } from "@confluentinc/kafka-javascript";
import { KafkaMessage } from "@confluentinc/kafka-javascript/types/kafkajs";
import { logError, logInfo } from "../src/utilities/resetTopics";

type Kafka = KafkaJS.Kafka;
export type Consumer = KafkaJS.Consumer;

type PreparedConsumer = {
  consumer: Consumer;
  groupId: string;
};

export type ConsumerSetup = {
  consumers: Consumer[];
  completion: Promise<void>;
  messageCountPerGroup: Map<string, number>;
  preparedConsumers: PreparedConsumer[];
  deliveredMessages: Map<string, Set<string>>;
  markCompletionIfNeeded: () => void;
  topics: string[];
  expectedMessagesPerGroup: number;
  runId: string;
};

type CreateConsumersOptions = {
  kafka: Kafka;
  groups: string[];
  topics: string[];
  consumersPerGroup: number;
  expectedMessagesPerGroup: number;
  runId: string;
};

type GroupConsumerOptions = {
  kafka: Kafka;
  groupId: string;
  topics: string[];
  consumersPerGroup: number;
};

type MessageHandlerContext = {
  groupId: string;
  runId: string;
  expectedMessagesPerGroup: number;
  deliveredMessages: Map<string, Set<string>>;
  messageCountPerGroup: Map<string, number>;
  markCompletionIfNeeded: () => void;
  stopGroupReading: (groupId: string) => void;
};

function createMessageHandler(context: MessageHandlerContext) {
  const {
    groupId,
    runId,
    expectedMessagesPerGroup,
    deliveredMessages,
    messageCountPerGroup,
    markCompletionIfNeeded,
    stopGroupReading,
  } = context;

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
      if (!messageId || parsed.runId !== runId) {
        return;
      }

      const current = messageCountPerGroup.get(groupId) ?? 0;
      if (current >= expectedMessagesPerGroup) {
        stopGroupReading(groupId);
        return;
      }

      const deliveredMessagesSet = deliveredMessages.get(groupId);
      if (!deliveredMessagesSet || deliveredMessagesSet.has(messageId)) {
        return;
      }

      deliveredMessagesSet.add(messageId);

      const next = current + 1;
      messageCountPerGroup.set(groupId, next);

      if (next >= expectedMessagesPerGroup) {
        stopGroupReading(groupId);
      }

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

function pauseConsumersForGroup(
  preparedConsumers: PreparedConsumer[],
  topics: string[],
  groupId: string
): void {
  for (const { consumer, groupId: preparedGroupId } of preparedConsumers) {
    if (preparedGroupId === groupId) {
      consumer.pause(topics.map((topic) => ({ topic })));
    }
  }
}

async function createGroupConsumers(
  options: GroupConsumerOptions
): Promise<PreparedConsumer[]> {
  const { kafka, groupId, topics, consumersPerGroup } = options;
  const preparedConsumers: PreparedConsumer[] = [];

  for (let i = 0; i < consumersPerGroup; i += 1) {
    const consumer = kafka.consumer({
      // "group.instance.id": `local-kafka-data-prep-${groupId}-consumer-${i}`,
      kafkaJS: {
        groupId,
        fromBeginning: true,
        sessionTimeout: 30_000,
        heartbeatInterval: 3_000,
      },
    });

    await consumer.connect();
    await Promise.all(topics.map((topic) => consumer.subscribe({ topic })));

    preparedConsumers.push({ consumer, groupId });
  }

  return preparedConsumers;
}

export async function createConsumers(
  options: CreateConsumersOptions
): Promise<ConsumerSetup> {
  const {
    kafka,
    groups,
    topics,
    consumersPerGroup,
    expectedMessagesPerGroup,
    runId,
  } = options;
  const consumers: Consumer[] = [];
  const preparedConsumers: PreparedConsumer[] = [];

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
    const groupPreparedConsumers = await createGroupConsumers({
      kafka,
      groupId,
      topics,
      consumersPerGroup,
    });

    consumers.push(
      ...groupPreparedConsumers.map(
        (preparedConsumer) => preparedConsumer.consumer
      )
    );
    preparedConsumers.push(...groupPreparedConsumers);
  }

  return {
    consumers,
    completion,
    messageCountPerGroup,
    preparedConsumers,
    deliveredMessages,
    markCompletionIfNeeded,
    topics,
    expectedMessagesPerGroup,
    runId,
  };
}

export async function runConsumers(
  consumerSetup: ConsumerSetup
): Promise<void> {
  const {
    preparedConsumers,
    deliveredMessages,
    messageCountPerGroup,
    markCompletionIfNeeded,
    topics,
    expectedMessagesPerGroup,
    runId,
  } = consumerSetup;
  const stoppedGroups = new Set<string>();

  const stopGroupReading = (groupId: string): void => {
    if (stoppedGroups.has(groupId)) {
      return;
    }

    stoppedGroups.add(groupId);
    pauseConsumersForGroup(preparedConsumers, topics, groupId);
    logInfo(`Paused consumer group ${groupId} after reaching expected limit.`);
  };

  await Promise.all(
    preparedConsumers.map(({ consumer, groupId }) =>
      consumer.run({
        eachMessage: createMessageHandler({
          groupId,
          runId,
          expectedMessagesPerGroup,
          deliveredMessages,
          messageCountPerGroup,
          markCompletionIfNeeded,
          stopGroupReading,
        }),
      })
    )
  );

  for (const consumer of consumerSetup.consumers) {
    consumer.pause(topics.map((topic) => ({ topic })));
  }
}

export function startConsumerMessageProcessing(
  consumerSetup: ConsumerSetup
): void {
  for (const consumer of consumerSetup.consumers) {
    consumer.resume(consumerSetup.topics.map((topic) => ({ topic })));
  }
}

export async function disconnectConsumers(
  consumers: Consumer[]
): Promise<void> {
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
