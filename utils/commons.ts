export async function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time);
  });
}

export async function makePolling<TReturnType>(
  promise: () => Promise<TReturnType>,
  shouldStop: (data: Awaited<TReturnType>) => boolean
) {
  const MAX_POLLING_TRIES = 4;

  for (let i = 0; i < MAX_POLLING_TRIES; i++) {
    await sleep(400);
    const result = await promise();
    if (shouldStop(result)) {
      console.log(`Polling ended at iteration: ${i}`);
      break;
    }
  }
}

export function getAuthorizationHeader(token: string) {
  return { headers: { Authorization: "Bearer " + token } } as const;
}
