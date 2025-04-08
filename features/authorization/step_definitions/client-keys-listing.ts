import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  Role,
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getUserId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing delle chiavi di quel client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });

    this.response = await apiClient.clients.getClientKeys(
      { clientId: this.clientId, limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} chiavi",
  async function (statusCode: number, numKeys: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          keys: z.array(z.unknown()),
        }),
      }),
    });

    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.keys.length, numKeys);
  }
);

When(
  "l'utente richiede una operazione di listing delle chiavi di quel client create dall'utente {string}",
  async function (role: Role) {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
      tenantType: z.string(),
    });

    this.response = await apiClient.clients.getClientKeys(
      {
        userIds: [getUserId(this.tenantType as TenantType, role)],
        clientId: this.clientId,
        limit: 50,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
