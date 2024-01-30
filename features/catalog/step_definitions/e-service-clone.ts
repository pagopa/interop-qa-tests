import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "./../../../services/data-preparation.service";
import { Party, Role } from "./common-steps";

Given(
  "un {string} di {string} ha già creato una versione in {string} per quell'eservice",
  async function (
    role: Role,
    party: Party,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = this.tokens[party]![role]!;

    this.descriptorId =
      await dataPreparationService.createDescriptorWithGivenState(
        token,
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
