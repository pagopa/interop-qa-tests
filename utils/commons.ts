import "../configs/env";
import { createReadStream, readFileSync } from "fs";
import crypto, { JsonWebKey, KeyObject, randomUUID } from "crypto";
import { z } from "zod";
import axios, { type AxiosResponse } from "axios";
import {
  setParallelCanAssign,
  parallelCanAssignHelpers,
} from "@cucumber/cucumber";
import jwt from "jsonwebtoken";
import { env } from "../configs/env";
import { generateSessionTokens } from "./session-tokens";

const { atMostOnePicklePerTag } = parallelCanAssignHelpers;
setParallelCanAssign(atMostOnePicklePerTag(["@no-parallel"]));

export type FileType = "yaml" | "wsdl";

export const TenantType = z.enum(["GSP", "GSP2", "PA1", "PA2", "Privato"]);
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

export function keyToBase64(key: string | KeyObject, withDelimitators = true) {
  if (withDelimitators) {
    return Buffer.from(key as string).toString("base64");
  }
  return Buffer.from(
    (key as string)
      .replace("-----BEGIN RSA PUBLIC KEY-----", "")
      .replace("-----END RSA PUBLIC KEY-----", "")
  ).toString("base64");
}

export function createKeyPairPEM(
  keyType: "RSA" | "NON-RSA" = "RSA",
  modulusLength = 2048
) {
  const { privateKey, publicKey } =
    keyType === "RSA"
      ? crypto.generateKeyPairSync("rsa", {
          publicKeyEncoding: {
            type: "pkcs1",
            format: "pem",
          },
          privateKeyEncoding: {
            type: "pkcs1",
            format: "pem",
          },
          modulusLength,
        })
      : crypto.generateKeyPairSync("ed25519", {
          publicKeyEncoding: {
            type: "spki",
            format: "pem",
          },
          privateKeyEncoding: {
            type: "pkcs8",
            format: "pem",
          },
          modulusLength,
        });

  return {
    privateKey,
    publicKey,
  };
}

export function createBase64PublicKey(
  keyType: "RSA" | "NON-RSA" = "RSA",
  modulusLength = 2048,
  withDelimitators = true
) {
  const keyPair = createKeyPairPEM(keyType, modulusLength);
  const { publicKey } = keyPair;
  return keyToBase64(publicKey, withDelimitators);
}

export async function downloadFile(fileUrl: string): Promise<Buffer> {
  const response = await axios({
    method: "get",
    url: fileUrl,
    responseType: "arraybuffer",
  });

  assertValidResponse(response);

  return Buffer.from(response.data);
}

export async function uploadFile(
  fileUrl: string,
  zipFilePath: string
): Promise<void> {
  const response = await axios({
    method: "put",
    url: fileUrl,
    data: createReadStream(zipFilePath),
    headers: {
      "Content-Type": "application/zip",
    },
  });

  assertValidResponse(response);
}

export function calculateKidFromPublicKey(publicKey: string): string {
  const jwk = crypto.createPublicKey(publicKey).export({ format: "jwk" });
  const sortedJwk = [...Object.keys(jwk)]
    .sort()
    .reduce<JsonWebKey>(
      (prev, sortedKey) => ({ ...prev, [sortedKey]: jwk[sortedKey] }),
      {}
    );
  const jwkString = JSON.stringify(sortedJwk);
  return crypto.createHash("sha256").update(jwkString).digest("base64url");
}

export function createClientAssertion(
  options:
    | {
        clientType: "CONSUMER";
        includeDigest?: boolean;
        clientId: string;
        purposeId: string;
        publicKey: string;
        privateKey: string;
      }
    | {
        clientType: "API";
        includeDigest?: boolean;
        clientId: string;
        publicKey: string;
        privateKey: string;
      }
): string {
  const issuedAt = Math.round(new Date().getTime() / 1000);

  const { publicKey, privateKey, clientId, clientType } = options;

  const kid = calculateKidFromPublicKey(publicKey);

  const headersRsa = {
    kid,
    alg: "RS256",
    typ: "JWT",
  };

  const payload = {
    iss: clientId,
    sub: clientId,
    aud: env.CLIENT_ASSERTION_JWT_AUDIENCE,
    jti: randomUUID(),
    iat: issuedAt,
    exp: issuedAt + 43200 * 60, // 30 days
    ...(clientType === "CONSUMER" ? { purposeId: options.purposeId } : {}),
    digest: options.includeDigest
      ? {
          alg: "SHA256",
          value:
            "5db26201b684761d2b970329ab8596773164ba1b43b1559980e20045941b8065",
        }
      : undefined,
  };

  return jwt.sign(payload, privateKey, {
    header: headersRsa,
  });
}

export async function requestVoucher({
  clientId,
  clientAssertion,
  clientAssertionType = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer",
  grantType = "client_credentials",
}: {
  clientId: string;
  clientAssertion: string;
  clientAssertionType?: string;
  grantType?: string;
}) {
  return await axios.post(
    env.AUTHORIZATION_SERVER_TOKEN_CREATION_URL,
    new URLSearchParams({
      client_id: clientId,
      client_assertion: clientAssertion,
      client_assertion_type: clientAssertionType,
      grant_type: grantType,
    }),
    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      validateStatus: () => true,
    }
  );
}
