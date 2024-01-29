import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
} from "../../../utils/commons";
import { EServiceMode } from "../../../api/models";
import { apiClient } from "../../../api";
import { Party } from "./common-steps";

Given(
  "l'utente ha già creato un e-service in modalità {string} senza descrittore",
  async function (mode: EServiceMode) {
    assertContextSchema(this, { token: z.string() });
    this.eserviceId = await dataPreparationService.createEService(this.token, {
      mode,
    });
  }
);

When("l'utente aggiunge un'analisi del rischio", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    party: Party,
  });
  this.response = await apiClient.eservices.addRiskAnalysisToEService(
    this.eserviceId,
    getRiskAnalysis({ completed: true, party: this.party }),
    getAuthorizationHeader(this.token)
  );
});
