import { readFileSync } from "node:fs";
import { resolve } from "node:path";
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

const parseExactMatchesFile = (filePath?: string): string[] => {
  if (!filePath) {
    return [];
  }

  const resolvedPath = resolve(filePath);
  const content = readFileSync(resolvedPath, "utf8").trim();

  if (!content) {
    return [];
  }

  if (content.startsWith("[")) {
    const parsed = JSON.parse(content);
    if (!Array.isArray(parsed)) {
      throw new Error(
        `Invalid exact matches file format at ${resolvedPath}: expected JSON array of strings.`
      );
    }

    return parsed
      .map((value) => String(value).trim())
      .filter((value) => value.length > 0);
  }

  return content
    .split(/\r?\n|,/)
    .map((value) => value.trim())
    .filter((value) => value.length > 0);
};

const mergeUniqueValues = (...values: string[][]): string[] => [
  ...new Set(values.flat()),
];

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
    EXACT_MATCHES_FILE_PATH: z.string().optional(),
    KAFKA_AUTH_MODE: z.enum(["aws-iam", "none"]).default("aws-iam"),
    KAFKA_BROKERS: z.string().optional(),
    KAFKA_CLIENT_ID: z.string().optional(),
    KAFKA_LOG_LEVEL: LogLevelSchema,
    LOG_LEVEL: LogLevelSchema,
    QUIET_MODE: z.string().optional().default("0"),
  })
  .superRefine((env, ctx) => {
    if (
      !env.DOMAIN_TOPIC_PREFIX &&
      !env.DEBEZIUM_OFFSETS_TOPIC &&
      !env.EXACT_MATCHES_FILE_PATH
    ) {
      ctx.addIssue({
        code: "custom",
        message:
          "At least one between DOMAIN_TOPIC_PREFIX, DEBEZIUM_OFFSETS_TOPIC, and EXACT_MATCHES_FILE_PATH must be set.",
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
    exactMatches: mergeUniqueValues(
      normalizeEnvValues(env.DEBEZIUM_OFFSETS_TOPIC),
      parseExactMatchesFile(env.EXACT_MATCHES_FILE_PATH)
    ),
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
