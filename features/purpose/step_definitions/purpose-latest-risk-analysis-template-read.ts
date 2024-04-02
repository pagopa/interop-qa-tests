import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede il template dell'analisi del rischio",
  async function () {
    assertContextSchema(this, { token: z.string() });
    this.response =
      await apiClient.purposes.retrieveLatestRiskAnalysisConfiguration(
        getAuthorizationHeader(this.token)
      );
  }
);
