import { readFileSync } from "fs";
import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente carica un documento allegato a quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    const blobFile = new Blob([readFileSync("./data/dummy.pdf")]);
    const doc = new File([blobFile], "documento-test-qa.pdf");

    this.response = await apiClient.agreements.addAgreementConsumerDocument(
      this.agreementId,
      {
        name: "documento-test-qa.pdf",
        prettyName: "documento-test-qa",
        doc,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
