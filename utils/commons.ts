import { readFileSync } from "fs";
import { z } from "zod";
import { AxiosResponse } from "axios";
import { CreatedResource } from "../api/models";
import { TenantType, Role, SessionTokens } from "../features/common-steps";
import { apiClient } from "../api";

type RiskAnalysisTemplateType = "PA" | "Privato/GSP";

const RISK_ANALYSIS_DATA: Record<
  RiskAnalysisTemplateType,
  { version: string; completed: unknown; uncompleted: unknown }
> = {
  "Privato/GSP": {
    version: "2.0",
    completed: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      usesPersonalData: ["NO"],
      usesThirdPartyPersonalData: ["NO"],
    },
    uncompleted: {
      purpose: ["INSTITUTIONAL"],
      usesPersonalData: ["NO"],
      usesThirdPartyPersonalData: ["NO"],
    },
  },
  PA: {
    version: "3.0",
    completed: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      personalDataTypes: ["WITH_NON_IDENTIFYING_DATA"],
      legalBasis: ["CONSENT"],
      knowsDataQuantity: ["NO"],
      deliveryMethod: ["CLEARTEXT"],
      policyProvided: ["YES"],
      confirmPricipleIntegrityAndDiscretion: ["true"],
      doneDpia: ["NO"],
      dataDownload: ["NO"],
      purposePursuit: ["MERE_CORRECTNESS"],
      checkedExistenceMereCorrectnessInteropCatalogue: ["true"],
      usesThirdPartyData: ["NO"],
      declarationConfirmGDPR: ["true"],
    },
    uncompleted: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      legalBasis: ["CONSENT"],
      knowsDataQuantity: ["NO"],
      deliveryMethod: ["CLEARTEXT"],
      policyProvided: ["YES"],
      confirmPricipleIntegrityAndDiscretion: ["true"],
      doneDpia: ["NO"],
      dataDownload: ["NO"],
      purposePursuit: ["MERE_CORRECTNESS"],
      checkedExistenceMereCorrectnessInteropCatalogue: ["true"],
      usesThirdPartyData: ["NO"],
      declarationConfirmGDPR: ["true"],
    },
  },
};

export function getRiskAnalysis({
  tenantType,
  completed,
}: {
  tenantType: TenantType;
  completed?: boolean;
}) {
  const templateType =
    tenantType === "PA1" || tenantType === "PA2" ? "PA" : "Privato/GSP";
  const templateStatus = completed ?? true ? "completed" : "uncompleted";

  const answers = RISK_ANALYSIS_DATA[templateType][templateStatus];
  const version = RISK_ANALYSIS_DATA[templateType].version;

  return {
    name: "finalità test",
    riskAnalysisForm: {
      version,
      answers,
    },
  };
}

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
  const MAX_POLLING_TRIES = 32;
  const SLEEP_TIME = 100;

  for (let i = 0; i < MAX_POLLING_TRIES; i++) {
    await sleep(SLEEP_TIME);
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
  tokens: SessionTokens,
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
    Buffer.from(readFileSync(process.env.TENANT_IDS_FILE_PATH!)).toString()
  );
  return file[tenantType].admin.organizationId;
}

export function getToken(
  tokens: SessionTokens,
  tenantType: TenantType,
  role: Role
) {
  const token = tokens[tenantType]?.[role];
  if (!token) {
    throw Error(
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

/**
 * The `getAttributes` BFF endpoint parses the query string in a different way from
 * the `paramsSerializer` function provided to the `axios` client.
 * This function is TEMPORARY and should be removed as soon as the BFF endpoint is fixed.
 *
 * @deprecated
 */
export function TOBE_REMOVED_customSerializer(params: Record<string, unknown>) {
  return Object.entries(params)
    .filter(([, value]) => value !== undefined && value !== null)
    .map(([key, value]) =>
      Array.isArray(value)
        ? value.map((v) => `${key}=${v}`).join("&")
        : `${key}=${value}`
    )
    .join("&");
}
