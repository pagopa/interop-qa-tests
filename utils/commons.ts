import { readFileSync } from "fs";
import { z } from "zod";
import { Party } from "../features/catalog/step_definitions/common-steps";

export const getRandomInt = () =>
  Number(Math.random() * Number.MAX_SAFE_INTEGER).toFixed(0);
export async function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time);
  });
}

export async function makePolling<TReturnType>(
  promise: () => Promise<TReturnType>,
  shouldStop: (data: Awaited<TReturnType>) => boolean
) {
  const MAX_POLLING_TRIES = 6;

  for (let i = 0; i < MAX_POLLING_TRIES; i++) {
    await sleep(400);
    const result = await promise();
    if (shouldStop(result)) {
      console.log(`Polling ended at iteration: ${i}`);
      return;
    }
  }
  throw Error("Eventual consistency error");
}

export function getAuthorizationHeader(token: string) {
  return { headers: { Authorization: "Bearer " + token } } as const;
}

export function assertContextSchema<TSchema extends z.ZodRawShape>(
  context: unknown,
  schema: TSchema
): asserts context is z.infer<z.ZodObject<TSchema>> {
  z.object(schema).parse(context);
}

export function getOrganizationId(party: Party) {
  const file = JSON.parse(
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    Buffer.from(readFileSync(process.env.TENANT_IDS_FILE_PATH!)).toString()
  );
  return file[party].admin.organizationId;
}
