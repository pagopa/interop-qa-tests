import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

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
