import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede la lettura del contenuto della chiave pubblica",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
      keyId: z.string(),
    });

    this.response = await apiClient.clients.getEncodedClientKeyById(
      this.clientId,
      this.keyId,
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(this.response);
  }
);
