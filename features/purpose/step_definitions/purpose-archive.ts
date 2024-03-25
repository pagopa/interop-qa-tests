import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";

When("l'utente archivia quella finalità", async function () {
  assertContextSchema(this, {
    token: z.string(),
    purposeId: z.string(),
  });

  const getPurposeResponse = await apiClient.purposes.getPurpose(
    this.purposeId,
    getAuthorizationHeader(this.token)
  );

  assertValidResponse(getPurposeResponse);

  const purpose = getPurposeResponse.data;
  const versionId =
    purpose.currentVersion?.id ?? purpose.waitingForApprovalVersion?.id;

  if (!versionId) {
    throw new Error(`Purpose version for id ${this.purposeId} not found`);
  }

  this.response = await apiClient.purposes.archivePurposeVersion(
    this.purposeId,
    versionId,
    getAuthorizationHeader(this.token)
  );
});

Given(
  "{string} ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
    });

    const token = getToken(this.tokens, tenant, "admin");

    await dataPreparationService.createNewPurposeVersion(
      token,
      this.purposeId,
      { dailyCalls: ESERVICE_DAILY_CALLS.perConsumer + 1 }
    );
  }
);
