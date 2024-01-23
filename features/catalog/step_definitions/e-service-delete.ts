import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

Given(
  "l'utente ha già creato un e-service senza descrittore",
  async function () {
    assertContextSchema(this, { token: z.string() });
    this.eserviceId = await dataPreparationService.createEService(this.token);
  }
);

When("l'utente cancella quell'e-service", async function () {
  assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
  this.response = await apiClient.eservices.deleteEService(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
});
