import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

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

Given(
  "l'utente ha già cancellato quel documento su quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
      documentId: z.string(),
    });
    await dataPreparationService.deleteDocumentFromDescriptor(
      this.eserviceId,
      this.descriptorId,
      this.documentId,
      this.token
    );
  }
);
