import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";

When("l'utente scarica il documento di analisi del rischio", async function () {
  assertContextSchema(this, {
    token: z.string(),
    purposeId: z.string(),
    versionId: z.string(),
  });

  const getPurposeResponse = await apiClient.purposes.getPurpose(
    this.purposeId,
    getAuthorizationHeader(this.token)
  );

  assertValidResponse(getPurposeResponse);

  const purpose = getPurposeResponse.data;
  const riskAnalysisDocumentId =
    purpose.currentVersion?.riskAnalysisDocument?.id;

  if (!riskAnalysisDocumentId) {
    throw new Error(
      `Risk analysis document for purpose id ${this.purposeId} not found`
    );
  }

  this.response = await apiClient.purposes.getRiskAnalysisDocument(
    this.purposeId,
    this.versionId,
    riskAnalysisDocumentId,
    getAuthorizationHeader(this.token)
  );
});

Given(
  "l'utente ha già aggiornato finalità rispettando le stime di carico per quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });
    await dataPreparationService.createNewPurposeVersion(
      this.token,
      this.purposeId,
      { dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1 }
    );
  }
);
