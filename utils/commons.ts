import "../configs/env";
import { readFileSync } from "fs";
import { z } from "zod";
import { AxiosResponse } from "axios";
import { CreatedResource } from "../api/models";
import { TenantType, Role, SessionTokens } from "../features/common-steps";
import { apiClient } from "../api";
import { generateSessionTokens } from "./session-tokens";

export const getRandomInt = () =>
  Number(Math.random() * Number.MAX_SAFE_INTEGER).toFixed(0);

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
  for (let i = 0; i < process.env.MAX_POLLING_TRIES; i++) {
    await sleep(process.env.POLLING_SLEEP_TIME);
    const result = await promise();
    if (shouldStop(result)) {
      return;
    }
  }
  throw Error(`Eventual consistency error: ${errorMessage}`);
}

export function getAuthorizationHeader(token: string) {
  return { headers: { Authorization: "Bearer " + token } } as const;
}

const COMMON_CONTEXT_SCHEMA = z.object({
  TEST_SEED: z.string(),
});
export function assertContextSchema<TSchema extends z.ZodRawShape>(
  context: unknown,
  schema?: TSchema
): asserts context is z.infer<z.ZodObject<TSchema>> &
  z.infer<typeof COMMON_CONTEXT_SCHEMA> {
  if (schema) {
    z.object(schema).parse(context);
  }
}

export function getOrganizationId(tenantType: TenantType) {
  const file = JSON.parse(
    Buffer.from(readFileSync(process.env.TENANTS_IDS_FILE_PATH)).toString()
  );
  return file[tenantType].admin.organizationId;
}

let cachedTokens: SessionTokens | undefined;

export async function getToken(
  tenantType: TenantType,
  role: Role = "admin"
): Promise<string> {
  if (!cachedTokens) {
    cachedTokens = SessionTokens.parse(
      await generateSessionTokens(process.env.TENANTS_IDS_FILE_PATH)
    );
  }
  const token = cachedTokens[tenantType]?.[role];
  if (!token) {
    throw new Error(
      `Token not found for tenantType: ${tenantType} and role: ${role}`
    );
  }
  return token;
}

export function assertValidResponse<T>(response: AxiosResponse<T>) {
  if (response.status >= 400) {
    throw Error(
      `Something went wrong: ${JSON.stringify(
        response.data ?? response.statusText
      )}`
    );
  }
}

export type FileType = "yaml" | "wsdl";

export async function uploadInterfaceDocument(
  fileName: string,
  eserviceId: string,
  descriptorId: string,
  token: string
): Promise<AxiosResponse<CreatedResource>> {
  const blobFile = new Blob([readFileSync(`./data/${fileName}`)]);
  const file = new File([blobFile], fileName);

  return apiClient.eservices.createEServiceDocument(
    eserviceId,
    descriptorId,
    {
      kind: "INTERFACE",
      prettyName: "Interfaccia",
      doc: file,
    },
    getAuthorizationHeader(token)
  );
}
