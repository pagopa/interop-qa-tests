import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente legge un'analisi del rischio di quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
    });
    this.response = await apiClient.eservices.getEServiceRiskAnalysis(
      this.eserviceId,
      this.riskAnalysisId,
      getAuthorizationHeader(this.token)
    );
  }
);
