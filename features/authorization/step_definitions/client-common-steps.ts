import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { ClientKind } from "../../../api/models";
import {
  Role,
  TenantType,
  assertContextSchema,
  createBase64PublicKey,
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
  "{string} ha già inserito l'utente con ruolo {string} come membro di quel client",
  async function (tenantType: TenantType, roleOfMemberToAdd: Role) {
    assertContextSchema(this, {
      clientId: z.string(),
    });
    const token = await getToken(tenantType);
    this.clientMemberUserId = getUserId(tenantType, roleOfMemberToAdd);

    await dataPreparationService.addMemberToClient(
      token,
      this.clientId,
      this.clientMemberUserId
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

Given(
  "un {string} di {string} ha caricato una chiave pubblica in quel client",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
    });

    const token = await getToken(tenantType, role);

    this.keyId = await dataPreparationService.addPublicKeyToClient(
      token,
      this.clientId,
      {
        use: "SIG",
        alg: "RS256",
        name: `key-${this.TEST_SEED}-${getRandomInt()}`,
        key: createBase64PublicKey(),
      }
    );
  }
);
