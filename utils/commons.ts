import { z } from "zod";

export const getRandomInt = () =>
  Number(Math.random() * Number.MAX_SAFE_INTEGER).toFixed(0);
export const TEST_SEED = getRandomInt();

export async function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time);
  });
}

export async function makePolling<TReturnType>(
  promise: () => Promise<TReturnType>,
  shouldStop: (data: Awaited<TReturnType>) => boolean,
  errorMessage: string = ""
) {
  const MAX_POLLING_TRIES = 8;

  for (let i = 0; i < MAX_POLLING_TRIES; i++) {
    await sleep(400);
    const result = await promise();
    if (shouldStop(result)) {
      console.log(`Polling ended at iteration: ${i}`);
      return;
    }
  }
  throw Error(`Eventual consistency error: ${errorMessage}`);
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

export function divideArrayInChunks<T>(array: T[], chunkSize: number): T[][] {
  return Array.from({ length: Math.ceil(array.length / chunkSize) }, (_, i) =>
    array.slice(i * chunkSize, i * chunkSize + chunkSize)
  );
}

export async function executePromisesInParallelChunks<T>(
  promises: Array<() => Promise<T>>,
  chunkSize: number = 5
): Promise<T[]> {
  const chunks = divideArrayInChunks(promises, chunkSize);
  const results: T[] = [];
  for (const chunk of chunks) {
    const data = await Promise.all(chunk.map((promise) => promise()));
    results.push(...data);
  }
  return results;
}
