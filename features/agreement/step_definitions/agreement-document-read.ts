import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di lettura del documento allegato a quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      agreementId: z.string(),
      documentId: z.string(),
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementConsumerDocument(
      this.agreementId,
      this.documentId,
      getAuthorizationHeader(this.token)
    );
  }
);
