import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di lettura di quel client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });

    this.response = await apiClient.clients.getClient(
      this.clientId,
      getAuthorizationHeader(this.token)
    );
  }
);
