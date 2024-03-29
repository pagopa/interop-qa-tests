import assert from "assert";
import {
  setDefaultTimeout,
  BeforeAll,
  Before,
  Given,
  Then,
} from "@cucumber/cucumber";
import { z } from "zod";
import { assertContextSchema, getRandomInt, getToken } from "../utils/commons";
import { generateSessionTokens } from "../utils/session-tokens";
import { dataPreparationService } from "../services/data-preparation.service";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

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

BeforeAll(async function () {
  this.parameters.tokens = SessionTokens.parse(
    await generateSessionTokens(process.env.TENANTS_IDS_FILE_PATH)
  );
});

Before(function () {
  this.TEST_SEED = getRandomInt();
  this.tokens = this.parameters.tokens;
});

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, tenantType: TenantType) {
    this.token = getToken(this.tokens, tenantType, role);
    this.role = role;
    this.tenantType = tenantType;
  }
);

Then("si ottiene status code {int}", function (statusCode: number) {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
    }),
  });

  assert.equal(this.response.status, statusCode);
});

Given(
  "{string} ha già rifiutato l'aggiornamento della stima di carico per quella finalità",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
    });

    const token = getToken(this.tokens, tenant, "admin");

    await dataPreparationService.rejectPurposeVersion(
      token,
      this.purposeId,
      this.waitingForApprovalVersionId
    );
  }
);
