import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

Given(
  "l'utente ha già caricato un documento su quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const documentId = await dataPreparationService.addInterfaceToDescriptor(
      this.token,
      this.eserviceId,
      this.descriptorId
    );
    this.documentId = documentId;
  }
);
When("l'utente richiede il documento", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
    documentId: z.string(),
  });
  this.response = await apiClient.eservices.getEServiceDocumentById(
    this.eserviceId,
    this.descriptorId,
    this.documentId,
    getAuthorizationHeader(this.token)
  );
});
