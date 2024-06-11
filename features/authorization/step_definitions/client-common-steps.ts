import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { ClientKind } from "../../../api/models";
import {
  Role,
  TenantType,
  assertContextSchema,
  getRandomInt,
  getToken,
  getUserId,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato {int} client {string}",
  async function (
    tenantType: TenantType,
    numClient: number,
    cliendKind: ClientKind
  ) {
    assertContextSchema(this);
    const token = await getToken(tenantType);

    const arr = new Array(numClient).fill(0);

    const result = await Promise.all(
      arr.map((_, i) =>
        dataPreparationService.createClient(token, cliendKind, {
          name: `client-${i}-${this.TEST_SEED}-${getRandomInt()}`,
        })
      )
    );

    this.clientId = result[0];
  }
);

Given(
  "{string} ha inserito l'utente con ruolo {string} come membro di un client",
  async function (tenantType: TenantType, roleOfMemberToAdd: Role) {
    assertContextSchema(this, {
      clientId: z.string(),
    });
    const token = await getToken(tenantType);
    const userIdOfMemberToAdd = getUserId(tenantType, roleOfMemberToAdd);

    await dataPreparationService.addMemberToClient(
      token,
      this.clientId,
      userIdOfMemberToAdd
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} client(s)",
  function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);
