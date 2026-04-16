import { z } from "zod";
import { LogLevel } from "../models/types";

export const DEFAULT_KAFKA_CLIENT_ID = "kafka-scripts";

const normalizeEnvValues = (envValue?: string): string[] => {
  if (!envValue) {
    return [];
  }

  return envValue
    .split(",")
    .map((value) => value.trim())
    .filter((value) => value.length > 0);
};

const LogLevelSchema = z.preprocess((value) => {
  if (value === undefined || value === null || value === "") {
    return LogLevel.INFO;
  }

  if (typeof value === "string") {
    const normalizedValue = value.trim().toUpperCase();

    if (/^\d+$/.test(normalizedValue)) {
      return Number(normalizedValue);
    }

    if (normalizedValue in LogLevel) {
      return LogLevel[normalizedValue as keyof typeof LogLevel];
    }
  }

  return value;
}, z.union([z.literal(LogLevel.DEBUG), z.literal(LogLevel.INFO), z.literal(LogLevel.WARNING), z.literal(LogLevel.ERROR)]).default(LogLevel.INFO));

export const ResetTopicsEnvSchema = z
  .object({
    AWS_REGION: z.string().optional(),
    DEBEZIUM_OFFSETS_TOPIC: z.string().optional(),
    DOMAIN_TOPIC_EXCLUDE: z.string().optional(),
    DOMAIN_TOPIC_PREFIX: z.string().optional(),
    KAFKA_AUTH_MODE: z.enum(["aws-iam", "none"]).default("aws-iam"),
    KAFKA_BROKERS: z.string().optional(),
    KAFKA_CLIENT_ID: z.string().optional(),
    KAFKA_LOG_LEVEL: LogLevelSchema,
    LOG_LEVEL: LogLevelSchema,
    QUIET_MODE: z.string().optional().default("0"),
  })
  .superRefine((env, ctx) => {
    if (!env.DOMAIN_TOPIC_PREFIX && !env.DEBEZIUM_OFFSETS_TOPIC) {
      ctx.addIssue({
        code: "custom",
        message:
          "Env vars DOMAIN_TOPIC_PREFIX and DEBEZIUM_OFFSETS_TOPIC cannot be both null.",
      });
    }

    if (!env.KAFKA_BROKERS) {
      ctx.addIssue({
        code: "custom",
        message: "Env var KAFKA_BROKERS cannot be null.",
      });
    }

    if (env.KAFKA_AUTH_MODE === "aws-iam" && !env.AWS_REGION) {
      ctx.addIssue({
        code: "custom",
        message: "Env var AWS_REGION cannot be null.",
      });
    }
  })
  .transform((env) => ({
    authMode: env.KAFKA_AUTH_MODE,
    awsRegion: env.AWS_REGION,
    brokers: normalizeEnvValues(env.KAFKA_BROKERS),
    exactMatches: normalizeEnvValues(env.DEBEZIUM_OFFSETS_TOPIC),
    excludePrefixes: normalizeEnvValues(env.DOMAIN_TOPIC_EXCLUDE),
    includePrefixes: normalizeEnvValues(env.DOMAIN_TOPIC_PREFIX),
    kafkaClientId: env.KAFKA_CLIENT_ID ?? DEFAULT_KAFKA_CLIENT_ID,
    logLevel: env.LOG_LEVEL,
    kafkaLogLevel: env.KAFKA_LOG_LEVEL,
    quietModeOn: env.QUIET_MODE === "1",
  }));

type ResetTopicsEnvSchema = z.infer<typeof ResetTopicsEnvSchema>;
export const config: ResetTopicsEnvSchema = ResetTopicsEnvSchema.parse(
  process.env
);
