import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente scarica il documento di analisi del rischio", async function () {
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
  const versionId = purpose.currentVersion?.id;
  const riskAnalysisDocumentId =
    purpose.currentVersion?.riskAnalysisDocument?.id;

  if (!versionId) {
    throw new Error(`Purpose version for id ${this.purposeId} not found`);
  }

  if (!riskAnalysisDocumentId) {
    throw new Error(
      `Risk analysis document for purpose id ${this.purposeId} not found`
    );
  }

  this.response = await apiClient.purposes.getRiskAnalysisDocument(
    this.purposeId,
    versionId,
    riskAnalysisDocumentId,
    getAuthorizationHeader(this.token)
  );
});

Given(
  "l'utente ha già aggiornato finalità rispettando le stime di carico per quell'e-service",
  async function () {}
);
