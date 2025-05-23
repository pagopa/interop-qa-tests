import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  TenantType,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { EServiceDescriptorState } from "../../../api/models";

When("l'utente cancella quel documento", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
    documentId: z.string(),
  });
  this.response = await apiClient.eservices.deleteEServiceDocumentById(
    this.eserviceId,
    this.descriptorId,
    this.documentId,
    getAuthorizationHeader(this.token)
  );
});

When("l'utente cancella quell'interfaccia", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
    interfaceId: z.string(),
  });
  this.response = await apiClient.eservices.deleteEServiceDocumentById(
    this.eserviceId,
    this.descriptorId,
    this.interfaceId,
    getAuthorizationHeader(this.token)
  );
});

Given(
  "{string} ha già creato un e-service con un descrittore in stato {string} con un'interfaccia già caricata",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token);

    const result = await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });
    this.interfaceId = result.interfaceId;

    if (descriptorState === "DRAFT") {
      this.interfaceId = await dataPreparationService.addInterfaceToDescriptor(
        token,
        eserviceId,
        descriptorId
      );
    }

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);
