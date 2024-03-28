import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role } from "./../../common-steps";

When("l'utente richiede la lettura della finalità", async function () {
  assertContextSchema(this, { purposeId: z.string() });
  this.response = await apiClient.purposes.getPurpose(
    this.purposeId,
    getAuthorizationHeader(this.token)
  );
});

Then("si ottiene status code 200 ma non l'analisi del rischio", function () {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
      data: z.object({
        riskAnalysis: z.unknown(),
      }),
    }),
  });

  assert.equal(this.response.status, 200);
  assert.equal(this.response.data.riskAnalysis, undefined);
});

Then(
  "si ottiene status code 200 ma l'analisi del rischio solo per admin",
  function () {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          riskAnalysis: z.unknown(),
        }),
      }),
      role: Role,
    });

    assert.equal(this.response.status, 200);
    if (this.role !== "admin") {
      assert.equal(this.response.data.riskAnalysis, undefined);
    }
  }
);
