import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "./../../../services/data-preparation.service";

Given(
  "l'utente ha già creato una versione in {string} per quell'eservice",
  async function (descriptorState: EServiceDescriptorState) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.descriptorId =
      await dataPreparationService.createDescriptorWithGivenState(
        this.token,
        this.eserviceId,
        descriptorState
      );
  }
);

When("l'utente clona quell'e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });
  this.response = await apiClient.eservices.cloneEServiceByDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});
