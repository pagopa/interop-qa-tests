import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getRandomInt,
  getAuthorizationHeader,
  assertValidResponse,
} from "../../../utils/commons";

When("l'utente aggiorna la descrizione di quell'e-service", async function () {
  assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
  this.response = await apiClient.eservices.updateEServiceDescription(
    this.eserviceId,
    {
      description: `Nuova descrizione - ${getRandomInt()}`,
    },
    getAuthorizationHeader(this.token)
  );

  assertValidResponse(this.response);
});
