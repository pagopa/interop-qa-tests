import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getUserId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede l'aggiunta di un admin di {string} al client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      token: z.string(),
    });

    const userId = getUserId(tenantType, "admin");

    this.response = await apiClient.clients.addUsersToClient(
      this.clientId,
      { userIds: [userId] },
      getAuthorizationHeader(this.token)
    );
  }
);
