import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  assertContextSchema,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given("l'utente ha già pubblicato quel descrittore", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  await dataPreparationService.bringDescriptorToGivenState({
    token: this.token,
    eserviceId: this.eserviceId,
    descriptorId: this.descriptorId,
    descriptorState: "PUBLISHED",
  });
});

When(
  "l'utente crea una versione in bozza per quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.response = await apiClient.eservices.createDescriptor(
      this.eserviceId,
      getAuthorizationHeader(this.token)
    );
  }
);
