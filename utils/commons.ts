import { readFileSync } from "fs";
import { z } from "zod";
import { AxiosResponse } from "axios";
import {
  Party,
  SessionTokens,
} from "../features/catalog/step_definitions/common-steps";
import { CreatedResource } from "../api/models";

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

export function getRiskAnalysis(params?: {
  completed?: boolean;
  party?: Party;
}) {
  const completed = params?.completed ?? true;
  const party: Party = params?.party ?? "PA1";
  const templateType =
    party === "PA1" || party === "PA2" ? "PA" : "Privato/GSP";
  const templateStatus = completed ? "completed" : "uncompleted";

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
      console.log(
        `Polling ended at iteration: ${i}. Waited ${SLEEP_TIME * i}ms`
      );
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

export function getOrganizationId(party: Party) {
  const file = JSON.parse(
    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    Buffer.from(readFileSync(process.env.TENANT_IDS_FILE_PATH!)).toString()
  );
  return file[party].admin.organizationId;
}

export function assertValidResponse(
  response: AxiosResponse<CreatedResource | void>
) {
  if (response.status >= 400) {
    throw Error(
      `Something went wrong: ${JSON.stringify(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (response.data as unknown as any).errors
      )}`
    );
  }
}
