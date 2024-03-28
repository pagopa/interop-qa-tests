import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
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

Then(
  "si ottiene status code {int} e il template in versione {string}",
  async function (statusCode: number, expectedVersion: string) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          version: z.string(),
          questions: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.version, expectedVersion);
  }
);
