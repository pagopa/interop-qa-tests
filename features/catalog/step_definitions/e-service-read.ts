import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente richiede la lettura di quell'e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
  });

  this.response = await apiClient.producers.getProducerEServiceDetails(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
});
