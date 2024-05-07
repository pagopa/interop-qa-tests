import assert from "assert";
import { setDefaultTimeout, Before, Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import {
  Role,
  TenantType,
  assertContextSchema,
  getRandomInt,
  getToken,
} from "../utils/commons";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

Before(function () {
  this.TEST_SEED = getRandomInt();
});

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, tenantType: TenantType) {
    this.token = await getToken(tenantType, role);
    this.role = role;
    this.tenantType = tenantType;
  }
);

Then("si ottiene status code {int}", function (statusCode: number) {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
    }),
  });

  assert.equal(this.response.status, statusCode);
});
