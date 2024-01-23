import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente aggiorna quell'e-service", async function () {
  assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
  this.response = await apiClient.eservices.updateEServiceById(
    this.eserviceId,
    {
      name: `e-service - ${getRandomInt()}`,
      description: "Nuova descrizione",
      mode: "RECEIVE",
      technology: "SOAP",
    },
    getAuthorizationHeader(this.token)
  );
});
