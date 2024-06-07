import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing dei membri di quel client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });
    this.response = await apiClient.clients.getClientUsers(
      this.clientId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista di {int} utenti",
  async function (count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, 200);
    assert.equal(this.response.data.results.length, count);
  }
);
