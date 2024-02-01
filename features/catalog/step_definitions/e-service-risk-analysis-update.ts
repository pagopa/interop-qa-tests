import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { Party, Role } from "./common-steps";

Given(
  "un {string} di {string} ha già aggiunto un'analisi del rischio a quell'e-service",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = this.tokens[party]![role]!;
    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        getRiskAnalysis({ completed: true, party })
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
