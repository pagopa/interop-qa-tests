import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  Role,
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  getUserId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già rimosso l'utente con ruolo {string} dai membri di quel client",
  async function (tenantType: TenantType, role: Role) {
    assertContextSchema(this, {
      clientId: z.string(),
    });
    const token = await getToken(tenantType, "admin");
    const userId = getUserId(tenantType, role);
    await dataPreparationService.removeMemberFromClient(
      token,
      this.clientId,
      userId
    );
  }
);

When(
  "l'utente richiede una operazione di cancellazione della chiave di quel client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
      keyId: z.string(),
    });

    this.response = await apiClient.clients.deleteClientKeyById(
      this.clientId,
      this.keyId,
      getAuthorizationHeader(this.token)
    );
  }
);
