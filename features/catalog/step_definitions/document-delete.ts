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
  "un {string} di {string} ha già caricato un documento su quel descrittore",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = getToken(this.tokens, party, role);

    const documentId = await dataPreparationService.addDocumentToDescriptor(
      token,
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
