import { KafkaJS } from "@confluentinc/kafka-javascript";

export type Admin = KafkaJS.Admin;
export type KafkaConfig = KafkaJS.KafkaConfig;
export type PartitionOffset = KafkaJS.PartitionOffset;

export type TopicOffset = Awaited<
  ReturnType<Admin["fetchTopicOffsets"]>
>[number];

export type PurgeResult = {
  topic: string;
  purged: boolean;
  reason?: string;
  before: TopicOffset[];
  after?: TopicOffset[];
};

export type KafkaAuthMode = "aws-iam" | "none";

export type ResetTopicSelectionOptions = {
  includePrefixes: string[];
  excludePrefixes: string[];
  exactMatches: string[];
};

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARNING = 2,
  ERROR = 3,
}
