import { KafkaJS } from "@confluentinc/kafka-javascript";
import { Kafka } from "@confluentinc/kafka-javascript/types/kafkajs";
import { logInfo, logWarning } from "../src/utilities/resetTopics";
import { sleep } from "./utils";

export async function getConsumerGroupsStatus(
  admin: KafkaJS.Admin,
  groups: string[]
): Promise<string[]> {
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

export function isNonEmptyGroupDeleteError(error: unknown): boolean {
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

export function isUnknownGroupDeleteError(error: unknown): boolean {
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

export async function waitForGroupsStability(
  kafka: Kafka,
  groups: string[]
): Promise<void> {
  const admin = kafka.admin();
  const timeoutMs = 60_000;
  const pollIntervalMs = 1_000;
  let elapsedMs = 0;

  await admin.connect();

  try {
    while (elapsedMs < timeoutMs) {
      const result = await admin.describeGroups(groups);
      const allStable = result.groups.every(
        (group) =>
          group.state === KafkaJS.ConsumerGroupStates.STABLE &&
          group.members.length > 0
      );

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
    "Timed out waiting for consumer groups to reach Stable state."
  );
}

export function buildGroupNames(
  count: number = 3,
  prefix?: string,
  suffix?: string
): string[] {
  const groupNames: string[] = [];
  for (let i = 0; i < count; i++) {
    // const uniqueSuffix = Math.random().toString(36).substring(2, 8);
    const suffixPart = suffix ? `-${suffix}` : "";
    groupNames.push(`${prefix || "test-group"}-${i}${suffixPart}`);
  }
  return groupNames;
}

export async function cleanupExistingTestGroups(
  admin: KafkaJS.Admin,
  groups: string[]
): Promise<void> {
  const CLEANUP_TIMEOUT_MS = 45_000;
  const CLEANUP_POLL_INTERVAL_MS = 1_500;

  if (!groups.length) {
    logInfo("No existing test groups to delete.");
    return;
  }

  try {
    await admin.connect();

    const existingGroups = await admin.listGroups();

    const groupsToDelete = existingGroups.groups
      .filter((group) => groups.includes(group.groupId))
      .map((group) => group.groupId);

    if (!groupsToDelete.length) {
      logInfo("No existing test groups to delete.");
      return;
    }
    const startedAt = Date.now();

    while (Date.now() - startedAt < CLEANUP_TIMEOUT_MS) {
      try {
        await admin.deleteGroups(groupsToDelete);
        logInfo(`Deleted existing groups: ${groupsToDelete.join(", ")}`);
        return;
      } catch (error) {
        if (isUnknownGroupDeleteError(error)) {
          logInfo("Test groups already deleted or not found.");
          return;
        }

        if (!isNonEmptyGroupDeleteError(error)) {
          throw error;
        }

        const statusParts: string[] = await getConsumerGroupsStatus(
          admin,
          groupsToDelete
        );

        logWarning(
          `Groups still non-empty, waiting for consumers to stop before delete (${statusParts.join(
            ", "
          )}).`
        );
        await sleep(CLEANUP_POLL_INTERVAL_MS);
      }
    }

    throw new Error(
      `Timed out waiting to delete non-empty groups: ${groupsToDelete.join(
        ", "
      )}. Stop active consumers and retry.`
    );
  } finally {
    await admin.disconnect();
  }
}
