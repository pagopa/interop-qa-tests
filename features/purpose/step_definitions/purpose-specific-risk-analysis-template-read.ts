import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede la versione {string} del template dell'analisi del rischio",
  async function (version: string) {
    assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
    this.response =
      await apiClient.purposes.retrieveRiskAnalysisConfigurationByVersion(
        { riskAnalysisVersion: version, eserviceId: this.eserviceId },
        getAuthorizationHeader(this.token)
      );
  }
);
