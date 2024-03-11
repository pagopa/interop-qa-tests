import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

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
