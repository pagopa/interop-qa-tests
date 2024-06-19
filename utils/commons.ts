import "../configs/env";
import { readFileSync } from "fs";
import crypto from "crypto";
import { z } from "zod";
import { type AxiosResponse } from "axios";
import { env } from "../configs/env";
import { generateSessionTokens } from "./session-tokens";

export type FileType = "yaml" | "wsdl";

export const TenantType = z.enum(["GSP", "PA1", "PA2", "Privato"]);
export type TenantType = z.infer<typeof TenantType>;
export const Role = z.enum([
  "admin",
  "api",
  "security",
  "support",
  "api,security",
]);
export type Role = z.infer<typeof Role>;

export const SessionTokens = z.record(TenantType, z.record(Role, z.string()));
export type SessionTokens = z.infer<typeof SessionTokens>;

const tenantsIDSPath = "./data/tenants-ids.json";

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
  for (let i = 0; i < env.MAX_POLLING_TRIES; i++) {
    await sleep(env.POLLING_SLEEP_TIME);
    const response = await promise();

    try {
      const shouldStopPolling = shouldStop(response);
      if (shouldStopPolling) {
        return;
      }
    } catch (err) {
      throw new Error(
        `Error during shouldStop polling logic evaluation: ${err}`
      );
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
  const file = JSON.parse(Buffer.from(readFileSync(tenantsIDSPath)).toString());
  return file[tenantType].organizationId[env.ENVIRONMENT];
}

export function getUserId(tenantType: TenantType, role: Role) {
  const file = JSON.parse(Buffer.from(readFileSync(tenantsIDSPath)).toString());
  return file[tenantType]["user-roles"][role];
}

let cachedTokens: SessionTokens | undefined;

export async function getToken(
  tenantType: TenantType,
  role: Role = "admin"
): Promise<string> {
  if (!cachedTokens) {
    cachedTokens = SessionTokens.parse(
      await generateSessionTokens(tenantsIDSPath)
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

export function createBase64PublicKey(
  keyType: "RSA" | "NON-RSA" = "RSA",
  modulusLength = 2048,
  withDelimitators = true
) {
  const keyPair =
    keyType === "RSA"
      ? crypto.generateKeyPairSync("rsa", {
          modulusLength,
        })
      : crypto.generateKeyPairSync("ed25519", {
          modulusLength,
        });

  const { publicKey } = keyPair;

  const publicKeyPEM = publicKey.export({
    type: keyType === "RSA" ? "pkcs1" : "spki",
    format: "pem",
  });

  if (withDelimitators) {
    return Buffer.from(publicKeyPEM).toString("base64");
  }

  return Buffer.from(
    (publicKeyPEM as string)
      .replace("-----BEGIN RSA PUBLIC KEY-----", "")
      .replace("-----END RSA PUBLIC KEY-----", "")
  ).toString("base64");
}
