import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState } from "../../../api/models";
import { TenantType } from "../../../utils/commons";
import { dataPreparationService } from "./../../../services/data-preparation.service";

Given(
  "{string} ha già creato una versione in {string} per quell'e-service",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);

    const { descriptorId } =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
      });

    this.descriptorId = descriptorId;
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
