import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

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
