import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

Given(
  "l'utente ha caricato un'interfaccia per quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    await dataPreparationService.addInterfaceToDescriptor(
      this.token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

When("l'utente pubblica quel descrittore", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  this.response = await apiClient.eservices.publishDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});
