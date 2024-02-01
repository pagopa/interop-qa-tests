import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role, Party } from "../../common-steps";

Given(
  "un {string} di {string} ha già creato un e-service senza descrittore",
  async function (role: Role, party: Party) {
    assertContextSchema(this);

    const token = getToken(this.tokens, party, role);

    this.eserviceId = await dataPreparationService.createEService(token);
  }
);

When("l'utente cancella quell'e-service", async function () {
  assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
  this.response = await apiClient.eservices.deleteEService(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
});
