import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente cancella il documento allegato a quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      agreementId: z.string(),
      documentId: z.string(),
      token: z.string(),
    });
    this.response = await apiClient.agreements.removeAgreementConsumerDocument(
      this.agreementId,
      this.documentId,
      getAuthorizationHeader(this.token)
    );
  }
);
