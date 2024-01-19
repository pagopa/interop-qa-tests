import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "l'utente ha già caricato un documento su quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const documentId = await dataPreparationService.addDocumentToDescriptor(
      this.token,
      this.eserviceId,
      this.descriptorId
    );
    this.documentId = documentId;
  }
);
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
