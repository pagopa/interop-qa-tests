import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente aggiorna il nome di quel documento", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
    documentId: z.string(),
  });

  this.response = await apiClient.eservices.updateEServiceDocumentById(
    this.eserviceId,
    this.descriptorId,
    this.documentId,
    { prettyName: "updatedPrettyName" },
    getAuthorizationHeader(this.token)
  );
});
