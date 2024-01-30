import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { Party } from "./common-steps";

Given(
  "l'utente ha già aggiunto un'analisi del rischio a quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      party: Party,
    });
    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        this.token,
        this.eserviceId,
        getRiskAnalysis({ completed: true, party: this.party })
      );
  }
);

When(
  "l'utente aggiorna l'analisi del rischio di quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
      party: Party,
    });

    this.response = await apiClient.eservices.updateEServiceRiskAnalysis(
      this.eserviceId,
      this.riskAnalysisId,
      getRiskAnalysis({ completed: false, party: this.party }),
      getAuthorizationHeader(this.token)
    );
  }
);
