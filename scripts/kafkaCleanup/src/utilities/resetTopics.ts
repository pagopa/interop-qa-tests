import { generateAuthToken } from "aws-msk-iam-sasl-signer-js";
import { KafkaJS } from "@confluentinc/kafka-javascript";
import {
  Admin,
  KafkaAuthMode,
  KafkaConfig,
  PartitionOffset,
  PurgeResult,
  LogLevel,
  type ResetTopicSelectionOptions,
} from "../models/types";
import { config } from "./../config/config";

export function createKafkaLogger(): KafkaJS.Logger {
  let currentLogLevel = config.kafkaLogLevel;

  const logger: KafkaJS.Logger = {
    debug: (entry: unknown) => {
      if (currentLogLevel <= LogLevel.DEBUG) {
        logDebug(`[KAFKA] ${entry}`);
      }
    },
    info: (entry: unknown) => {
      if (currentLogLevel <= LogLevel.INFO) {
        logInfo(`[KAFKA] ${entry}`);
      }
    },
    warn: (entry: unknown) => {
      if (currentLogLevel <= LogLevel.WARNING) {
        logWarning(`[KAFKA] ${entry}`);
      }
    },
    error: (entry: unknown) => {
      if (currentLogLevel <= LogLevel.ERROR) {
        logError(`[KAFKA] ${entry}`);
      }
    },
    namespace: (_namespace: string, logLevel?: number): KafkaJS.Logger => {
      if (typeof logLevel === "number") {
        currentLogLevel = logLevel;
      }
      return logger;
    },
    setLogLevel: (logLevel: number): void => {
      currentLogLevel = logLevel;
    },
  };

  return logger;
}

export const logDebug = (message: string): void => {
  if (!config.quietModeOn && config.logLevel <= LogLevel.DEBUG) {
    console.log(`[DEBUG] ${message}`);
  }
};
export const logInfo = (message: string): void => {
  if (!config.quietModeOn && config.logLevel <= LogLevel.INFO) {
    console.log(`[INFO] ${message}`);
  }
};
export const logError = (message: unknown): void => {
  if (config.logLevel <= LogLevel.ERROR) {
    console.error(`[ERROR] ${message}`);
  }
};
export const logWarning = (message: unknown): void => {
  if (config.logLevel <= LogLevel.WARNING) {
    console.warn(`[WARNING] ${message}`);
  }
};

export function buildKafkaConfig(
  authMode: KafkaAuthMode,
  brokers?: string[],
  clientId?: string,
  awsRegion?: string
): KafkaConfig {
  if (authMode === "none") {
    return {
      clientId: clientId ?? config.kafkaClientId,
      brokers: brokers ?? config.brokers,
      ssl: false,
      logger: createKafkaLogger(),
    };
  }

  return {
    clientId: clientId ?? config.kafkaClientId,
    brokers: brokers ?? config.brokers,
    ssl: true,
    sasl: {
      mechanism: "oauthbearer",
      oauthBearerProvider: () => oauthBearerTokenProvider(awsRegion as string),
    },
  };
}

export function shouldExcludeTopic(
  topic: string,
  excludePrefixes: string[]
): boolean {
  return excludePrefixes.some((prefix) => topic.startsWith(prefix));
}

export function shouldResetTopic(
  topic: string,
  options: ResetTopicSelectionOptions
): boolean {
  if (shouldExcludeTopic(topic, options.excludePrefixes)) {
    return false;
  }

  if (options.includePrefixes.some((prefix) => topic.startsWith(prefix))) {
    return true;
  }

  return options.exactMatches.some((exactMatch) => topic === exactMatch);
}

export function getTopicsToReset(
  kafkaTopics: string[],
  options: ResetTopicSelectionOptions
): string[] {
  return kafkaTopics.filter((topic) => shouldResetTopic(topic, options));
}

export async function oauthBearerTokenProvider(
  region: string
): Promise<KafkaJS.OauthbearerProviderResponse> {
  const authTokenResponse = await generateAuthToken({ region });

  return {
    value: authTokenResponse.token,
    principal: "aws-msk-iam",
    lifetime: authTokenResponse.expiryTime,
  };
}

export async function purgeTopics(
  admin: Admin,
  topics: string[]
): Promise<PurgeResult[]> {
  const results: PurgeResult[] = [];

  for (const topic of topics) {
    const before = await admin.fetchTopicOffsets(topic);
    logInfo(`Topic ${topic} offsets before purge`);
    for (const { partition, offset, high, low } of before) {
      logInfo(
        `Topic ${topic} partition ${partition} - low: ${low}, high: ${high}, offset: ${offset}`
      );
    }

    const partitions: PartitionOffset[] = before
      .filter(({ high, low }: { high: string; low: string }) => high !== low)
      .map(({ partition, high }: { partition: number; high: string }) => ({
        partition,
        offset: high,
      }));

    if (!partitions.length) {
      results.push({
        topic,
        purged: false,
        reason: "already empty",
        before,
      });

      continue;
    }

    await admin.deleteTopicRecords({ topic, partitions });

    const after = await admin.fetchTopicOffsets(topic);
    logInfo(`Topic ${topic} offsets after purge:`);
    for (const { partition, offset, high, low } of after) {
      logInfo(
        `Topic ${topic} partition ${partition} - low: ${low}, high: ${high}, offset: ${offset}`
      );
    }

    results.push({
      topic,
      purged: true,
      before,
      after,
    });
  }

  return results;
}
