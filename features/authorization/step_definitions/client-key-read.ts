import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  Role,
  TenantType,
  assertContextSchema,
  createBase64PublicKey,
  getAuthorizationHeader,
  getRandomInt,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";

Given(
  "un {string} di {string} ha caricato una chiave pubblica nel client",
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

When("l'utente richiede la lettura della chiave pubblica", async function () {
  assertContextSchema(this, {
    token: z.string(),
    clientId: z.string(),
    keyId: z.string(),
  });

  this.response = await apiClient.clients.getClientKeyById(
    this.clientId,
    this.keyId,
    getAuthorizationHeader(this.token)
  );
});